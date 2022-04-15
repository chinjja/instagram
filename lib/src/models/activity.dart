import 'package:cloud_firestore/cloud_firestore.dart';

class Activity {
  final String activityId;
  final String type;
  final String fromUid;
  final String toUid;
  final Timestamp? date;
  final Map<String, dynamic> data;

  const Activity({
    required this.activityId,
    required this.type,
    required this.fromUid,
    required this.toUid,
    required this.date,
    required this.data,
  });

  Map<String, dynamic> toJson() => {
        'activityId': activityId,
        'type': type,
        'fromUid': fromUid,
        'toUid': toUid,
        'date': date,
        'data': data,
      };

  static Activity fromJson(Map<String, dynamic> json) {
    return Activity(
      activityId: json['activityId'],
      type: json['type'],
      fromUid: json['fromUid'],
      toUid: json['toUid'],
      date: json['date'],
      data: Map.castFrom(json['data']),
    );
  }
}
