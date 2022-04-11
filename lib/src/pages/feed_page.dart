import 'package:flutter/material.dart';
import 'package:instagram/src/models/post.dart';
import 'package:instagram/src/models/user.dart';
import 'package:instagram/src/pages/add_post_page.dart';
import 'package:instagram/src/resources/firestore_methods.dart';
import 'package:instagram/src/widgets/post_card.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';

class FeedPage extends StatefulWidget {
  const FeedPage({
    Key? key,
    required this.currentUser,
    required this.onShowChat,
  }) : super(key: key);
  final User currentUser;
  final void Function() onShowChat;
  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  late final _firestore = context.read<FirestoreMethods>();

  @override
  Widget build(BuildContext context) {
    final currentUser = widget.currentUser;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Instagram'),
        actions: [
          IconButton(
            onPressed: _addPost,
            icon: const Icon(Icons.add_outlined),
          ),
          IconButton(
            onPressed: widget.onShowChat,
            icon: const Icon(Icons.send),
          ),
        ],
      ),
      body: StreamBuilder<List<Post>>(
        stream: _firestore.posts
            .all(uids: [currentUser.uid, ...currentUser.following]),
        builder: (context, snapshot) {
          final posts = snapshot.data;
          if (posts == null) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (posts.isEmpty) {
            return const Center(
              child: Text('게시물이 없습니다. 팔로잉을 하세요.'),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 4),
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final post = posts[index];
              return PostCard(
                key: ValueKey(post.postId),
                post: post,
                user: currentUser,
              );
            },
            separatorBuilder: (context, index) => const Divider(),
          );
        },
      ),
    );
  }

  void _addPost() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddPostPage(user: widget.currentUser),
      ),
    );
  }
}
