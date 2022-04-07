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
    required this.user,
  }) : super(key: key);
  final User user;

  @override
  State<BookmarkPage> createState() => _BookmarkPageState();
}

class _BookmarkPageState extends State<BookmarkPage>
    with AutomaticKeepAliveClientMixin {
  late final _firestore = context.read<FirestoreMethods>();
  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      appBar: AppBar(title: const Text('저장됨')),
      body: StreamBuilder<List<Bookmark>>(
        stream: _firestore.bookmarks(uid: widget.user.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          final bookmarks = snapshot.data ?? [];
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
                      stream: _firestore.post(postId: bookmark.postId),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        final post = snapshot.data;
                        if (post == null) {
                          return const Center(
                            child: Text('게시물이 삭제되었습니다.'),
                          );
                        }
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PostListPage(
                                  user: widget.user,
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
                      }),
                );
              },
            ),
          );
        },
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
