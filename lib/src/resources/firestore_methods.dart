import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:instagram/src/repo/providers/provider.dart';
import 'package:rxdart/rxdart.dart';

class FirestoreMethods {
  const FirestoreMethods({
    required this.users,
    required this.posts,
    required this.likes,
    required this.comments,
    required this.activities,
    required this.chats,
    required this.messages,
    required this.bookmarks,
    required this.fcmProvider,
  });
  final UserProvider users;
  final PostProvider posts;
  final LikeProvider likes;
  final CommentProvider comments;
  final ActivityProvider activities;
  final ChatProvider chats;
  final MessageProvider messages;
  final BookmarkProvider bookmarks;
  final FcmProvider fcmProvider;

  static Stream<List<R>> buffer<T, R>(
    List<T> list,
    Stream<List<R>> Function(List<T>) map, {
    int count = 10,
  }) {
    final streams = <Stream<List<R>>>[];
    int i = 0;
    while (i < list.length) {
      final len = math.min(count, list.length - i);
      streams.add(map(list.sublist(i, i + len)));
      i += len;
    }
    return Rx.combineLatest(streams, (List<List<R>> intermediates) {
      final result = <R>[];
      for (final intermediate in intermediates) {
        result.addAll(intermediate);
      }
      return result;
    });
  }

  static Future<void> deleteCollection(
      WriteBatch batch, DocumentReference ref, String id) async {
    final collectionRef = ref.collection(id);
    final snapshot = await collectionRef.get();
    for (final doc in snapshot.docs) {
      batch.delete(collectionRef.doc(doc.id));
    }
  }
}
