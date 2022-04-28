import 'package:flutter/material.dart';
import 'package:instagram/src/auth/bloc/auth_cubit.dart';
import 'package:instagram/src/message/models/message_data.dart';
import 'package:instagram/src/repo/models/model.dart';
import 'package:instagram/src/user/view/user_page.dart';
import 'package:instagram/src/utils/utils.dart';
import 'package:provider/provider.dart';

class MessageCard extends StatefulWidget {
  const MessageCard({
    Key? key,
    required this.prevMessage,
    required this.message,
  }) : super(key: key);
  final MessageData? prevMessage;
  final MessageData message;
  @override
  State<MessageCard> createState() => _MessageCardState();
}

class _MessageCardState extends State<MessageCard> {
  @override
  Widget build(BuildContext context) {
    final auth = context.select((AuthCubit cubit) => cubit.user);

    final prevMessage = widget.prevMessage;
    final message = widget.message;

    final user = message.user;
    final photoUrl = user.photoUrl;
    final username = user.username;
    final isMe = message.user == auth;
    final showDeco =
        !isMe && (prevMessage == null || prevMessage.user != message.user);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 50,
            child: Visibility(
              visible: showDeco,
              child: GestureDetector(
                onTap: () {
                  _showProfile(user);
                },
                child: CircleAvatar(
                  radius: 18,
                  backgroundImage: networkImage(photoUrl),
                ),
              ),
            ),
          ),
          Expanded(
            child: Align(
              alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Visibility(
                    visible: showDeco,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 2, bottom: 2),
                      child: Text(username),
                    ),
                  ),
                  Padding(
                    padding: isMe
                        ? const EdgeInsets.only(left: 60)
                        : const EdgeInsets.only(right: 60),
                    child: Container(
                      decoration: ShapeDecoration(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        color: Colors.black,
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      child: Text(message.message.text),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showProfile(User user) async {
    Navigator.push(
      context,
      UserPage.route(user: user),
    );
  }
}
