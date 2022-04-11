import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:instagram/src/models/like.dart';

class Likes {
  final String id;
  final Map<String, Like> likes;

  const Likes({
    required this.id,
    required this.likes,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'likes': likes.map((key, value) => MapEntry(key, value.toJson())),
      };

  static Likes fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    final likes =
        data['likes'].map((key, json) => MapEntry(key, Like.fromJson(json)));
    return Likes(
      id: data['id'],
      likes: Map.castFrom(likes),
    );
  }
}
