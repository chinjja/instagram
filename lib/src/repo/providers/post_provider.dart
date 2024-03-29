import 'dart:async';
import 'dart:developer';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:instagram/src/repo/models/model.dart';
import 'package:instagram/src/repo/providers/provider.dart';
import 'package:instagram/src/resources/firestore_methods.dart';
import 'package:instagram/src/resources/storage_methods.dart';
import 'package:image/image.dart';

class PostProvider {
  PostProvider({
    required this.storage,
    required this.comments,
    required this.likes,
    required this.bookmarks,
    required this.activities,
  });
  final _firestore = FirebaseFirestore.instance;
  final StorageMethods storage;
  final CommentProvider comments;
  final LikeProvider likes;
  final BookmarkProvider bookmarks;
  final ActivityProvider activities;

  Future<List<Post>> fetch({
    required int limit,
    User? byUser,
    Post? cursor,
  }) async {
    Timestamp? timestamp;
    if (cursor != null) {
      timestamp = Timestamp.fromDate(cursor.date);
    }
    final snapshot = await _firestore
        .collection('posts')
        .where('uid', isEqualTo: byUser?.uid)
        .where('date', isLessThan: timestamp)
        .orderBy('date', descending: true)
        .limit(limit)
        .get();

    return snapshot.docs.map((e) => Post.fromJson(e.data())).toList();
  }

  Future<Post?> get({required String postId}) async {
    final snapshot = await _firestore.collection('posts').doc(postId).get();

    if (snapshot.exists) {
      return Post.fromJson(snapshot.data()!);
    }
    return null;
  }

  Future<Post> add(Post obj) async {
    final photo = await storage.uploadImageData(
      Uint8List.fromList(encodePng(obj.postImage!)),
      'posts',
      obj.postId,
    );

    obj = obj.copyWith(postUrl: photo.url);

    final batch = _firestore.batch();
    final post = _firestore.collection('posts').doc(obj.postId);
    final data = obj.toJson();
    data['date'] = FieldValue.serverTimestamp();
    batch.set(post, data);

    batch.update(_firestore.collection('users').doc(obj.uid), {
      'postCount': FieldValue.increment(1),
    });

    log('add post: ${obj.postId}');
    await batch.commit();
    return obj;
  }

  Future<void> delete({
    required Post post,
  }) async {
    log('delete post: $post.postId');

    final batch = _firestore.batch();
    await FirestoreMethods.deleteCollection(
        batch, _firestore.collection('posts').doc(post.postId), 'comments');
    await FirestoreMethods.deleteCollection(
        batch, _firestore.collection('posts').doc(post.postId), 'likeCount');
    await FirestoreMethods.deleteCollection(
        batch, _firestore.collection('posts').doc(post.postId), 'commentCount');
    await activities.clear(batch, postId: post.postId);

    likes.set(batch,
        uid: post.uid, postId: post.postId, value: false, ignoreCount: true);
    bookmarks.set(batch, uid: post.uid, postId: post.postId, value: false);
    activities.clear(batch, postId: post.postId);

    batch.update(_firestore.collection('users').doc(post.uid), {
      'postCount': FieldValue.increment(-1),
    });
    batch.delete(_firestore.collection('posts').doc(post.postId));
    await batch.commit();
    await storage.delete('posts', post.postId);
  }

  Future<void> setLike({
    required Post post,
    required String uid,
    required bool value,
  }) async {
    final batch = _firestore.batch();
    likes.set(batch, uid: uid, postId: post.postId, value: value);
    if (value) {
      activities.add(batch,
          postId: post.postId,
          fromUid: uid,
          toUid: post.uid,
          type: 'like',
          data: {
            'postUrl': post.postUrl,
          });
    }

    await batch.commit();
  }

  Future<void> setBookmark({
    required String uid,
    required Post post,
    required bool value,
  }) async {
    final batch = _firestore.batch();
    if (value) {
      bookmarks.set(
        batch,
        uid: uid,
        postId: post.postId,
        postUrl: post.postUrl,
        value: value,
      );
    } else {
      bookmarks.set(
        batch,
        uid: uid,
        postId: post.postId,
        value: value,
      );
    }
    await batch.commit();
  }

  Future<Comment> addComment({
    required Post post,
    required String uid,
    required String text,
  }) async {
    final batch = _firestore.batch();
    final comment = comments.add(batch,
        postId: post.postId, fromUid: uid, toUid: post.uid, text: text);
    activities.add(batch,
        postId: post.postId,
        fromUid: uid,
        toUid: post.uid,
        type: 'comment',
        data: {
          'postUrl': post.postUrl,
          'text': text,
        });
    await batch.commit();
    return comment;
  }
}
