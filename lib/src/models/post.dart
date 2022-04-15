import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String description;
  final String uid;
  final String postId;
  final Timestamp? date;
  final String postUrl;
  final double aspectRatio;

  const Post({
    required this.description,
    required this.uid,
    required this.postId,
    required this.date,
    required this.postUrl,
    required this.aspectRatio,
  });

  Map<String, dynamic> toJson() => {
        'uid': uid,
        'description': description,
        'postId': postId,
        'date': date,
        'postUrl': postUrl,
        'aspectRatio': aspectRatio,
      };

  static Post fromJson(Map<String, dynamic> json) {
    return Post(
      uid: json['uid'],
      description: json['description'],
      postId: json['postId'],
      date: json['date'] ?? Timestamp.now(),
      postUrl: json['postUrl'],
      aspectRatio: (json['aspectRatio'] as num).toDouble(),
    );
  }
}
