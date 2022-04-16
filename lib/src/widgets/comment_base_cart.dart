import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:instagram/src/models/user.dart';
import 'package:instagram/src/pages/profile_page.dart';
import 'package:instagram/src/utils/utils.dart';
import 'package:intl/intl.dart';

class CommentBaseCard extends StatefulWidget {
  const CommentBaseCard({
    Key? key,
    required this.user,
    required this.text,
    required this.date,
    this.trailing,
    this.onTap,
  }) : super(key: key);
  final User? user;
  final String text;
  final DateTime date;
  final Widget? trailing;
  final void Function()? onTap;
  @override
  State<CommentBaseCard> createState() => _CommentBaseCardState();
}

class _CommentBaseCardState extends State<CommentBaseCard> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: widget.user == null
                ? null
                : () {
                    _showProfile(widget.user!);
                  },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                radius: 16,
                backgroundImage: networkImage(widget.user?.photoUrl),
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
                      text: (widget.user?.username ?? '') + ' ',
                      style: Theme.of(context)
                          .textTheme
                          .bodyText1
                          ?.copyWith(fontWeight: FontWeight.bold),
                      children: [
                        TextSpan(
                            text: widget.text,
                            style:
                                const TextStyle(fontWeight: FontWeight.normal)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat.yMMMd().add_jm().format(widget.date),
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
          if (widget.trailing != null) widget.trailing!,
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
