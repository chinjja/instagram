import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:instagram/src/repo/models/model.dart';
import 'package:uuid/uuid.dart';

class ActivityProvider {
  final _firestore = FirebaseFirestore.instance;

  Future<List<Activity>> fetch({
    required String toUid,
    required int limit,
    Activity? cursor,
  }) async {
    Timestamp? timestamp;
    if (cursor != null) {
      timestamp = Timestamp.fromDate(cursor.date);
    }
    final snapshot = await _firestore
        .collection('activities')
        .where('date', isLessThan: timestamp)
        .orderBy('date', descending: true)
        .limit(limit)
        .get();
    return snapshot.docs.map((e) => Activity.fromJson(e.data())).toList();
  }

  Future<List<Activity>> activities({required String postId}) async {
    final snapshot = await _firestore
        .collection('activities')
        .where('postId', isEqualTo: postId)
        .get();
    return snapshot.docs.map((e) => Activity.fromJson(e.data())).toList();
  }

  Activity? add(
    WriteBatch batch, {
    required String postId,
    required String fromUid,
    required String toUid,
    required String type,
    required Map<String, dynamic> data,
  }) {
    if (fromUid == toUid) return null;

    final activityId = const Uuid().v1();
    final activity = Activity(
      activityId: activityId,
      postId: postId,
      type: type,
      fromUid: fromUid,
      toUid: toUid,
      data: data,
      date: DateTime.now(),
    );
    final doc = _firestore.collection('activities').doc(activityId);
    final json = activity.toJson();
    json['date'] = FieldValue.serverTimestamp();
    log('create activity: $activityId');
    batch.set(doc, json);
    return activity;
  }

  Future<void> delete({required String activityId}) async {
    final batch = _firestore.batch();
    _delete(batch, activityId: activityId);
    await batch.commit();
  }

  Future<void> _delete(
    WriteBatch batch, {
    required String activityId,
  }) async {
    log('delete activity: $activityId');
    batch.delete(_firestore.collection('activities').doc(activityId));
  }

  Future<void> clear(
    WriteBatch batch, {
    required String postId,
  }) async {
    final list = await activities(postId: postId);
    log('delete activity: $postId');
    for (final i in list) {
      _delete(batch, activityId: i.activityId);
    }
  }
}
