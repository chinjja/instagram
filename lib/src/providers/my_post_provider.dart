import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:instagram/src/models/my_post.dart';
import 'package:instagram/src/resources/storage_methods.dart';
import 'package:rxdart/rxdart.dart';

class MyPostProvider {
  MyPostProvider({required this.storage});
  final _firestore = FirebaseFirestore.instance;
  final StorageMethods storage;

  void create(WriteBatch batch, {required String uid}) {
    log('create my post collection: $uid');
    batch.set(_firestore.collection('my-posts').doc(uid),
        MyPosts(uid: uid, posts: {}).toJson());
  }

  void delete(WriteBatch batch, {required String uid}) {
    log('delete my post collection: $uid');
    batch.delete(_firestore.collection('my-posts').doc(uid));
  }

  Stream<MyPosts> at({required String uid}) {
    return _firestore
        .collection('my-posts')
        .doc(uid)
        .snapshots()
        .where((doc) => doc.data() != null)
        .map((doc) => MyPosts.fromSnapshot(doc))
        .doOnError((_, e) => log(e.toString()));
  }

  void add(
    WriteBatch batch, {
    required String uid,
    required String postId,
    required String postUrl,
  }) {
    final data = MyPost(postId: postId, postUrl: postUrl).toJson();
    log('add my post: $postId');
    batch.update(_firestore.collection('my-posts').doc(uid), {
      'posts.$postId': data,
    });
  }

  void remove(
    WriteBatch batch, {
    required String uid,
    required String postId,
  }) {
    log('remove my post: $uid');
    batch.update(_firestore.collection('my-posts').doc(uid), {
      'posts.$postId': FieldValue.delete(),
    });
  }
}
