import 'package:flutter/material.dart';
import 'package:instagram/src/models/comment.dart';
import 'package:instagram/src/models/user.dart';
import 'package:instagram/src/pages/profile_page.dart';
import 'package:instagram/src/resources/firestore_methods.dart';
import 'package:instagram/src/utils/utils.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class CommentCard extends StatefulWidget {
  const CommentCard({
    Key? key,
    required this.comment,
  }) : super(key: key);
  final Comment comment;
  @override
  State<CommentCard> createState() => _CommentCardState();
}

class _CommentCardState extends State<CommentCard> {
  late final _firestore = context.read<FirestoreMethods>();
  User? user;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    final value = await _firestore.users.once(uid: widget.comment.uid);
    setState(() {
      user = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    final photoUrl = user?.photoUrl;
    final username = user?.username ?? '';
    final comment = widget.comment;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: user == null
                ? null
                : () {
                    _showProfile(user!);
                  },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                radius: 16,
                backgroundImage: networkImage(photoUrl),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      text: username + ' ',
                      style: Theme.of(context)
                          .textTheme
                          .bodyText1
                          ?.copyWith(fontWeight: FontWeight.bold),
                      children: [
                        TextSpan(
                            text: comment.text,
                            style:
                                const TextStyle(fontWeight: FontWeight.normal)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    comment.date == null
                        ? ''
                        : DateFormat.yMMMd()
                            .add_jm()
                            .format(comment.date!.toDate()),
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
          IconButton(
            onPressed: _like,
            icon: const Icon(Icons.favorite_outline, size: 16),
          ),
        ],
      ),
    );
  }

  void _like() {}

  void _showProfile(User user) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProfilePage(user: user),
      ),
    );
  }
}
