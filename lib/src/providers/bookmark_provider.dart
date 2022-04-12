import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:instagram/src/models/bookmark.dart';
import 'package:instagram/src/models/bookmarks.dart';
import 'package:instagram/src/resources/storage_methods.dart';
import 'package:rxdart/rxdart.dart';

class BookmarkProvider {
  BookmarkProvider({required this.storage});
  final _firestore = FirebaseFirestore.instance;
  final StorageMethods storage;

  void create(WriteBatch batch, {required String id}) {
    log('create bookmark: $id');
    batch.set(_firestore.collection('bookmarks').doc(id),
        Bookmarks(id: id, posts: {}).toJson());
  }

  void delete(WriteBatch batch, {required String id}) {
    log('delete bookmark: $id');
    batch.delete(_firestore.collection('bookmarks').doc(id));
  }

  Stream<Bookmarks> at({required String id}) {
    return _firestore
        .collection('bookmarks')
        .doc(id)
        .snapshots()
        .where((doc) => doc.data() != null)
        .map((doc) => Bookmarks.fromSnapshot(doc))
        .doOnError((_, e) => log(e.toString()));
  }

  Future<void> bookmark({
    required String id,
    required String postId,
    required String postUrl,
  }) async {
    final data = Bookmark(postId: postId, postUrl: postUrl).toJson();
    log('bookmark: $postId');
    await _firestore.collection('bookmarks').doc(id).update({
      'posts.$postId': data,
    });
  }

  Future<void> unbookmark({
    required String id,
    required String postId,
  }) async {
    log('unbookmark: $id');
    await _firestore.collection('bookmarks').doc(id).update({
      'posts.$postId': FieldValue.delete(),
    });
  }
}
