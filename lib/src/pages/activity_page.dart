import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:instagram/src/repo/models/model.dart';
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

  List<Activity>? activities;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    final list = await _firestore.activities
        .list(toUid: widget.currentUser.uid, limit: 15);
    setState(() {
      activities = list;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('활동'),
        actions: [
          if (kIsWeb)
            IconButton(onPressed: _refresh, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: SafeArea(
        child: activities == null
            ? const Center(child: CircularProgressIndicator())
            : Stack(
                children: [
                  RefreshIndicator(
                    onRefresh: _refresh,
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      itemCount: activities!.length,
                      itemBuilder: (context, index) {
                        final activity =
                            activities![activities!.length - index - 1];
                        return Dismissible(
                          key: UniqueKey(),
                          onDismissed: (dir) {
                            _firestore.activities
                                .delete(activityId: activity.activityId);
                            setState(() {
                              activities?.removeAt(index);
                            });
                          },
                          child: ActivityCard(
                            activity: activity,
                          ),
                        );
                      },
                      separatorBuilder: (context, index) => const Divider(),
                    ),
                  ),
                  if (activities!.isEmpty)
                    const Center(
                      child: Text('활동이 없습니다.'),
                    )
                ],
              ),
      ),
    );
  }
}
