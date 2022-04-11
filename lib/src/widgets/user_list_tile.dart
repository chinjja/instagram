import 'package:flutter/material.dart';
import 'package:instagram/src/models/user.dart';
import 'package:instagram/src/pages/profile_page.dart';
import 'package:instagram/src/utils/utils.dart';

class UserListTile extends StatelessWidget {
  const UserListTile({
    Key? key,
    required this.user,
    this.trailing,
    this.onTap,
  }) : super(key: key);
  final User user;
  final Widget? trailing;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    final url = user.photoUrl;
    return ListTile(
      key: ValueKey(user.uid),
      leading: CircleAvatar(
        radius: 20,
        backgroundImage: networkImage(url),
      ),
      title: Text(user.username),
      subtitle: Text(user.state ?? ''),
      trailing: trailing,
      onTap: onTap ??
          () {
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
