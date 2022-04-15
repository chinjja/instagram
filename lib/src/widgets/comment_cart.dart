import 'package:flutter/material.dart';
import 'package:instagram/src/models/comment.dart';
import 'package:instagram/src/models/user.dart';
import 'package:instagram/src/resources/firestore_methods.dart';
import 'package:instagram/src/widgets/comment_base_cart.dart';
import 'package:provider/provider.dart';

class CommentCard extends StatefulWidget {
  const CommentCard({
    Key? key,
    required this.comment,
  }) : super(key: key);
  final Comment comment;
  @override
  State<CommentCard> createState() => _CommentCardState();
}

class _CommentCardState extends State<CommentCard> {
  late final _firestore = context.read<FirestoreMethods>();
  User? user;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    final value = await _firestore.users.get(uid: widget.comment.uid);
    setState(() {
      user = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    final comment = widget.comment;

    return CommentBaseCard(
      user: user,
      text: comment.text,
      date: comment.date,
      trailing: IconButton(
        onPressed: _like,
        icon: const Icon(Icons.favorite_outline, size: 16),
      ),
    );
  }

  void _like() {}
}
