import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:instagram/src/models/comment.dart';

class Comments {
  final String id;
  final List<Comment> list;

  const Comments({
    required this.id,
    required this.list,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'list': list.map((e) => e.toJson()).toList(),
      };

  static Comments fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    final list = <Comment>[];
    for (final json in data['list']) {
      list.add(Comment.fromJson(json));
    }
    return Comments(
      id: data['id'],
      list: list,
    );
  }
}
