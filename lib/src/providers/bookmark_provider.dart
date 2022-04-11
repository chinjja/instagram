import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:instagram/src/models/bookmark.dart';
import 'package:instagram/src/resources/storage_methods.dart';
import 'package:rxdart/rxdart.dart';

class BookmarkProvider {
  BookmarkProvider({required this.storage});
  final _firestore = FirebaseFirestore.instance;
  final StorageMethods storage;

  Future<void> toggle({required String postId, required String uid}) async {
    final bookmarks = _firestore
        .collection('posts')
        .doc(postId)
        .collection('bookmarks')
        .doc(uid);
    final bookmark = await bookmarks.get();
    if (bookmark.exists) {
      log('delete bookmark: $uid');
      await bookmarks.delete();
    } else {
      log('create bookmark: $uid');
      await bookmarks.set(
        Bookmark(
          uid: uid,
          postId: postId,
        ).toJson(),
      );
    }
  }

  Stream<bool> has({required String postId, required String uid}) {
    return _firestore
        .collection('posts')
        .doc(postId)
        .collection('bookmarks')
        .doc(uid)
        .snapshots()
        .map((event) => event.exists);
  }

  Stream<List<Bookmark>> all({required String uid}) {
    return _firestore
        .collectionGroup('bookmarks')
        .where('uid', isEqualTo: uid)
        .snapshots()
        .flatMap((snapshot) => Stream.fromIterable(snapshot.docs)
            .map((doc) => Bookmark.fromSnapshot(doc))
            .toList()
            .asStream());
  }
}
