import 'package:flutter/material.dart';
import 'package:instagram/src/models/comment.dart';
import 'package:instagram/src/models/user.dart';
import 'package:instagram/src/resources/firestore_methods.dart';
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

  @override
  Widget build(BuildContext context) {
    final comment = widget.comment;
    return FutureBuilder<User>(
        future: _firestore.user(uid: comment.uid).first,
        builder: (context, snapshot) {
          final photoUrl = snapshot.data?.photoUrl;
          final username = snapshot.data?.username ?? '';
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CircleAvatar(
                    radius: 16,
                    backgroundImage:
                        photoUrl == null ? null : NetworkImage(photoUrl),
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
                                  style: const TextStyle(
                                      fontWeight: FontWeight.normal)),
                            ],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          DateFormat.yMMMd()
                              .add_jm()
                              .format(comment.datePublished),
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
        });
  }

  void _like() {}
}
