import 'package:flutter/material.dart';
import 'package:instagram/src/models/activities.dart';
import 'package:instagram/src/models/activity.dart';
import 'package:instagram/src/models/comment.dart';
import 'package:instagram/src/models/user.dart';
import 'package:instagram/src/resources/firestore_methods.dart';
import 'package:instagram/src/widgets/activity_cart.dart';
import 'package:provider/provider.dart';

class ActivityPage extends StatefulWidget {
  const ActivityPage({
    Key? key,
    required this.currentUser,
  }) : super(key: key);
  final User currentUser;

  @override
  State<ActivityPage> createState() => _ActivityPageState();
}

class _ActivityPageState extends State<ActivityPage> {
  late final _firestore = context.read<FirestoreMethods>();

  @override
  Widget build(BuildContext context) {
    final currentUser = widget.currentUser;
    return Scaffold(
      appBar: AppBar(title: const Text('활동')),
      body: SafeArea(
        child: StreamBuilder<Activities>(
            stream: _firestore.users.activities(uid: currentUser.uid),
            builder: (context, snapshot) {
              final activities = snapshot.data?.list;
              if (activities == null) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              if (activities.isEmpty) {
                return const Center(
                  child: Text('활동이 없습니다.'),
                );
              }
              return ListView.separated(
                padding: const EdgeInsets.symmetric(vertical: 4),
                itemCount: activities.length,
                itemBuilder: (context, index) {
                  final activity = activities[activities.length - index - 1];
                  return ActivityCard(
                    key: ValueKey('$index'),
                    activity: activity,
                  );
                },
                separatorBuilder: (context, index) => const Divider(),
              );
            }),
      ),
    );
  }
}
