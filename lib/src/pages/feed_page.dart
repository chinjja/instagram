import 'package:cloud_firestore/cloud_firestore.dart';
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
  List<Post>? posts;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    final end = DateTime.now().subtract(const Duration(days: 7));
    final list = <Post>[];
    for (final uid in [
      widget.currentUser.uid,
      ...widget.currentUser.following
    ]) {
      list.addAll(await _firestore.posts.list(
        uid: uid,
        limit: 10,
        end: Timestamp.fromDate(end),
      ));
    }
    list.sort((a, b) => b.date!.compareTo(a.date!));
    setState(() {
      posts = list;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Instagram'),
        actions: [
          IconButton(
            onPressed: posts == null ? null : _addPost,
            icon: const Icon(Icons.add_outlined),
          ),
          IconButton(
            onPressed: widget.onShowChat,
            icon: const Icon(Icons.send),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: posts == null
            ? const Center(child: CircularProgressIndicator())
            : Stack(
                children: [
                  ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    itemCount: posts!.length,
                    itemBuilder: (context, index) {
                      final post = posts![index];
                      return PostCard(
                        key: ValueKey(post.postId),
                        post: post,
                        user: widget.currentUser,
                        onDelete: () {
                          posts?.removeWhere(
                              (element) => element.postId == post.postId);
                          setState(() {});
                        },
                      );
                    },
                    separatorBuilder: (context, index) => const Divider(),
                  ),
                  if (posts!.isEmpty)
                    const Center(
                      child: Text('게시물이 없습니다. 팔로잉을 하세요.'),
                    )
                ],
              ),
      ),
    );
  }

  void _addPost() async {
    final post = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddPostPage(user: widget.currentUser),
      ),
    ) as Post?;
    if (post != null) {
      setState(() {
        posts = [post, ...posts!];
      });
    }
  }
}
