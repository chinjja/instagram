import 'package:cloud_firestore/cloud_firestore.dart';

class Like {
  final String uid;
  final String to;
  final Timestamp? datePublished;

  const Like({
    required this.uid,
    required this.to,
    required this.datePublished,
  });

  Map<String, dynamic> toJson() => {
        'uid': uid,
        'to': to,
        'datePublished': datePublished,
      };

  static Like fromJson(Map<String, dynamic> json) {
    return Like(
      uid: json['uid'],
      to: json['to'],
      datePublished: json['datePublished'],
    );
  }
}
