import 'package:flutter/material.dart';
import 'package:instagram/src/models/user.dart';
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

  @override
  Widget build(BuildContext context) {
    final user = widget.user;

    return DefaultTabController(
      initialIndex: widget.showFollows ? 0 : 1,
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.user.username),
          bottom: TabBar(
            tabs: [
              Tab(text: '${user.followers.length} 팔로워'),
              Tab(text: '${user.following.length} 팔로잉'),
            ],
          ),
        ),
        body: TabBarView(children: [
          _page(user.followers, '팔로워가 없습니다.'),
          _page(user.following, '팔로잉이 없습니다.'),
        ]),
      ),
    );
  }

  Widget _page(List<String> uidList, String emptyMessage) {
    if (uidList.isEmpty) {
      return Center(
        child: Text(emptyMessage),
      );
    }
    return StreamBuilder<List<User>>(
        stream: _firestore.usersByUidList(uidList),
        builder: (context, snapshot) {
          final users = snapshot.data;
          if (users == null) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              return UserListTile(
                key: ValueKey(user.uid),
                user: user,
              );
            },
          );
        });
  }
}
