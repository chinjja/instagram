import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:instagram/src/models/comment.dart';
import 'package:instagram/src/models/post.dart';
import 'package:instagram/src/resources/storage_methods.dart';
import 'package:instagram/src/utils/utils.dart';
import 'package:rxdart/rxdart.dart';
import 'package:uuid/uuid.dart';

class CommentProvider {
  CommentProvider({required this.storage});
  final _firestore = FirebaseFirestore.instance;
  final StorageMethods storage;

  Stream<Comment> at({required String postId, required String commentId}) {
    return _firestore
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .doc(commentId)
        .snapshots()
        .map((event) => Comment.fromSnapshot(event));
  }

  Stream<List<Comment>> all(
      {required String postId, Timestamp? start, Timestamp? end}) {
    return _firestore
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .orderBy('datePublished')
        .where('datePublished', isLessThanOrEqualTo: start)
        .where('datePublished', isGreaterThan: end)
        .snapshots()
        .flatMap((e) => Stream.fromIterable(e.docs)
            .map((event) => Comment.fromSnapshot(event))
            .toList()
            .asStream());
  }

  Future<void> create({
    required Post post,
    required String uid,
    required String text,
    WriteBatch? batch,
  }) async {
    text = text.trim();
    assert(text.isNotEmpty);
    final commentId = const Uuid().v1();
    final comment = Comment(
      commentId: commentId,
      postId: post.postId,
      uid: uid,
      to: post.uid,
      text: text,
      datePublished: Timestamp.now(),
    );
    final ref = _firestore
        .collection('posts')
        .doc(post.postId)
        .collection('comments')
        .doc(commentId);
    final data = serverTimestamp(comment.toJson());
    log('create comment: $commentId');
    if (batch != null) {
      batch.set(ref, data);
    } else {
      await ref.set(data);
    }
  }

  Future<void> delete(Comment comment) async {
    log('delete comment: ${comment.commentId}');
    await _firestore
        .collection('posts')
        .doc(comment.postId)
        .collection('comments')
        .doc(comment.commentId)
        .delete();
  }
}
