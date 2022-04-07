import 'package:cloud_firestore/cloud_firestore.dart';

class Bookmark {
  final String uid;
  final String postId;

  const Bookmark({
    required this.uid,
    required this.postId,
  });

  Map<String, dynamic> toJson() => {
        'uid': uid,
        'postId': postId,
      };

  static Bookmark fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    return Bookmark(
      uid: data['uid'],
      postId: data['postId'],
    );
  }
}
