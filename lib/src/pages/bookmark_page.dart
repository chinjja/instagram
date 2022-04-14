import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:instagram/src/models/bookmark.dart';
import 'package:instagram/src/models/user.dart';
import 'package:instagram/src/pages/post_list_page.dart';
import 'package:instagram/src/resources/firestore_methods.dart';
import 'package:instagram/src/utils/utils.dart';
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
  List<Bookmark>? bookmarks;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    final list = await _firestore.bookmarks.list(
      uid: widget.currentUser.uid,
      limit: 15,
    );
    setState(() {
      bookmarks = list;
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = widget.currentUser;
    return Scaffold(
      appBar: AppBar(
        title: const Text('저장됨'),
        actions: [
          if (kIsWeb)
            IconButton(onPressed: _refresh, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: SafeArea(
        child: bookmarks == null
            ? const Center(child: CircularProgressIndicator())
            : Stack(
                children: [
                  RefreshIndicator(
                    onRefresh: _refresh,
                    child: GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithMaxCrossAxisExtent(
                        mainAxisSpacing: 1,
                        crossAxisSpacing: 1,
                        maxCrossAxisExtent: 150,
                      ),
                      itemCount: bookmarks!.length,
                      itemBuilder: (context, index) {
                        final bookmark = bookmarks![index];
                        return AspectRatio(
                          key: ValueKey(bookmark.postId),
                          aspectRatio: 1,
                          child: GestureDetector(
                            onTap: () async {
                              final post = await _firestore.posts
                                  .get(postId: bookmark.postId);
                              if (post != null) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => PostListPage(
                                      user: currentUser,
                                      posts: [post],
                                    ),
                                  ),
                                );
                              } else {
                                showSnackbar(context, '해당 포스트가 조재하지 않습니다.');
                              }
                            },
                            child: Image.network(
                              bookmark.postUrl,
                              fit: BoxFit.cover,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  if (bookmarks!.isEmpty)
                    const Center(
                      child: Text('북마크가 없습니다.'),
                    )
                ],
              ),
      ),
    );
  }
}
