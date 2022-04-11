import 'dart:developer';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:instagram/src/models/activity.dart';
import 'package:instagram/src/models/comments.dart';
import 'package:instagram/src/models/likes.dart';
import 'package:instagram/src/models/post.dart';
import 'package:instagram/src/models/user.dart' as model;
import 'package:instagram/src/providers/activity_provider.dart';
import 'package:instagram/src/providers/comment_provider.dart';
import 'package:instagram/src/providers/like_provider.dart';
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
  });
  final _firestore = FirebaseFirestore.instance;
  final StorageMethods storage;
  final CommentProvider commentProvider;
  final LikeProvider likeProvider;
  final ActivityProvider activityProvider;

  Stream<Post> at({required String postId}) {
    return _firestore
        .collection('posts')
        .doc(postId)
        .snapshots()
        .map((doc) => Post.fromSnapshot(doc))
        .doOnError((_, e) => log(e.toString()));
  }

  Stream<List<Post>> all({
    required List<String> uids,
    Timestamp? start,
    Timestamp? end,
  }) {
    assert(start != null || end != null);
    return FirestoreMethods.buffer(
        uids,
        (List<String> uid) => _firestore
            .collection('posts')
            .where('uid', whereIn: uid)
            .where('datePublished', isLessThanOrEqualTo: start)
            .where('datePublished', isGreaterThan: end)
            .orderBy('datePublished', descending: true)
            .snapshots()
            .flatMap((e) => Stream.fromIterable(e.docs)
                .map((data) => Post.fromSnapshot(data))
                .toList()
                .asStream())).doOnError((_, e) => log(e.toString()));
  }

  Future<Post> create({
    required String description,
    required Uint8List file,
    required model.User user,
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
      uid: user.uid,
      postId: postId,
      datePublished: Timestamp.now(),
      postUrl: photo.url,
      aspectRatio: photo.width / photo.height,
      bookmarks: [],
    );

    final batch = _firestore.batch();
    final data = serverTimestamp(post.toJson());
    batch.set(_firestore.collection('posts').doc(postId), data);
    likeProvider.create(batch, postId);
    commentProvider.create(batch, postId);

    log('create post: $postId');
    await batch.commit();
    if (description.isNotEmpty) {
      commentProvider.comment(
        id: postId,
        to: user.uid,
        uid: user.uid,
        text: description,
      );
    }
    return post;
  }

  Future<void> delete({required String postId}) async {
    log('delete post: $postId');
    final batch = _firestore.batch();
    batch.delete(_firestore.collection('posts').doc(postId));
    likeProvider.delete(batch, postId);
    commentProvider.delete(batch, postId);
    await storage.delete('posts', postId);
    await batch.commit();
  }

  Future<void> bookmark({required String postId, required String uid}) async {
    log('bookmark: $uid');
    await _firestore.collection('posts').doc(postId).update({
      'bookmarks': FieldValue.arrayUnion([uid])
    });
  }

  Future<void> unbookmark({required String postId, required String uid}) async {
    log('unbookmark: $uid');
    await _firestore.collection('posts').doc(postId).update({
      'bookmarks': FieldValue.arrayRemove([uid])
    });
  }

  Stream<List<Post>> bookmarks({required String uid}) {
    return _firestore
        .collection('posts')
        .where('bookmarks', arrayContains: uid)
        .snapshots()
        .flatMap((snapshot) => Stream.fromIterable(snapshot.docs)
            .map((doc) => Post.fromSnapshot(doc))
            .toList()
            .asStream())
        .doOnError((_, e) => log(e.toString()));
  }

  Stream<Likes> likes({required String postId}) {
    return likeProvider.at(id: postId);
  }

  Future<void> like({required Post post, required String uid}) async {
    likeProvider.like(
      id: post.postId,
      uid: uid,
      to: post.uid,
    );
  }

  Future<void> unlike({required Post post, required String uid}) async {
    likeProvider.unlike(id: post.postId, uid: uid);
  }

  Stream<Comments> comments({required String postId}) {
    return commentProvider.at(id: postId);
  }

  Future<void> comment(
      {required Post post, required String uid, required String text}) async {
    commentProvider.comment(
        id: post.postId, uid: uid, to: post.uid, text: text);
  }

  Stream<List<Activity>> activities({required String uid}) {
    return const Stream.empty();
  }
}
