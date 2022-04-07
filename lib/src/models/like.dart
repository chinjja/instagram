import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:instagram/src/models/activity.dart';

class Like extends Activity {
  const Like({
    required String uid,
    required String postId,
    required String to,
    required DateTime datePublished,
  }) : super(
          uid: uid,
          postId: postId,
          to: to,
          datePublished: datePublished,
        );

  Map<String, dynamic> toJson() => {
        'uid': uid,
        'postId': postId,
        'to': to,
        'datePublished': datePublished.toIso8601String(),
      };

  static Like fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    return Like(
      uid: data['uid'],
      postId: data['postId'],
      to: data['to'],
      datePublished: DateTime.parse(data['datePublished']),
    );
  }
}
