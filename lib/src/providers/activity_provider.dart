import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:instagram/src/models/activity.dart';
import 'package:instagram/src/resources/storage_methods.dart';
import 'package:rxdart/rxdart.dart';
import 'package:uuid/uuid.dart';

class ActivityProvider {
  ActivityProvider({required this.storage});
  final _firestore = FirebaseFirestore.instance;
  final StorageMethods storage;

  Future<void> create({
    required String refType,
    required String refId,
    required String uid,
    required String to,
    required String text,
  }) async {
    final activityId = const Uuid().v1();
    final data = Activity(
      activityId: activityId,
      refType: refType,
      refId: refId,
      uid: uid,
      to: to,
      text: text,
      datePublished: null,
    ).toJson();
    data['datePublished'] = FieldValue.serverTimestamp();
    log('create activity: $activityId');
    await _firestore.collection('activities').doc(activityId).set(data);
  }

  Future<void> delete({required String activityId}) async {
    log('delete activity: $activityId');
    await _firestore.collection('activities').doc(activityId).delete();
  }

  Stream<List<Activity>> activities({required String uid}) {
    return _firestore
        .collection('activities')
        .where('to', isEqualTo: uid)
        .snapshots()
        .flatMap((snapshot) => Stream.fromIterable(snapshot.docs)
            .map((doc) => Activity.fromJson(doc.data()))
            .toList()
            .asStream())
        .doOnError((_, e) => log(e.toString()));
  }
}
