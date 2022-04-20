import 'package:flutter/material.dart';
import 'package:instagram/src/repo/models/model.dart';
import 'package:instagram/src/pages/profile_page.dart';
import 'package:instagram/src/resources/firestore_methods.dart';
import 'package:instagram/src/utils/utils.dart';
import 'package:provider/provider.dart';

class MessageCard extends StatefulWidget {
  const MessageCard({
    Key? key,
    required this.sender,
    required this.userMap,
    required this.prevMessage,
    required this.message,
  }) : super(key: key);
  final User sender;
  final Map<String, User> userMap;
  final Message? prevMessage;
  final Message message;
  @override
  State<MessageCard> createState() => _MessageCardState();
}

class _MessageCardState extends State<MessageCard> {
  late final _firestore = context.read<FirestoreMethods>();

  @override
  Widget build(BuildContext context) {
    final prevMessage = widget.prevMessage;
    final message = widget.message;

    final user = widget.userMap[message.uid];
    final photoUrl = user?.photoUrl;
    final username = user?.username ?? '';
    final isMe = message.uid == widget.sender.uid;
    final showDeco =
        !isMe && (prevMessage == null || prevMessage.uid != message.uid);

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
                onTap: user == null
                    ? null
                    : () {
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
                      child: Text(message.text),
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
      MaterialPageRoute(
        builder: (context) => ProfilePage(user: user),
      ),
    );
  }
}
