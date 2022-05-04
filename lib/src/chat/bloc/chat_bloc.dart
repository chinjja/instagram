import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:instagram/src/chat/models/chat_data.dart';
import 'package:instagram/src/repo/models/model.dart';
import 'package:instagram/src/resources/firestore_methods.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tuple/tuple.dart';

part 'chat_event.dart';
part 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final User auth;
  final FirestoreMethods _methods;

  ChatBloc(
    this._methods, {
    required this.auth,
  }) : super(const ChatState()) {
    on<ChatSubscriptionRequested>(
      (event, emit) {
        emit(state.copyWith(status: ChatStatus.loading));
        return emit.forEach(
            _methods.chats.chats(uid: auth.uid).flatMap((chats) =>
                Stream.fromIterable(chats).flatMap((chat) => Rx.combineLatest3(
                    Stream.fromIterable(chat.users)
                        .flatMap(
                            (uid) => _methods.users.get(uid: uid).asStream())
                        .where((user) => user != null)
                        .cast<User>()
                        .take(4)
                        .toList()
                        .asStream(),
                    _methods.messages.latest(chatId: chat.chatId),
                    _methods.chats.user(chatId: chat.chatId, uid: auth.uid),
                    (
                      List<User> members,
                      Message? message,
                      ChatUser? chatUser,
                    ) =>
                        Tuple4(chat, members, message, chatUser)))),
            onData: (Tuple4<Chat, List<User>, Message?, ChatUser?> data) {
          final copy = state.list
              .where((e) => e.chat.chatId != data.item1.chatId)
              .toList();

          final chat = data.item1;
          final members = data.item2;
          final msg = data.item3;
          final user = data.item4;
          if (msg != null && user != null) {
            copy.add(ChatData(
              date: msg.date,
              chat: chat,
              members: members,
              lastMessage: msg.text,
              isNew: msg.date.isAfter(user.date),
            ));
            copy.sort((a, b) => b.date.compareTo(a.date));
          }

          return state.copyWith(
            status: ChatStatus.success,
            list: copy,
          );
        }, onError: (_, __) {
          return state.copyWith(status: ChatStatus.failure);
        });
      },
    );

    on<ChatDeleted>(
      (event, emit) {
        return _methods.chats.delete(chatId: event.chat.chatId);
      },
    );
  }
}
