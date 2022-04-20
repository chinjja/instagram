import 'dart:developer';
import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';

class LikeProvider {
  static const maxDistribution = 5;
  final _firestore = FirebaseFirestore.instance;

  Future<int> getCount({
    required String postId,
  }) async {
    final snapshot = await _firestore
        .collection('posts')
        .doc(postId)
        .collection('likeCount')
        .get();
    int count = 0;
    for (final doc in snapshot.docs) {
      count += doc['count'] as int;
    }
    return count;
  }

  Future<bool> exists({
    required String uid,
    required String postId,
  }) async {
    final snapshot = await _firestore
        .collection('users')
        .doc(uid)
        .collection('likes')
        .doc(postId)
        .get();
    return snapshot.exists;
  }

  void set(
    WriteBatch batch, {
    required String uid,
    required String postId,
    required bool value,
    bool ignoreCount = false,
  }) {
    final like =
        _firestore.collection('users').doc(uid).collection('likes').doc(postId);
    final count = _firestore
        .collection('posts')
        .doc(postId)
        .collection('likeCount')
        .doc(math.Random().nextInt(maxDistribution).toString());
    if (value) {
      batch.set(like, {
        'postId': postId,
      });
      batch.set(
          count, {'count': FieldValue.increment(1)}, SetOptions(merge: true));
    } else {
      batch.delete(like);
      if (!ignoreCount) {
        batch.set(
          count,
          {'count': FieldValue.increment(-1)},
          SetOptions(merge: true),
        );
      }
    }
    log('like: $value $uid');
  }
}
