import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:instagram/src/models/activity.dart';
import 'package:instagram/src/models/comment.dart';
import 'package:instagram/src/models/like.dart';
import 'package:instagram/src/resources/storage_methods.dart';
import 'package:rxdart/rxdart.dart';

class ActivityProvider {
  ActivityProvider({required this.storage});
  final _firestore = FirebaseFirestore.instance;
  final StorageMethods storage;

  Stream<List<Activity>> all({required String uid}) {
    final comments = _firestore
        .collectionGroup('comments')
        .where('to', isEqualTo: uid)
        .orderBy('datePublished', descending: true)
        .limit(50)
        .snapshots()
        .flatMap((snapshot) => Stream.fromIterable(snapshot.docs)
            .map((doc) => Comment.fromSnapshot(doc))
            .toList()
            .asStream());

    final likes = _firestore
        .collectionGroup('likes')
        .where('to', isEqualTo: uid)
        .orderBy('datePublished', descending: true)
        .limit(50)
        .snapshots()
        .flatMap((snapshot) => Stream.fromIterable(snapshot.docs)
            .map((doc) => Like.fromSnapshot(doc))
            .toList()
            .asStream());

    return Rx.combineLatest2(comments, likes, (List<Comment> a, List<Like> b) {
      final list = <Activity>[
        ...a.where((e) => e.uid != uid),
        ...b.where((e) => e.uid != uid),
      ];
      list.sort(
        (a, b) => b.datePublished.compareTo(a.datePublished),
      );
      return list;
    });
  }
}
