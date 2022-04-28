import 'package:flutter/material.dart';
import 'package:instagram/src/repo/models/user.dart';
import 'package:instagram/src/resources/firestore_methods.dart';
import 'package:instagram/src/widgets/user_list_tile.dart';
import 'package:provider/provider.dart';

class FollowPage extends StatefulWidget {
  const FollowPage({
    Key? key,
    required this.user,
    required this.showFollows,
  }) : super(key: key);
  final User user;
  final bool showFollows;

  @override
  State<FollowPage> createState() => _FollowPageState();
}

class _FollowPageState extends State<FollowPage> {
  late final _firestore = context.read<FirestoreMethods>();
  List<User> following = [];
  List<User> followers = [];

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    final followingList = <User>[];
    for (final uid in widget.user.following) {
      final user = await _firestore.users.get(uid: uid);
      if (user != null) {
        followingList.add(user);
      }
    }
    final followersList = <User>[];
    for (final uid in await _firestore.users
        .fetchFollowers(uid: widget.user.uid, limit: 20)) {
      final user = await _firestore.users.get(uid: uid);
      if (user != null) {
        followersList.add(user);
      }
    }
    setState(() {
      following = followingList;
      followers = followersList;
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: widget.showFollows ? 0 : 1,
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.user.username),
          bottom: TabBar(
            tabs: [
              Tab(text: '${followers.length} 팔로워'),
              Tab(text: '${following.length} 팔로잉'),
            ],
          ),
        ),
        body: TabBarView(children: [
          _page(followers, '팔로워가 없습니다.'),
          _page(following, '팔로잉이 없습니다.'),
        ]),
      ),
    );
  }

  Widget _page(List<User> data, String emptyMessage) {
    if (data.isEmpty) {
      return Center(
        child: Text(emptyMessage),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 4),
      itemCount: data.length,
      itemBuilder: (context, index) {
        final user = data[index];
        return UserListTile(
          key: ValueKey(user.uid),
          user: user,
        );
      },
    );
  }
}
