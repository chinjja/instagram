import 'package:flutter/material.dart';
import 'package:instagram/src/models/activity.dart';
import 'package:instagram/src/models/comment.dart';
import 'package:instagram/src/models/user.dart';
import 'package:instagram/src/resources/firestore_methods.dart';
import 'package:instagram/src/widgets/activity_cart.dart';
import 'package:provider/provider.dart';

class ActivityPage extends StatefulWidget {
  const ActivityPage({
    Key? key,
    required this.user,
  }) : super(key: key);
  final User user;

  @override
  State<ActivityPage> createState() => _ActivityPageState();
}

class _ActivityPageState extends State<ActivityPage>
    with AutomaticKeepAliveClientMixin {
  late final _firestore = context.read<FirestoreMethods>();

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(title: const Text('활동')),
      body: SafeArea(
        child: StreamBuilder<List<Activity>>(
            stream: _firestore.activities(to: widget.user.uid),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              final activities = snapshot.data ?? [];
              if (activities.isEmpty) {
                return const Center(
                  child: Text('활동이 없습니다.'),
                );
              }
              return ListView.separated(
                itemCount: activities.length,
                itemBuilder: (context, index) {
                  final activity = activities[index];
                  return ActivityCard(
                    key: ValueKey(
                      activity is Comment
                          ? activity.commentId
                          : activity.runtimeType.toString() + activity.uid,
                    ),
                    activity: activity,
                  );
                },
                separatorBuilder: (context, index) => const Divider(),
              );
            }),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
