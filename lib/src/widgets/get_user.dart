import 'package:flutter/material.dart';
import 'package:instagram/src/models/user.dart';
import 'package:instagram/src/resources/firestore_methods.dart';
import 'package:provider/provider.dart';

typedef GetUserBuilder = Widget Function(
    BuildContext context, User? currentUser);

class GetUser extends StatelessWidget {
  const GetUser({Key? key, required this.uid, required this.builder})
      : super(key: key);
  final String? uid;
  final GetUserBuilder builder;

  @override
  Widget build(BuildContext context) {
    late final _firestore = context.read<FirestoreMethods>();

    return StreamBuilder<User>(
      initialData: uid == null ? null : _firestore.users.get(uid: uid!),
      stream: uid == null ? null : _firestore.users.at(uid: uid!),
      builder: (context, snapshot) {
        final currentUser = snapshot.data;
        return builder(context, currentUser);
      },
    );
  }
}
