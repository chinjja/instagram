import 'package:cloud_firestore/cloud_firestore.dart';

class Comment {
  final String id;
  final String uid;
  final String text;
  final DateTime datePublished;

  const Comment({
    required this.id,
    required this.uid,
    required this.text,
    required this.datePublished,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'uid': uid,
        'text': text,
        'datePublished': datePublished.toIso8601String(),
      };

  static Comment fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    return Comment(
      id: data['id'],
      uid: data['uid'],
      text: data['text'],
      datePublished: DateTime.parse(data['datePublished']),
    );
  }
}
