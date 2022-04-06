import 'package:flutter/material.dart';
import 'package:instagram/src/models/comment.dart';
import 'package:instagram/src/models/post.dart';
import 'package:instagram/src/models/user.dart';
import 'package:instagram/src/resources/firestore_methods.dart';
import 'package:instagram/src/widgets/comment_cart.dart';
import 'package:provider/provider.dart';

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
  final _text = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final post = widget.post;

    return Scaffold(
      appBar: AppBar(
        title: const Text('댓글'),
        actions: [
          IconButton(onPressed: _message, icon: const Icon(Icons.send))
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder<List<Comment>>(
                  stream: _firestore.comments(post),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                    final comments = snapshot.data ?? [];
                    return ListView.builder(
                      itemCount: comments.length,
                      itemBuilder: (context, index) {
                        final comment = comments[index];
                        return CommentCard(
                          key: ValueKey(comment.id),
                          comment: comment,
                        );
                      },
                    );
                  }),
            ),
            _bottomTextField(),
          ],
        ),
      ),
    );
  }

  Widget _bottomTextField() {
    return StatefulBuilder(builder: (context, setState) {
      return Padding(
        padding: const EdgeInsets.only(
          left: 12,
          right: 12,
          bottom: 4,
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundImage: widget.user.photoUrl == null
                  ? null
                  : NetworkImage(widget.user.photoUrl!),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: _text,
                onChanged: (text) {
                  setState(() {});
                },
                autofocus: widget.autoFocus,
                decoration: InputDecoration(
                  hintText: '댓글 달기...',
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                  ),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(100)),
                  suffix: InkWell(
                    child: Text(
                      '게시',
                      style: TextStyle(
                        color: _text.text.isEmpty ? Colors.grey : Colors.blue,
                      ),
                    ),
                    onTap: _text.text.isEmpty
                        ? null
                        : () async {
                            _firestore.postComment(
                              post: widget.post,
                              user: widget.user,
                              text: _text.text,
                            );
                            setState(
                              () {
                                _text.text = '';
                              },
                            );
                          },
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  void _message() {}
}
