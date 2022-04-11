import 'package:flutter/material.dart';
import 'package:instagram/src/models/bookmark.dart';
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
      body: StreamBuilder<List<Bookmark>>(
        stream: _firestore.bookmarks.all(uid: currentUser.uid),
        builder: (context, snapshot) {
          final bookmarks = snapshot.data;
          if (bookmarks == null) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (bookmarks.isEmpty) {
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
              itemCount: bookmarks.length,
              itemBuilder: (context, index) {
                final bookmark = bookmarks[index];
                return AspectRatio(
                  key: ValueKey(bookmark.postId),
                  aspectRatio: 1,
                  child: StreamBuilder<Post>(
                    stream: _firestore.posts.at(postId: bookmark.postId),
                    builder: (context, snapshot) {
                      final post = snapshot.data;
                      if (post == null) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PostListPage(
                                user: currentUser,
                                posts: [post],
                              ),
                            ),
                          );
                        },
                        child: Image.network(
                          post.postUrl,
                          fit: BoxFit.cover,
                        ),
                      );
                    },
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
