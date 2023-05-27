import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:instagram/src/auth/bloc/auth_cubit.dart';
import 'package:instagram/src/chat/models/chat_data.dart';
import 'package:instagram/src/repo/models/model.dart';
import 'package:instagram/src/utils/utils.dart';
import 'package:intl/intl.dart';

class ChatCard extends StatelessWidget {
  const ChatCard({
    Key? key,
    required this.data,
    required this.onTap,
  }) : super(key: key);
  final ChatData data;
  final void Function() onTap;

  @override
  Widget build(BuildContext context) {
    final auth = context.select((AuthCubit cubit) => cubit.user);
    final userMap = <String, User>{};
    for (final user in data.members) {
      userMap[user.uid] = user;
    }

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: _chatIcon(data.chat, auth, userMap),
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _chatTitle(data.chat, auth, userMap),
                  const SizedBox(height: 4),
                  Text(
                    data.lastMessage.replaceAll(RegExp('\n'), ' '),
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
                  DateFormat.yMd().add_jm().format(data.date),
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                Visibility(
                  visible: data.isNew,
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
    );
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

  Widget _chatIcon(Chat chat, User auth, Map<String, User> map) {
    if (chat.group) {
      return groupIcon(chat, chat.users, map);
    } else {
      final uid = oppositeItem(chat.users, auth.uid);
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
                .cast<User>()
                .map((user) => user.username)
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

  Widget _chatTitle(Chat chat, User auth, Map<String, User> map) {
    if (chat.group) {
      return groupTitle(chat, chat.users, map);
    } else {
      final uid = oppositeItem(chat.users, auth.uid);
      final user = map[uid];
      return Text(
        user?.username ?? '',
        maxLines: 1,
        overflow: TextOverflow.fade,
        style: const TextStyle(fontWeight: FontWeight.bold),
      );
    }
  }
}
