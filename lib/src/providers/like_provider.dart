import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:instagram/src/models/like.dart';
import 'package:instagram/src/models/post.dart';
import 'package:instagram/src/resources/storage_methods.dart';
import 'package:instagram/src/utils/utils.dart';
import 'package:rxdart/rxdart.dart';

class LikeProvider {
  LikeProvider({required this.storage});
  final _firestore = FirebaseFirestore.instance;
  final StorageMethods storage;

  Stream<List<Like>> all({required String postId}) {
    return _firestore
        .collection('posts')
        .doc(postId)
        .collection('likes')
        .snapshots()
        .flatMap((snapshot) => Stream.fromIterable(snapshot.docs)
            .map((doc) => Like.fromSnapshot(doc))
            .toList()
            .asStream());
  }

  Stream<bool> has({required String postId, required String uid}) {
    return _firestore
        .collection('posts')
        .doc(postId)
        .collection('likes')
        .doc(uid)
        .snapshots()
        .map((event) => event.exists);
  }

  Future<void> toggle({required Post post, required String uid}) async {
    final ref = _firestore
        .collection('posts')
        .doc(post.postId)
        .collection('likes')
        .doc(uid);
    log('toggle like: $uid');
    await _firestore.runTransaction((transaction) async {
      final like = await transaction.get(ref);
      if (like.exists) {
        transaction.delete(ref);
      } else {
        final data = serverTimestamp(Like(
          uid: uid,
          postId: post.postId,
          to: post.uid,
          datePublished: Timestamp.now(),
        ).toJson());
        transaction.set(ref, data);
      }
    });
  }
}
