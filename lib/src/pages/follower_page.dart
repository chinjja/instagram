import 'package:flutter/material.dart';
import 'package:instagram/src/repo/models/user.dart';
import 'package:instagram/src/resources/firestore_methods.dart';
import 'package:instagram/src/widgets/user_list_tile.dart';
import 'package:provider/provider.dart';

class FollowPage extends StatefulWidget {
  const FollowPage({
    Key? key,
    required this.user,
    required this.followers,
    required this.following,
    required this.showFollows,
  }) : super(key: key);
  final User user;
  final List<String> followers;
  final List<String> following;
  final bool showFollows;

  @override
  State<FollowPage> createState() => _FollowPageState();
}

class _FollowPageState extends State<FollowPage> {
  late final _firestore = context.read<FirestoreMethods>();
  List<User>? users;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    final list = <User>[];
    for (final uid in {...widget.followers, ...widget.following}) {
      final user = await _firestore.users.get(uid: uid);
      if (user != null) {
        list.add(user);
      }
    }
    setState(() {
      users = list;
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
              Tab(text: '${widget.followers.length} 팔로워'),
              Tab(text: '${widget.following.length} 팔로잉'),
            ],
          ),
        ),
        body: TabBarView(children: [
          _page(widget.followers.toSet(), users ?? [], '팔로워가 없습니다.'),
          _page(widget.following.toSet(), users ?? [], '팔로잉이 없습니다.'),
        ]),
      ),
    );
  }

  Widget _page(Set<String> uidList, List<User> data, String emptyMessage) {
    if (uidList.isEmpty) {
      return Center(
        child: Text(emptyMessage),
      );
    }

    final users = <User>[];
    for (final user in data) {
      if (uidList.contains(user.uid)) {
        users.add(user);
      }
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 4),
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index];
        return UserListTile(
          key: ValueKey(user.uid),
          user: user,
        );
      },
    );
  }
}
