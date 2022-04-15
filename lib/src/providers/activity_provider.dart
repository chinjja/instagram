import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:instagram/src/models/activity.dart';
import 'package:uuid/uuid.dart';

class ActivityProvider {
  final _firestore = FirebaseFirestore.instance;

  Future<List<Activity>> list({
    required String toUid,
    required int limit,
    Timestamp? start,
    Timestamp? end,
  }) async {
    final snapshot = await _firestore
        .collection('users')
        .doc(toUid)
        .collection('activities')
        .where('date', isLessThanOrEqualTo: start)
        .where('date', isGreaterThan: end)
        .limit(limit)
        .get();
    return snapshot.docs.map((e) => Activity.fromJson(e.data())).toList();
  }

  Activity? add(
    WriteBatch batch, {
    required String fromUid,
    required String toUid,
    required String type,
    required Map<String, dynamic> data,
  }) {
    if (fromUid == toUid) return null;

    final activityId = const Uuid().v1();
    final activity = Activity(
      activityId: activityId,
      type: type,
      fromUid: fromUid,
      toUid: toUid,
      data: data,
      date: Timestamp.now(),
    );
    final doc = _firestore
        .collection('users')
        .doc(toUid)
        .collection('activities')
        .doc(activityId);
    final json = activity.toJson();
    json['date'] = FieldValue.serverTimestamp();
    log('create activity: $activityId');
    batch.set(doc, json);
    return activity;
  }
}
