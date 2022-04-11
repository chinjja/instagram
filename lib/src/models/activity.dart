import 'package:cloud_firestore/cloud_firestore.dart';

class Activity {
  final String postId;
  final String uid;
  final String to;
  final Timestamp datePublished;

  const Activity({
    required this.postId,
    required this.uid,
    required this.to,
    required this.datePublished,
  });
}
