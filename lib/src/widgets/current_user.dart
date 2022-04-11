import 'package:flutter/material.dart';
import 'package:instagram/src/resources/auth_methods.dart';
import 'package:instagram/src/widgets/get_user.dart';
import 'package:provider/provider.dart';

class CurrentUser extends StatelessWidget {
  const CurrentUser({Key? key, required this.builder}) : super(key: key);
  final GetUserBuilder builder;

  @override
  Widget build(BuildContext context) {
    late final _auth = context.read<AuthMethods>();
    return GetUser(uid: _auth.currentUid, builder: builder);
  }
}
