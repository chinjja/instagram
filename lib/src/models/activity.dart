import 'package:cloud_firestore/cloud_firestore.dart';

class Activity {
  final String type;
  final String uid;
  final Timestamp? datePublished;
  final Map<String, dynamic> data;

  const Activity({
    required this.type,
    required this.uid,
    required this.datePublished,
    required this.data,
  });

  Map<String, dynamic> toJson() => {
        'type': type,
        'uid': uid,
        'datePublished': datePublished,
        'data': data,
      };

  static Activity fromJson(Map<String, dynamic> json) {
    return Activity(
      type: json['type'],
      uid: json['uid'],
      datePublished: json['datePublished'],
      data: json['data'],
    );
  }
}
