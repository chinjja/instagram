import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:instagram/src/models/like.dart';
import 'package:instagram/src/models/likes.dart';
import 'package:instagram/src/resources/storage_methods.dart';
import 'package:rxdart/rxdart.dart';

class LikeProvider {
  LikeProvider({required this.storage});
  final _firestore = FirebaseFirestore.instance;
  final StorageMethods storage;

  void create(WriteBatch batch, String id) {
    log('create like: $id');
    batch.set(_firestore.collection('likes').doc(id),
        Likes(id: id, likes: {}).toJson());
  }

  void delete(WriteBatch batch, String id) {
    log('delete like: $id');
    batch.delete(_firestore.collection('likes').doc(id));
  }

  Stream<Likes> at({required String id}) {
    return _firestore
        .collection('likes')
        .doc(id)
        .snapshots()
        .where((doc) => doc.data() != null)
        .map((doc) => Likes.fromSnapshot(doc))
        .doOnError((_, e) => log(e.toString()));
  }

  Future<void> like(
      {required String id, required String uid, required String to}) async {
    final data =
        Like(uid: uid, to: to, datePublished: Timestamp.now()).toJson();
    data['datePublished'] = FieldValue.serverTimestamp();
    log('like: $id');
    await _firestore.collection('likes').doc(id).update({
      'likes.$uid': data,
    });
  }

  Future<void> unlike({required String id, required String uid}) async {
    log('unlike: $id');
    await _firestore.collection('likes').doc(id).update({
      'likes.$uid': FieldValue.delete(),
    });
  }
}
