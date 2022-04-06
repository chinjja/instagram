import 'dart:developer';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:instagram/src/models/comment.dart';
import 'package:instagram/src/models/post.dart';
import 'package:instagram/src/models/user.dart' as model;
import 'package:instagram/src/resources/storage_methods.dart';
import 'package:rxdart/rxdart.dart';
import 'package:uuid/uuid.dart';

class FirestoreMethods {
  FirestoreMethods({required this.storage});
  final _firestore = FirebaseFirestore.instance;
  final StorageMethods storage;

  Stream<List<Post>> posts([List<String> uidList = const []]) {
    var query = _firestore
        .collection('posts')
        .orderBy('datePublished', descending: true);
    if (uidList.isNotEmpty) {
      query = query.where('uid', whereIn: uidList);
    }

    return query.snapshots().flatMap((e) => Stream.fromIterable(e.docs)
        .map((data) => Post.fromSnapshot(data))
        .toList()
        .asStream());
  }

  Stream<List<model.User>> users({String username = ''}) {
    return _firestore
        .collection('users')
        .where('username', isGreaterThanOrEqualTo: username)
        .snapshots()
        .flatMap((e) => Stream.fromIterable(e.docs)
            .map((event) => model.User.fromSnapshot(event))
            .toList()
            .asStream());
  }

  Stream<List<model.User>> usersByUidList(List<String> uidList) {
    return _firestore
        .collection('users')
        .where('uid', whereIn: uidList)
        .snapshots()
        .flatMap((e) => Stream.fromIterable(e.docs)
            .map((event) => model.User.fromSnapshot(event))
            .toList()
            .asStream());
  }

  Stream<model.User> user({required String uid}) {
    return _firestore
        .collection('users')
        .doc(uid)
        .snapshots()
        .map((event) => model.User.fromSnapshot(event));
  }

  Stream<List<Comment>> comments(Post post) {
    return _firestore
        .collection('posts')
        .doc(post.postId)
        .collection('comments')
        .orderBy('datePublished')
        .snapshots()
        .flatMap((e) => Stream.fromIterable(e.docs)
            .map((event) => Comment.fromSnapshot(event))
            .toList()
            .asStream());
  }

  Future<String> uploadPost({
    required String description,
    required Uint8List file,
    required model.User user,
  }) async {
    try {
      description = description.trim();
      final postId = const Uuid().v1();
      final photoUrl = await storage.uploadImageData(
        file,
        'posts',
        postId,
      );

      final post = Post(
        description: description,
        uid: user.uid,
        postId: postId,
        datePublished: DateTime.now(),
        postUrl: photoUrl,
      );

      final batch = _firestore.batch();
      batch.set(_firestore.collection('posts').doc(postId), post.toJson());
      if (description.isNotEmpty) {
        postComment(post: post, user: user, text: description, batch: batch);
      }
      await batch.commit();
      return 'success';
    } catch (e) {
      return e.toString();
    }
  }

  Stream<List<String>> likes({required Post post}) {
    return _firestore
        .collection('posts')
        .doc(post.postId)
        .collection('likes')
        .snapshots()
        .flatMap((value) => Stream.fromIterable(value.docs)
            .map((event) => event['uid'] as String)
            .toList()
            .asStream());
  }

  Future<void> likePost({required Post post, required model.User user}) async {
    try {
      final ref = _firestore
          .collection('posts')
          .doc(post.postId)
          .collection('likes')
          .doc(user.uid);
      await _firestore.runTransaction((transaction) async {
        final like = await transaction.get(ref);
        if (like.exists) {
          transaction.delete(ref);
        } else {
          transaction.set(ref, {'uid': user.uid});
        }
      });
    } catch (e) {
      log(e.toString());
    }
  }

  Future<String> postComment({
    required Post post,
    required model.User user,
    required String text,
    WriteBatch? batch,
  }) async {
    try {
      if (text.isNotEmpty) {
        final commentId = const Uuid().v1();
        final comment = Comment(
          id: commentId,
          uid: user.uid,
          text: text,
          datePublished: DateTime.now(),
        );
        final ref = _firestore
            .collection('posts')
            .doc(post.postId)
            .collection('comments')
            .doc(commentId);

        if (batch != null) {
          batch.set(ref, comment.toJson());
        } else {
          await ref.set(comment.toJson());
        }
      }
      return "success";
    } catch (e) {
      return e.toString();
    }
  }

  Future<void> deletePost(Post post) async {
    try {
      await _firestore.collection('posts').doc(post.postId).delete();
    } catch (e) {
      log(e.toString());
    }
  }

  Stream<List<String>> followers({required String uid}) {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('followers')
        .snapshots()
        .flatMap((event) => Stream.fromIterable(event.docs)
            .map((event) => event['uid'] as String)
            .toList()
            .asStream());
  }

  Stream<List<String>> following({required String uid}) {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('following')
        .snapshots()
        .flatMap((event) => Stream.fromIterable(event.docs)
            .map((event) => event['uid'] as String)
            .toList()
            .asStream());
  }

  Future<void> follow({
    required String uid,
    required String to,
  }) async {
    try {
      await _firestore.runTransaction((transaction) async {
        final followers = _firestore
            .collection('users')
            .doc(to)
            .collection('followers')
            .doc(uid);
        final following = _firestore
            .collection('users')
            .doc(uid)
            .collection('following')
            .doc(to);
        final isFollow = await transaction.get(followers);
        if (isFollow.exists) {
          transaction.delete(followers);
          transaction.delete(following);
        } else {
          transaction.set(followers, {'uid': uid});
          transaction.set(following, {'uid': to});
        }
      });
    } catch (e) {
      log(e.toString());
    }
  }

  Future<void> updateUser(
    model.User user, {
    Uint8List? photo,
    String? username,
    String? state,
  }) async {
    final batch = _firestore.batch();
    final ref = _firestore.collection('users').doc(user.uid);
    if (photo != null) {
      final photoUrl = await storage.uploadImageData(
        photo,
        'profile/photo',
        user.uid,
      );
      batch.update(ref, {
        'photoUrl': photoUrl,
      });
    }
    if (username != null) {
      username = username.trim();
      batch.update(ref, {
        'username': username,
      });
    }
    if (state != null) {
      state = state.trim();
      batch.update(ref, {'state': state});
    }
    await batch.commit();
  }

  Future<void> initUser(UserCredential credential) async {
    final user = credential.user!;
    final data = await _firestore
        .collection('users')
        .where('uid', isEqualTo: user.uid)
        .get();
    if (data.docs.isEmpty) {
      log('${user.email} is empty');
      await _firestore.collection('users').doc(user.uid).set(model.User(
            email: user.email!,
            uid: user.uid,
            photoUrl: user.photoURL,
            username: user.displayName ?? user.email!,
          ).toJson());
    }
  }
}
