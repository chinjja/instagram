import 'package:flutter/material.dart';
import 'package:instagram/src/models/user.dart';
import 'package:instagram/src/resources/firestore_methods.dart';
import 'package:provider/provider.dart';

typedef GetUserListBuilder = Widget Function(
    BuildContext context, List<User>? users);

class GetUserList extends StatelessWidget {
  const GetUserList({Key? key, required this.uids, required this.builder})
      : super(key: key);
  final List<String>? uids;
  final GetUserListBuilder builder;

  @override
  Widget build(BuildContext context) {
    final _firestore = context.read<FirestoreMethods>();
    if (uids == null) {
      return builder(context, null);
    }
    if (uids!.isEmpty) {
      return builder(context, []);
    }
    return StreamBuilder<List<User>>(
      initialData: uids!
          .map((e) => _firestore.users.get(uid: e))
          .where((e) => e != null)
          .cast<User>()
          .toList(),
      stream: _firestore.users.all(uids: uids!),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return builder(context, null);
        }
        final users = snapshot.data ?? [];
        return builder(context, users);
      },
    );
  }
}
