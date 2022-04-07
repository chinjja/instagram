import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String description;
  final String uid;
  final String postId;
  final DateTime datePublished;
  final String postUrl;
  final double aspectRatio;

  const Post({
    required this.description,
    required this.uid,
    required this.postId,
    required this.datePublished,
    required this.postUrl,
    required this.aspectRatio,
  });

  Map<String, dynamic> toJson() => {
        'uid': uid,
        'description': description,
        'postId': postId,
        'datePublished': datePublished.toIso8601String(),
        'postUrl': postUrl,
        'aspectRatio': aspectRatio,
      };

  static Post fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    return Post(
      uid: data['uid'],
      description: data['description'],
      postId: data['postId'],
      datePublished: DateTime.parse(data['datePublished']),
      postUrl: data['postUrl'],
      aspectRatio: data['aspectRatio'],
    );
  }
}
