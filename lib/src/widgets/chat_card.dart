import 'package:flutter/material.dart';
import 'package:instagram/src/models/chat.dart';
import 'package:instagram/src/models/chat_user.dart';
import 'package:instagram/src/models/message.dart';
import 'package:instagram/src/models/user.dart';
import 'package:instagram/src/pages/message_page.dart';
import 'package:instagram/src/resources/firestore_methods.dart';
import 'package:instagram/src/utils/utils.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';

class ChatCard extends StatefulWidget {
  const ChatCard({
    Key? key,
    required this.chat,
    required this.user,
  }) : super(key: key);
  final Chat chat;
  final User user;

  @override
  State<ChatCard> createState() => _ChatCardState();
}

class _ChatCardState extends State<ChatCard> {
  late final _firestore = context.read<FirestoreMethods>();

  @override
  Widget build(BuildContext context) {
    final chat = widget.chat;
    final user = widget.user;
    final members = chat.users;
    final mesageStream = _firestore.messages.last(chatId: chat.chatId);
    final userTimestamp =
        _firestore.chats.user(chatId: chat.chatId, uid: user.uid);
    final usersStream = _firestore.users.all(uids: members.take(4).toList());
    return StreamBuilder<ChatUser>(
        stream: userTimestamp,
        builder: (context, snapshot) {
          final chatUser = snapshot.data;
          return StreamBuilder<Message?>(
            stream: mesageStream,
            builder: (context, snapshot) {
              final message = snapshot.data;
              late bool isNewMessage;
              if (message != null && chatUser != null) {
                isNewMessage = message.date.compareTo(chatUser.date) > 0;
              } else {
                isNewMessage = false;
              }
              return StreamBuilder<List<User>>(
                  stream: usersStream,
                  builder: (context, snapshot) {
                    final users = snapshot.data ?? [];
                    final userMap = <String, User>{};
                    for (final user in users) {
                      userMap[user.uid] = user;
                    }

                    return InkWell(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: _chatIcon(chat, members, userMap),
                            ),
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _chatTitle(chat, members, userMap),
                                  const SizedBox(height: 4),
                                  Text(
                                    message?.text
                                            .replaceAll(RegExp('\n'), ' ') ??
                                        '',
                                    maxLines: 1,
                                    overflow: TextOverflow.fade,
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  DateFormat.yMd().add_jm().format(
                                      message?.date.toDate() ?? DateTime.now()),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                                Visibility(
                                  visible: isNewMessage,
                                  maintainState: true,
                                  maintainAnimation: true,
                                  maintainSize: true,
                                  child: const Chip(
                                    label: Text('New'),
                                    backgroundColor: Colors.redAccent,
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                      onTap: () {
                        _joinChat(chat);
                      },
                    );
                  });
            },
          );
        });
  }

  Widget groupIcon(Chat chat, List<String> users, Map<String, User> map) {
    if (chat.photoUrl != null) {
      final photoUrl = chat.photoUrl!;
      return CircleAvatar(
        radius: 24,
        backgroundImage: networkImage(photoUrl),
      );
    } else {
      return SizedBox(
        width: 48,
        height: 48,
        child: Center(
          child: Wrap(
            children: users.take(4).map((uid) => map[uid]).map((user) {
              return CircleAvatar(
                radius: 12,
                backgroundImage: networkImage(user?.photoUrl),
              );
            }).toList(),
          ),
        ),
      );
    }
  }

  Widget _chatIcon(Chat chat, List<String> users, Map<String, User> map) {
    if (chat.group) {
      return groupIcon(chat, users, map);
    } else {
      final uid = oppositeItem(users, widget.user.uid);
      final user = map[uid];
      return CircleAvatar(
        radius: 24,
        backgroundImage: networkImage(user?.photoUrl),
      );
    }
  }

  Widget groupTitle(Chat chat, List<String> users, Map<String, User> map) {
    if (chat.title != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            chat.title!,
            maxLines: 1,
            overflow: TextOverflow.fade,
          ),
          const SizedBox(width: 8),
          Text(
            '${users.length}',
            style: const TextStyle(color: Colors.grey),
          ),
        ],
      );
    } else {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            users
                .take(4)
                .map((uid) => map[uid])
                .where((user) => user != null)
                .join(', '),
            maxLines: 1,
            overflow: TextOverflow.fade,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 8),
          Text(
            '${users.length}',
            style: const TextStyle(color: Colors.grey),
          ),
        ],
      );
    }
  }

  Widget _chatTitle(Chat chat, List<String> users, Map<String, User> map) {
    if (chat.group) {
      return groupTitle(chat, users, map);
    } else {
      final uid = oppositeItem(users, widget.user.uid);
      final user = map[uid];
      return Text(
        user?.username ?? '',
        maxLines: 1,
        overflow: TextOverflow.fade,
        style: const TextStyle(fontWeight: FontWeight.bold),
      );
    }
  }

  void _joinChat(Chat chat) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MessagePage(
          group: chat.group,
          chat: chat,
          currentUser: widget.user,
          autoFocus: true,
        ),
      ),
    );
  }
}
