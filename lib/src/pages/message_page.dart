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
  late final Timestamp timestamp;
  late Chat? chat = widget.chat;
  StreamSubscription? subscription;
  Map<String, User> userMap = {};
  List<User> userList = [];

  @override
  void initState() {
    super.initState();
    if (!widget.group && chat == null) {
      _firestore.chats
          .findDirectChat(uid: widget.currentUser.uid, to: widget.others!.first)
          .first
          .then((value) => setState(() {
                chat = value;
                initChat(chat!);
              }))
          .onError((error, stackTrace) {});
    }
    checkMessage();
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
    timestamp = Timestamp.now();
    subscription?.cancel();
    subscription = _firestore.messages
        .listenLasts(chatId: chat.chatId, timestamp: timestamp);

    for (final uid in chat.members.keys.toList()) {
      final user = await _firestore.users.once(uid: uid);
      if (user != null) {
        userMap[uid] = user;
        userList.add(user);
      }
    }
  }

  void checkMessage() {
    if (chat != null) {
      _firestore.chats.checkMessage(chat: chat!, uid: widget.currentUser.uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    final members = chat?.members.keys.toList();
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: _title(members),
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
          title: Text('참여자: ${userMap.length}'),
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

  Widget? _title(List<String>? members) {
    if (widget.group) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(chat?.title ?? '그룹채팅'),
          const SizedBox(width: 8),
          Text(
            '${members?.length ?? 0}',
            style: const TextStyle(color: Colors.grey),
          ),
        ],
      );
    } else {
      final users = members == null ? widget.others : members.toList();
      final uid = oppositeItem(users, widget.currentUser.uid);
      if (uid == null) {
        return null;
      }
      return Text(userMap[uid]?.username ?? '');
    }
  }

  Widget _body() {
    return StreamBuilder<List<Message>>(
      stream: chat == null
          ? null
          : Rx.combineLatest2(
              _firestore.messages.lasts(chatId: chat!.chatId),
              _firestore.messages.all(
                chatId: chat!.chatId,
                start: timestamp,
                limit: 25,
              ),
              (List<Message> a, List<Message> b) => [...a, ...b],
            ),
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
          setState(() {
            chat = c;
            initChat(chat!);
          });
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
