import 'package:flutter/material.dart';
import 'package:instagram/src/comment/model/comment_data.dart';
import 'package:instagram/src/comment/view/comment_base_cart.dart';

class CommentCard extends StatelessWidget {
  const CommentCard({
    Key? key,
    required this.data,
  }) : super(key: key);

  final CommentData data;

  @override
  Widget build(BuildContext context) {
    return CommentBaseCard(
      user: data.commentUser,
      text: data.comment.text,
      date: data.comment.date,
      trailing: IconButton(
        onPressed: _like,
        icon: const Icon(Icons.favorite_outline, size: 16),
      ),
    );
  }

  void _like() {}
}
