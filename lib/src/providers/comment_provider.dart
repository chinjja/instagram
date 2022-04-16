import 'dart:developer';
import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:instagram/src/models/comment.dart';
import 'package:uuid/uuid.dart';

class CommentProvider {
  final _firestore = FirebaseFirestore.instance;

  static const maxDistribution = 5;

  Future<List<Comment>> list({
    required String postId,
    required int limit,
    Timestamp? start,
    Timestamp? end,
  }) async {
    final snapshot = await _firestore
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .where('date', isLessThanOrEqualTo: start)
        .where('date', isGreaterThan: end)
        .orderBy('date')
        .limit(limit)
        .get();

    return snapshot.docs.map((e) => Comment.fromJson(e.data())).toList();
  }

  QueryDocumentSnapshot? _latestDocument;

  Future<List<Comment>> first({
    required String postId,
    required int limit,
  }) async {
    final snapshot = await _firestore
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .orderBy('date')
        .limit(limit)
        .get();
    _latestDocument = snapshot.size == 0 ? null : snapshot.docs.last;
    return snapshot.docs.map((e) => Comment.fromJson(e.data())).toList();
  }

  Future<List<Comment>> next({
    required String postId,
    required int limit,
  }) async {
    if (_latestDocument == null) {
      return [];
    }
    final snapshot = await _firestore
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .startAfterDocument(_latestDocument!)
        .orderBy('date')
        .limit(limit)
        .get();

    _latestDocument = snapshot.size == 0 ? _latestDocument : snapshot.docs.last;
    return snapshot.docs.map((e) => Comment.fromJson(e.data())).toList();
  }

  Future<Comment?> get(
      {required String postId, required String commentId}) async {
    final snapshot = await _firestore
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .doc(commentId)
        .get();

    if (snapshot.exists) {
      return Comment.fromJson(snapshot.data()!);
    }
    return null;
  }

  Future<int> getCount({
    required String postId,
  }) async {
    final snapshot = await _firestore
        .collection('posts')
        .doc(postId)
        .collection('commentCount')
        .get();
    int count = 0;
    for (final doc in snapshot.docs) {
      count += doc['count'] as int;
    }
    return count;
  }

  Comment add(
    WriteBatch batch, {
    required String postId,
    required String fromUid,
    required String toUid,
    required String text,
  }) {
    final commentId = const Uuid().v1();
    final comment = _firestore
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .doc(commentId);
    final count = _firestore
        .collection('posts')
        .doc(postId)
        .collection('commentCount')
        .doc(math.Random().nextInt(maxDistribution).toString());

    final obj = Comment(
      commentId: commentId,
      uid: fromUid,
      to: toUid,
      date: DateTime.now(),
      text: text,
    );
    final data = obj.toJson();
    data['date'] = FieldValue.serverTimestamp();
    batch.set(comment, data);
    batch.set(
      count,
      {'count': FieldValue.increment(1)},
      SetOptions(merge: true),
    );
    log('add comment $text $fromUid');
    return obj;
  }
}
