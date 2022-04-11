import 'package:cloud_firestore/cloud_firestore.dart';

class Comment {
  final String commentId;
  final String uid;
  final String to;
  final Timestamp? datePublished;
  final String text;

  const Comment({
    required this.commentId,
    required this.uid,
    required this.to,
    required this.datePublished,
    required this.text,
  });

  Map<String, dynamic> toJson() => {
        'commentId': commentId,
        'uid': uid,
        'to': to,
        'text': text,
        'datePublished': datePublished,
      };

  static Comment fromJson(Map<String, dynamic> json) {
    return Comment(
      commentId: json['commentId'],
      uid: json['uid'],
      to: json['to'],
      text: json['text'],
      datePublished: json['datePublished'],
    );
  }
}
