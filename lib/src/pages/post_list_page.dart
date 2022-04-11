import 'package:flutter/material.dart';
import 'package:instagram/src/models/post.dart';
import 'package:instagram/src/models/user.dart';
import 'package:instagram/src/widgets/post_card.dart';

class PostListPage extends StatelessWidget {
  const PostListPage({
    Key? key,
    required this.user,
    required this.posts,
  }) : super(key: key);
  final User user;
  final List<Post> posts;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: ListView.separated(
        itemCount: posts.length,
        itemBuilder: (context, index) {
          final post = posts[index];
          return PostCard(
            key: ValueKey(post.postId),
            post: post,
            user: user,
          );
        },
        separatorBuilder: (context, index) => const Divider(),
      ),
    );
  }
}
