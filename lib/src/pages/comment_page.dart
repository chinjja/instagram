import 'package:flutter/material.dart';
import 'package:instagram/src/models/comment.dart';
import 'package:instagram/src/models/post.dart';
import 'package:instagram/src/models/user.dart';
import 'package:instagram/src/resources/firestore_methods.dart';
import 'package:instagram/src/widgets/comment_cart.dart';
import 'package:instagram/src/widgets/send_text_field.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';

class CommentPage extends StatefulWidget {
  const CommentPage({
    Key? key,
    required this.post,
    required this.user,
    required this.autoFocus,
  }) : super(key: key);
  final Post post;
  final User user;
  final bool autoFocus;
  @override
  State<CommentPage> createState() => _CommentPageState();
}

class _CommentPageState extends State<CommentPage> {
  late final _firestore = context.read<FirestoreMethods>();
  late final post = widget.post;

  List<Comment> comments = [];

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    final list = await _firestore.comments.list(
      postId: post.postId,
      limit: 10,
    );
    setState(() {
      comments = list;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('댓글'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: comments.isEmpty
                  ? const Center(
                      child: Text('댓글이 없습니다.'),
                    )
                  : ListView.builder(
                      itemCount: comments.length,
                      itemBuilder: (context, index) {
                        final comment = comments[index];
                        return CommentCard(
                          key: ValueKey(comment.commentId),
                          comment: comment,
                        );
                      },
                    ),
            ),
            SendTextField(
              user: widget.user,
              hintText: '댓글 달기...',
              sendText: '게시',
              onTap: (text) async {
                final comment = await _firestore.posts.addComment(
                  post: widget.post,
                  uid: widget.user.uid,
                  text: text,
                );
                setState(() {
                  comments.add(comment);
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
