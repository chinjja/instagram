import 'package:flutter/material.dart';
import 'package:instagram/src/repo/models/model.dart';
import 'package:instagram/src/user/view/user_page.dart';
import 'package:instagram/src/utils/utils.dart';
import 'package:intl/intl.dart';

class CommentBaseCard extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: user == null
                ? null
                : () {
                    _showProfile(context, user!);
                  },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                radius: 16,
                backgroundImage: networkImage(user?.photoUrl),
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
                      text: '${user?.username ?? ''} ',
                      style: Theme.of(context)
                          .textTheme
                          .bodyLarge
                          ?.copyWith(fontWeight: FontWeight.bold),
                      children: [
                        TextSpan(
                            text: text,
                            style:
                                const TextStyle(fontWeight: FontWeight.normal)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat.yMMMd().add_jm().format(date),
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }

  void _showProfile(BuildContext context, User user) async {
    Navigator.push(
      context,
      UserPage.route(user: user),
    );
  }
}
