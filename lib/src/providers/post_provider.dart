import 'dart:async';
import 'dart:developer';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:instagram/src/models/comments.dart';
import 'package:instagram/src/models/likes.dart';
import 'package:instagram/src/models/post.dart';
import 'package:instagram/src/models/user.dart' as model;
import 'package:instagram/src/providers/activity_provider.dart';
import 'package:instagram/src/providers/comment_provider.dart';
import 'package:instagram/src/providers/like_provider.dart';
import 'package:instagram/src/providers/user_provider.dart';
import 'package:instagram/src/resources/firestore_methods.dart';
import 'package:instagram/src/resources/storage_methods.dart';
import 'package:instagram/src/utils/utils.dart';
import 'package:rxdart/rxdart.dart';
import 'package:uuid/uuid.dart';

class PostProvider {
  PostProvider({
    required this.storage,
    required this.commentProvider,
    required this.likeProvider,
    required this.activityProvider,
    required this.userProvider,
  });
  final _firestore = FirebaseFirestore.instance;
  final StorageMethods storage;
  final CommentProvider commentProvider;
  final LikeProvider likeProvider;
  final ActivityProvider activityProvider;
  final UserProvider userProvider;

  Stream<Post> at({required String uid, required String postId}) {
    return _firestore
        .collection('my-posts')
        .doc(uid)
        .collection('posts')
        .doc(postId)
        .snapshots()
        .where((doc) => doc.data() != null)
        .map((doc) => Post.fromSnapshot(doc))
        .doOnError((_, e) => log(e.toString()));
  }

  Stream<List<Post>> all({
    required String uid,
    Timestamp? start,
    Timestamp? end,
  }) {
    assert(start != null || end != null);
    return _firestore
        .collection('my-posts')
        .doc(uid)
        .collection('posts')
        .where('datePublished', isLessThanOrEqualTo: start)
        .where('datePublished', isGreaterThan: end)
        .orderBy('datePublished', descending: true)
        .snapshots()
        .flatMap((e) => Stream.fromIterable(e.docs)
            .map((data) => Post.fromSnapshot(data))
            .toList()
            .asStream())
        .doOnError((_, e) => log(e.toString()));
  }

  Stream<List<Post>> feeds({
    required List<String> uids,
    Timestamp? start,
    Timestamp? end,
  }) {
    assert(start != null || end != null);
    final streams = uids.map((e) => all(uid: e, start: start, end: end));
    return Rx.combineLatest(streams, (List<List<Post>> values) {
      final list = <Post>[];
      for (final sub in values) {
        list.addAll(sub);
      }
      list.sort((a, b) => b.datePublished!.compareTo(a.datePublished!));
      return list;
    });
  }

  Stream<Post?> latestFeed({required String uid, Timestamp? timestamp}) {
    return _firestore
        .collection('my-posts')
        .doc(uid)
        .collection('posts')
        .where('datePublished', isGreaterThan: timestamp)
        .orderBy('datePublished', descending: true)
        .limit(1)
        .snapshots()
        .flatMap((snapshot) => Stream.fromIterable(snapshot.docs)
            .map((doc) => Post.fromSnapshot(doc))
            .cast<Post?>()
            .defaultIfEmpty(null)
            .first
            .asStream());
  }

  Stream<List<Post>> latestFeeds({
    required List<String> uids,
    required Timestamp timestamp,
    required CompositeSubscription subscription,
  }) {
    final streams = uids.map((e) => latestFeed(uid: e, timestamp: timestamp));
    final subject = BehaviorSubject.seeded(<Post>[]);

    subscription.add(Rx.merge(streams).listen((post) async {
      if (post != null) {
        final list = await subject.first;
        subject.add([post, ...list]);
      }
    }));
    return subject;
  }

  Future<Post> create({
    required String description,
    required Uint8List file,
    required String uid,
  }) async {
    description = description.trim();
    final postId = const Uuid().v1();
    final photo = await storage.uploadImageData(
      file,
      'posts',
      postId,
    );

    final post = Post(
      description: description,
      uid: uid,
      postId: postId,
      datePublished: Timestamp.now(),
      postUrl: photo.url,
      aspectRatio: photo.width / photo.height,
    );

    final batch = _firestore.batch();
    final data = serverTimestamp(post.toJson());
    batch.set(
        _firestore
            .collection('my-posts')
            .doc(uid)
            .collection('posts')
            .doc(postId),
        data);
    likeProvider.create(
      batch,
      postId,
    );
    commentProvider.create(
      batch,
      postId,
    );
    userProvider.addPost(
      batch,
      uid: post.uid,
      postId: postId,
      postUrl: post.postUrl,
    );

    log('create post: $postId');
    await batch.commit();
    if (description.isNotEmpty) {
      await commentProvider.comment(
        id: postId,
        to: uid,
        uid: uid,
        text: description,
      );
    }
    return post;
  }

  Future<void> delete({required String postId, required String uid}) async {
    log('delete post: $postId');
    final batch = _firestore.batch();
    batch.delete(_firestore
        .collection('my-posts')
        .doc(uid)
        .collection('posts')
        .doc(postId));
    likeProvider.delete(batch, postId);
    commentProvider.delete(batch, postId);
    userProvider.removePost(batch, uid: uid, postId: postId);
    await batch.commit();
    await userProvider.unbookmark(postId: postId, uid: uid);
    await storage.delete('posts', postId);
  }

  Stream<Likes> likes({required String postId}) {
    return likeProvider.at(id: postId);
  }

  Future<void> like({required Post post, required String uid}) async {
    await likeProvider.like(
      id: post.postId,
      uid: uid,
      to: post.uid,
    );
    await activityProvider
        .activity(from: uid, uid: post.uid, type: 'like', data: {
      'postId': post.postId,
    });
  }

  Future<void> unlike({required Post post, required String uid}) async {
    await likeProvider.unlike(id: post.postId, uid: uid);
    await activityProvider
        .activity(from: uid, uid: post.uid, type: 'unlike', data: {
      'postId': post.postId,
    });
  }

  Stream<Comments> comments({required String postId}) {
    return commentProvider.at(id: postId);
  }

  Future<void> comment(
      {required Post post, required String uid, required String text}) async {
    await commentProvider.comment(
        id: post.postId, uid: uid, to: post.uid, text: text);
    await activityProvider
        .activity(from: uid, uid: post.uid, type: 'comment', data: {
      'postId': post.postId,
      'text': text,
    });
  }
}
