import 'package:flutter/material.dart';
import 'package:instagram/src/models/chat.dart';
import 'package:instagram/src/models/message.dart';
import 'package:instagram/src/models/user.dart';
import 'package:instagram/src/pages/message_page.dart';
import 'package:instagram/src/resources/firestore_methods.dart';
import 'package:instagram/src/utils/utils.dart';
import 'package:instagram/src/widgets/get_user_list.dart';
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
  List<User>? latestUsers;

  @override
  Widget build(BuildContext context) {
    final chat = widget.chat;
    final user = widget.user;
    final members = chat.members.keys.toList();
    final userStream = members.take(4).toList();
    return StreamBuilder<Message?>(
      stream: _firestore.messages.last(chatId: chat.chatId),
      builder: (context, snapshot) {
        final message = snapshot.data;
        final member = chat.members[user.uid];
        late bool isNewMessage;
        if (message != null && member != null) {
          isNewMessage = message.datePublished.compareTo(member.timestamp) > 0;
        } else {
          isNewMessage = false;
        }
        return GetUserList(
          uids: userStream,
          builder: (context, data) {
            final users = data ?? latestUsers;
            if (users != null) {
              latestUsers = users;
            }
            return InkWell(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: _chatIcon(chat, users),
                    ),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _chatTitle(chat, members, users),
                          const SizedBox(height: 4),
                          Text(
                            message?.text.replaceAll(RegExp('\n'), ' ') ?? '',
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
                              message?.datePublished.toDate() ??
                                  DateTime.now()),
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
          },
        );
      },
    );
  }

  static Widget groupIcon(Chat chat, List<User>? members) {
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
            children: members?.map((e) {
                  final photoUrl = e.photoUrl;
                  return CircleAvatar(
                    radius: 12,
                    backgroundImage: networkImage(photoUrl),
                  );
                }).toList() ??
                [],
          ),
        ),
      );
    }
  }

  Widget _chatIcon(Chat chat, List<User>? users) {
    if (chat.group) {
      return groupIcon(chat, users);
    } else {
      final other = opposite(users, widget.user);
      final photoUrl = other?.photoUrl;
      return CircleAvatar(
        radius: 24,
        backgroundImage: networkImage(photoUrl),
      );
    }
  }

  static Widget groupTitle(
      Chat chat, List<String>? members, List<User>? users) {
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
            '${members?.length ?? 0}',
            style: const TextStyle(color: Colors.grey),
          ),
        ],
      );
    } else {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            users?.map((e) => e.username).join(', ') ?? '',
            maxLines: 1,
            overflow: TextOverflow.fade,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 8),
          Text(
            '${members?.length ?? 0}',
            style: const TextStyle(color: Colors.grey),
          ),
        ],
      );
    }
  }

  Widget _chatTitle(Chat chat, List<String>? members, List<User>? users) {
    if (chat.group) {
      return groupTitle(chat, members, users);
    } else {
      final other = opposite(users, widget.user);
      return Text(
        other?.username ?? '',
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
