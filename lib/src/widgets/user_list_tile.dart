import 'package:flutter/material.dart';
import 'package:instagram/src/models/user.dart';
import 'package:instagram/src/pages/profile_page.dart';

class UserListTile extends StatelessWidget {
  const UserListTile({
    Key? key,
    required this.user,
    this.trailing,
  }) : super(key: key);
  final User user;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final url = user.photoUrl;
    return ListTile(
      key: ValueKey(user.uid),
      leading:
          CircleAvatar(backgroundImage: url == null ? null : NetworkImage(url)),
      title: Text(user.username),
      trailing: trailing,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProfilePage(user: user),
          ),
        );
      },
    );
  }
}
