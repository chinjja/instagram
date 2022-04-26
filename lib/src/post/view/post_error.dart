import 'package:flutter/material.dart';

class PostError extends StatelessWidget {
  const PostError({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Post process failure'),
    );
  }
}
