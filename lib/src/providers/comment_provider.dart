import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:instagram/src/models/comment.dart';
import 'package:instagram/src/models/comments.dart';
import 'package:instagram/src/resources/storage_methods.dart';
import 'package:rxdart/rxdart.dart';
import 'package:uuid/uuid.dart';

class CommentProvider {
  CommentProvider({required this.storage});
  final _firestore = FirebaseFirestore.instance;
  final StorageMethods storage;

  Stream<Comments> at({required String id}) {
    return _firestore
        .collection('comments')
        .doc(id)
        .snapshots()
        .where((doc) => doc.data() != null)
        .map((event) => Comments.fromSnapshot(event));
  }

  void create(WriteBatch batch, String id) {
    batch.set(_firestore.collection('comments').doc(id),
        Comments(id: id, list: []).toJson());
  }

  void delete(WriteBatch batch, String id) {
    batch.delete(_firestore.collection('comments').doc(id));
  }

  Future<void> comment({
    required String id,
    required String uid,
    required String to,
    required String text,
  }) async {
    text = text.trim();
    assert(text.isNotEmpty);
    final commentId = const Uuid().v1();
    final comment = Comment(
      commentId: commentId,
      uid: uid,
      to: to,
      text: text,
      datePublished: Timestamp.now(),
    );
    log('create comment: $commentId');
    await _firestore.collection('comments').doc(id).update({
      'list': FieldValue.arrayUnion([comment.toJson()]),
    });
  }
}
