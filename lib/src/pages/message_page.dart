import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:instagram/src/models/chat.dart';
import 'package:instagram/src/models/message.dart';
import 'package:instagram/src/models/user.dart';
import 'package:instagram/src/resources/firestore_methods.dart';
import 'package:instagram/src/utils/utils.dart';
import 'package:instagram/src/widgets/message_card.dart';
import 'package:instagram/src/widgets/send_text_field.dart';
import 'package:instagram/src/widgets/user_list_tile.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';

class MessagePage extends StatefulWidget {
  const MessagePage({
    Key? key,
    required this.group,
    this.chat,
    required this.currentUser,
    this.others,
    required this.autoFocus,
  })  : assert(chat != null || others != null),
        super(key: key);
  final Chat? chat;
  final User currentUser;
  final List<String>? others;
  final bool group;
  final bool autoFocus;
  @override
  State<MessagePage> createState() => _MessagePageState();
}

class _MessagePageState extends State<MessagePage> with WidgetsBindingObserver {
  late final _firestore = context.read<FirestoreMethods>();
  late final timestamp = Timestamp.now();
  late Chat? chat = widget.chat;
  StreamSubscription? subscription;
  Map<String, User> userMap = {};
  List<User> userList = [];
  Stream<List<Message>>? messageStream;
  late Stream<List<Message>> latestMessateStream;
  int latestMore = 0;
  List<Message> messages = [];

  @override
  void initState() {
    super.initState();
    if (!widget.group && chat == null) {
      _firestore.chats
          .findDirectChat(uid: widget.currentUser.uid, to: widget.others!.first)
          .then((value) => initChat(value!))
          .onError((error, stackTrace) {});
    }
    if (chat != null) {
      initChat(chat!);
    }
    WidgetsBinding.instance?.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance?.removeObserver(this);
    subscription?.cancel();
    checkMessage();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      checkMessage();
    }
  }

  Future<void> initChat(Chat chat) async {
    final map = <String, User>{};
    final list = <User>[];
    for (final uid in chat.users) {
      final user = await _firestore.users.once(uid: uid);
      if (user != null) {
        map[uid] = user;
        list.add(user);
      }
    }
    subscription =
        _firestore.messages.latest(chatId: chat.chatId).listen((event) {
      if (event != null && event.date.compareTo(timestamp) > 0) {
        if (messages.isEmpty || event.messageId != messages.first.messageId) {
          final copy = [event, ...messages];
          messages = copy;
          setState(() {
            messageStream = Stream.value(messages);
          });
        }
      }
    });
    setState(() {
      this.chat = chat;
      userMap = map;
      userList = list;
    });
    _refresh();
  }

  void _refresh() async {
    final list = await _firestore.messages.first(
      chatId: chat!.chatId,
      start: timestamp,
      limit: 25,
    );
    if (list.isNotEmpty) {
      final copy = [...messages, ...list];
      messages = copy;
      setState(() {
        messageStream = Stream.value(messages);
      });
    }
  }

  void checkMessage() {
    if (chat != null) {
      _firestore.chats.updateUserTimestamp(
        chat: chat!,
        uid: widget.currentUser.uid,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: _title(),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: _body(),
            ),
            _input(),
          ],
        ),
      ),
      endDrawer: Drawer(
        child: SafeArea(
          child: Builder(
            builder: (context) {
              return _drawer();
            },
          ),
        ),
      ),
    );
  }

  Widget _drawer() {
    return Column(
      children: [
        ListTile(
          title: Text('참여자: ${userList.length}'),
          subtitle: Text(
              '개설일: ${chat == null ? '' : DateFormat.yMd().format(chat!.datePublished.toDate())}'),
        ),
        const Divider(),
        Expanded(
          child: ListView.builder(
            itemExtent: 60,
            itemCount: userList.length,
            itemBuilder: (context, index) {
              final user = userList[index];
              return UserListTile(
                key: ValueKey(user),
                user: user,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget? _title() {
    if (widget.group) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(chat?.title ?? '그룹채팅'),
          const SizedBox(width: 8),
          Text(
            '${userList.length}',
            style: const TextStyle(color: Colors.grey),
          ),
        ],
      );
    } else {
      final users = userList.isEmpty ? widget.others : userList;
      final uid = oppositeItem(users, widget.currentUser.uid);
      if (uid == null) {
        return null;
      }
      return Text(userMap[uid]?.username ?? '');
    }
  }

  Widget _body() {
    return StreamBuilder<List<Message>>(
      stream: messageStream,
      builder: (context, snapshot) {
        final messages = snapshot.data ?? [];
        return GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: ListView.builder(
            reverse: true,
            padding: const EdgeInsets.symmetric(vertical: 4),
            itemCount: messages.length,
            itemBuilder: (context, index) {
              if (index == messages.length - 1 && index > latestMore) {
                latestMore = index;
                _fetchMore();
              }
              final message = messages[index];
              return MessageCard(
                key: ValueKey(message.messageId),
                sender: widget.currentUser,
                userMap: userMap,
                prevMessage:
                    index == messages.length - 1 ? null : messages[index + 1],
                message: message,
              );
            },
          ),
        );
      },
    );
  }

  void _fetchMore() async {
    if (chat == null) return;

    final list = await _firestore.messages.next(
      chatId: chat!.chatId,
      limit: 25,
    );
    if (list.isNotEmpty) {
      final copy = [...messages, ...list];
      messages = copy;
      setState(() {
        messageStream = Stream.value(messages);
      });
    }
  }

  Widget _input() {
    return SendTextField(
      user: widget.currentUser,
      hintText: '메시지 보내기...',
      sendText: '보내기',
      onTap: (text) async {
        if (chat == null) {
          final c = await _firestore.chats.create(
            group: widget.group,
            members: {widget.currentUser.uid, ...widget.others!},
          );
          initChat(c);
        }
        _firestore.messages.send(
          chatId: chat!.chatId,
          uid: widget.currentUser.uid,
          text: text,
        );
      },
    );
  }
}
