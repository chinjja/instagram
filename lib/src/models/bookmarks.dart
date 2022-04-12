import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:instagram/src/models/bookmark.dart';

class Bookmarks {
  final String id;
  final Map<String, Bookmark> posts;

  const Bookmarks({
    required this.id,
    required this.posts,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'posts': posts.map((key, value) => MapEntry(key, value.toJson())),
      };

  static Bookmarks fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    final likes = data['posts']
        .map((key, json) => MapEntry(key, Bookmark.fromJson(json)));
    return Bookmarks(
      id: data['id'],
      posts: Map.castFrom(likes),
    );
  }
}
