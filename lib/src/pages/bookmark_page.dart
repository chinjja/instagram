import 'package:flutter/material.dart';
import 'package:instagram/src/models/bookmarks.dart';
import 'package:instagram/src/models/post.dart';
import 'package:instagram/src/models/user.dart';
import 'package:instagram/src/pages/post_list_page.dart';
import 'package:instagram/src/resources/firestore_methods.dart';
import 'package:provider/provider.dart';

class BookmarkPage extends StatefulWidget {
  const BookmarkPage({
    Key? key,
    required this.currentUser,
  }) : super(key: key);
  final User currentUser;

  @override
  State<BookmarkPage> createState() => _BookmarkPageState();
}

class _BookmarkPageState extends State<BookmarkPage> {
  late final _firestore = context.read<FirestoreMethods>();

  @override
  Widget build(BuildContext context) {
    final currentUser = widget.currentUser;
    return Scaffold(
      appBar: AppBar(title: const Text('저장됨')),
      body: StreamBuilder<Bookmarks>(
        stream: _firestore.users.bookmarks(uid: currentUser.uid),
        builder: (context, snapshot) {
          final bookmarks = snapshot.data;
          final posts = bookmarks?.posts.values.toList();
          if (posts == null) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (posts.isEmpty) {
            return const Center(
              child: Text('저장된 포스트가 없습니다.'),
            );
          }
          return SafeArea(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                mainAxisSpacing: 1,
                crossAxisSpacing: 1,
                maxCrossAxisExtent: 150,
              ),
              itemCount: posts.length,
              itemBuilder: (context, index) {
                final post = posts[index];
                return AspectRatio(
                  key: ValueKey(post.postId),
                  aspectRatio: 1,
                  child: GestureDetector(
                    onTap: () async {
                      final obj = await _firestore.posts
                          .at(uid: bookmarks!.id, postId: post.postId)
                          .first;
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PostListPage(
                            user: currentUser,
                            posts: [obj],
                            bookmarks: bookmarks,
                          ),
                        ),
                      );
                    },
                    child: Image.network(
                      post.postUrl,
                      fit: BoxFit.cover,
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
