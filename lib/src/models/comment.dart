import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:instagram/src/models/activity.dart';

class Comment extends Activity {
  final String commentId;
  final String text;

  const Comment({
    required String uid,
    required String postId,
    required String to,
    required Timestamp datePublished,
    required this.commentId,
    required this.text,
  }) : super(
          uid: uid,
          postId: postId,
          to: to,
          datePublished: datePublished,
        );

  Map<String, dynamic> toJson() => {
        'commentId': commentId,
        'postId': postId,
        'uid': uid,
        'to': to,
        'text': text,
        'datePublished': datePublished,
      };

  static Comment fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    return Comment(
      commentId: data['commentId'],
      postId: data['postId'],
      uid: data['uid'],
      to: data['to'],
      text: data['text'],
      datePublished: data['datePublished'],
    );
  }
}
