import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:instagram/src/message/models/chat_info.dart';
import 'package:instagram/src/message/models/message_data.dart';
import 'package:instagram/src/repo/models/model.dart';
import 'package:instagram/src/resources/firestore_methods.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tuple/tuple.dart';

part 'message_event.dart';
part 'message_state.dart';

class MessageBloc extends Bloc<MessageEvent, MessageState> {
  final FirestoreMethods _methods;
  final User auth;
  final ChatInfo? info;
  bool _isFetching = false;
  final _limit = 25;
  final _date = DateTime.now();

  MessageBloc(
    FirestoreMethods methods, {
    required this.auth,
    required this.info,
  })  : _methods = methods,
        super(const MessageState()) {
    on<MessageSubscripted>(
      (event, emit) async {
        final chat = event.chat;
        emit(state.copyWith(chat: chat));

        _updateTimestamp(state.chat);
        add(const MessageFetched());

        return emit.forEach(
            Rx.combineLatest2(
              _methods.chats.at(chatId: chat.chatId).cast<Chat>().flatMap((e) =>
                  Stream.fromIterable(e.users)
                      .flatMap((uid) =>
                          _methods.users.get(uid: uid).asStream().cast<User>())
                      .toList()
                      .asStream()
                      .map((members) => Tuple2(e, members))),
              _methods.messages
                  .latest(chatId: chat.chatId)
                  .where((e) => e != null)
                  .cast<Message>()
                  .flatMap((e) => _methods.users
                      .get(uid: e.uid)
                      .asStream()
                      .where((u) => u != null)
                      .cast<User>()
                      .map((u) => Tuple2(e, u))),
              (Tuple2<Chat, List<User>> a, Tuple2<Message, User> b) =>
                  Tuple4(a.item1, a.item2, b.item1, b.item2),
            ), onData: (Tuple4<Chat, List<User>, Message, User> data) {
          final chat = data.item1;
          final members = data.item2;
          final msg = data.item3;
          final msgUser = data.item4;
          late List<MessageData> list;
          if (state.messages.isNotEmpty &&
              state.messages.first.message.messageId == msg.messageId) {
            list = state.messages;
          } else if (!msg.date.isAfter(_date)) {
            list = state.messages;
          } else {
            list = [
              MessageData(user: msgUser, message: msg),
              ...state.messages
            ];
          }
          return state.copyWith(
            status: MessageStatus.success,
            messages: list,
            chat: chat,
            members: members,
          );
        });
      },
    );

    on<MessageFetched>(
      (event, emit) async {
        final chat = state.chat;
        if (chat == null) return;

        if (state.hasReachedMax || _isFetching) return;
        _isFetching = true;

        late List<MessageData> messages;
        try {
          if (state.status == MessageStatus.initial) {
            emit(state.copyWith(status: MessageStatus.loading));
            messages = await _fetch(chatId: chat.chatId);
            messages.removeWhere((e) => e.message.date.isAfter(_date));
          } else if (state.messages.isNotEmpty) {
            messages = await _fetch(
                chatId: chat.chatId, cursor: state.messages.last.message);
          }

          emit(state.copyWith(
            status: MessageStatus.success,
            messages: [
              ...state.messages,
              ...messages,
            ],
            hasReachedMax: messages.length < _limit,
          ));
        } finally {
          _isFetching = false;
        }
      },
    );

    on<MessageSend>(
      (event, emit) async {
        var chat = state.chat;
        if (chat == null) {
          chat = await _methods.chats.create(
            group: info!.group,
            members: {auth.uid, ...info!.others.map((e) => e.uid)},
          );
          add(MessageSubscripted(chat: chat));
        }
        await _methods.messages.send(
          chatId: chat.chatId,
          uid: auth.uid,
          text: event.text,
        );
      },
    );
  }

  @override
  Future<void> close() async {
    await _updateTimestamp(state.chat);
    super.close();
  }

  Future<void> _updateTimestamp(Chat? chat) async {
    if (chat != null) {
      return await _methods.chats.updateUserTimestamp(
        chat: chat,
        uid: auth.uid,
      );
    }
  }

  Future<List<MessageData>> _fetch(
      {required String chatId, Message? cursor}) async {
    final data = await _methods.messages.fetch(
      chatId: chatId,
      cursor: cursor,
      limit: _limit,
    );
    return await _map(data);
  }

  Future<MessageData> _get(Message message) async {
    return MessageData(
      message: message,
      user: (await _methods.users.get(
        uid: message.uid,
      ))!,
    );
  }

  Future<List<MessageData>> _map(List<Message> messages) async {
    final streams = messages.map((post) {
      return _get(post).asStream();
    }).toList();
    return await Rx.concatEager(streams).toList();
  }
}
