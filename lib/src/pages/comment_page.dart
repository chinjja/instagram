import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:instagram/src/models/comment.dart';
import 'package:instagram/src/models/comments.dart';
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

  @override
  Widget build(BuildContext context) {
    final post = widget.post;

    return Scaffold(
      appBar: AppBar(
        title: const Text('댓글'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder<Comments>(
                  stream: _firestore.posts.comments(
                    postId: post.postId,
                  ),
                  builder: (context, snapshot) {
                    final comments = snapshot.data?.list;
                    if (comments == null) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                    return ListView.builder(
                      itemCount: comments.length,
                      itemBuilder: (context, index) {
                        final comment = comments[index];
                        return CommentCard(
                          key: ValueKey(comment.commentId),
                          comment: comment,
                        );
                      },
                    );
                  }),
            ),
            SendTextField(
              user: widget.user,
              hintText: '댓글 달기...',
              sendText: '게시',
              onTap: (text) {
                _firestore.posts.comment(
                  post: widget.post,
                  uid: widget.user.uid,
                  text: text,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
