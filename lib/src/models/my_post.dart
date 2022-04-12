import 'package:cloud_firestore/cloud_firestore.dart';

class MyPost {
  final String postId;
  final String postUrl;

  const MyPost({
    required this.postId,
    required this.postUrl,
  });

  Map<String, dynamic> toJson() => {
        'postId': postId,
        'postUrl': postUrl,
      };

  static MyPost fromJson(Map<String, dynamic> json) {
    return MyPost(
      postId: json['postId'],
      postUrl: json['postUrl'],
    );
  }
}

class MyPosts {
  final String uid;
  final Map<String, MyPost> posts;

  const MyPosts({
    required this.uid,
    required this.posts,
  });

  Map<String, dynamic> toJson() => {
        'uid': uid,
        'posts': posts.map((key, value) => MapEntry(key, value.toJson())),
      };

  static MyPosts fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    final likes =
        data['posts'].map((key, json) => MapEntry(key, MyPost.fromJson(json)));
    return MyPosts(
      uid: data['uid'],
      posts: Map.castFrom(likes),
    );
  }
}
