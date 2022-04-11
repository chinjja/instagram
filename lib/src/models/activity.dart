import 'package:cloud_firestore/cloud_firestore.dart';

class Activity {
  final String activityId;
  final String refType;
  final String refId;
  final String uid;
  final String to;
  final String text;
  final Timestamp? datePublished;

  const Activity({
    required this.activityId,
    required this.refType,
    required this.refId,
    required this.uid,
    required this.to,
    required this.text,
    required this.datePublished,
  });

  Map<String, dynamic> toJson() => {
        'activityId': activityId,
        'refType': refType,
        'refId': refId,
        'uid': uid,
        'to': to,
        'text': text,
        'datePublished': datePublished,
      };

  static Activity fromJson(Map<String, dynamic> json) {
    return Activity(
      activityId: json['activityId'],
      refType: json['refType'],
      refId: json['refId'],
      uid: json['uid'],
      to: json['to'],
      text: json['text'],
      datePublished: json['datePublished'],
    );
  }
}
