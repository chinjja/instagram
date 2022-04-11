import 'dart:developer';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:instagram/src/models/post.dart';
import 'package:instagram/src/models/user.dart' as model;
import 'package:instagram/src/providers/comment_provider.dart';
import 'package:instagram/src/resources/firestore_methods.dart';
import 'package:instagram/src/resources/storage_methods.dart';
import 'package:instagram/src/utils/utils.dart';
import 'package:rxdart/rxdart.dart';
import 'package:uuid/uuid.dart';

class PostProvider {
  PostProvider({required this.storage, required this.commentProvider});
  final _firestore = FirebaseFirestore.instance;
  final StorageMethods storage;
  final CommentProvider commentProvider;

  Stream<Post> at({required String postId}) {
    return _firestore
        .collection('posts')
        .doc(postId)
        .snapshots()
        .map((doc) => Post.fromSnapshot(doc));
  }

  Stream<List<Post>> all({required List<String> uids}) {
    return FirestoreMethods.buffer(
        uids,
        (List<String> uid) => _firestore
            .collection('posts')
            .where('uid', whereIn: uid)
            .orderBy('datePublished', descending: true)
            .snapshots()
            .flatMap((e) => Stream.fromIterable(e.docs)
                .map((data) => Post.fromSnapshot(data))
                .toList()
                .asStream()));
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
    );

    final batch = _firestore.batch();
    final data = serverTimestamp(post.toJson());
    batch.set(_firestore.collection('posts').doc(postId), data);
    if (description.isNotEmpty) {
      commentProvider.create(
          post: post, uid: user.uid, text: description, batch: batch);
    }

    log('create post: $postId');
    await batch.commit();
    return post;
  }

  Future<void> delete({required String postId}) async {
    final batch = _firestore.batch();
    final postRef = _firestore.collection('posts').doc(postId);
    FirestoreMethods.deleteCollection(batch, postRef, 'likes');
    FirestoreMethods.deleteCollection(batch, postRef, 'bookmarks');
    FirestoreMethods.deleteCollection(batch, postRef, 'comments');
    batch.delete(postRef);
    await storage.delete('posts', postId);
    await batch.commit();
  }
}
