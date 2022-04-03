import 'package:flutter/material.dart';
import 'package:instagram/src/models/post.dart';
import 'package:instagram/src/models/user.dart';
import 'package:instagram/src/pages/add_post_page.dart';
import 'package:instagram/src/resources/firestore_methods.dart';
import 'package:instagram/src/widgets/post_card.dart';
import 'package:provider/provider.dart';

class FeedPage extends StatefulWidget {
  const FeedPage({
    Key? key,
    required this.user,
  }) : super(key: key);
  final User user;
  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  late final _firestore = context.read<FirestoreMethods>();

  @override
  Widget build(BuildContext context) {
    final user = widget.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Instagram'),
        actions: [
          IconButton(
            onPressed: _addPost,
            icon: const Icon(Icons.add_outlined),
          ),
        ],
      ),
      body: StreamBuilder<List<Post>>(
        stream: _firestore.posts([user.uid, ...user.following]),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          final posts = snapshot.data ?? [];
          if (posts.isEmpty) {
            return const Center(
              child: Text('포스트가 없습니다. 팔로잉을 하세요.'),
            );
          }
          return RefreshIndicator(
            onRefresh: () async {
              _refresh();
              return Future.delayed(const Duration(seconds: 1));
            },
            child: ListView.builder(
              itemCount: posts.length,
              itemBuilder: (context, index) {
                final post = posts[index];
                return PostCard(
                  key: ValueKey(post.postId),
                  post: post,
                  user: user,
                );
              },
            ),
          );
        },
      ),
    );
  }

  void _addPost() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddPostPage(user: widget.user),
      ),
    );
  }

  void _refresh() {
    setState(() {});
  }
}
