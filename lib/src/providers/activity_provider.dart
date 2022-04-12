import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:instagram/src/models/activities.dart';
import 'package:instagram/src/models/activity.dart';
import 'package:instagram/src/resources/storage_methods.dart';

class ActivityProvider {
  ActivityProvider({required this.storage});
  final _firestore = FirebaseFirestore.instance;
  final StorageMethods storage;

  Stream<Activities> at({required String uid}) {
    return _firestore
        .collection('activities')
        .doc(uid)
        .snapshots()
        .where((doc) => doc.data() != null)
        .map((event) => Activities.fromSnapshot(event));
  }

  void create(WriteBatch batch, {required String uid}) {
    batch.set(_firestore.collection('activities').doc(uid),
        Activities(uid: uid, list: []).toJson());
  }

  void delete(WriteBatch batch, {required String uid}) {
    batch.delete(_firestore.collection('activities').doc(uid));
  }

  Future<void> activity({
    required String uid,
    required String from,
    required String type,
    required Map<String, dynamic> data,
  }) async {
    if (uid == from) return;

    final comment = Activity(
      type: type,
      uid: from,
      data: data,
      datePublished: Timestamp.now(),
    );
    log('create activity: $from');
    await _firestore.collection('activities').doc(uid).update({
      'list': FieldValue.arrayUnion([comment.toJson()]),
    });
  }
}
