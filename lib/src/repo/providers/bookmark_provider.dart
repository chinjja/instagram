import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:instagram/src/repo/models/model.dart';

class BookmarkProvider {
  final _firestore = FirebaseFirestore.instance;

  Future<bool> exists({
    required String uid,
    required String postId,
  }) async {
    final snapshot = await _firestore
        .collection('users')
        .doc(uid)
        .collection('bookmarks')
        .doc(postId)
        .get();
    return snapshot.exists;
  }

  void set(
    WriteBatch batch, {
    required String uid,
    required String postId,
    String? postUrl,
    required bool value,
  }) {
    if (value && postUrl == null) {
      throw 'require a post url for bookmarking';
    }
    final bookmark = _firestore
        .collection('users')
        .doc(uid)
        .collection('bookmarks')
        .doc(postId);
    if (value) {
      final data = Bookmark(postId: postId, postUrl: postUrl!);
      batch.set(bookmark, data.toJson());
    } else {
      batch.delete(bookmark);
    }
    log('bookmark: $value $postId');
  }

  Future<List<Bookmark>> fetch({
    required String uid,
    required int limit,
    Bookmark? cursor,
  }) async {
    final snapshot = await _firestore
        .collection('users')
        .doc(uid)
        .collection('bookmarks')
        .where('postId', isGreaterThan: cursor?.postId)
        .orderBy('postId')
        .limit(limit)
        .get();
    return snapshot.docs.map((e) => Bookmark.fromJson(e.data())).toList();
  }
}
