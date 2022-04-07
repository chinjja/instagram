import 'dart:developer';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:instagram/src/models/activity.dart';
import 'package:instagram/src/models/bookmark.dart';
import 'package:instagram/src/models/comment.dart';
import 'package:instagram/src/models/like.dart';
import 'package:instagram/src/models/post.dart';
import 'package:instagram/src/models/user.dart' as model;
import 'package:instagram/src/resources/storage_methods.dart';
import 'package:rxdart/rxdart.dart';
import 'package:uuid/uuid.dart';

class FirestoreMethods {
  FirestoreMethods({required this.storage});
  final _firestore = FirebaseFirestore.instance;
  final StorageMethods storage;

  Stream<Post> post({required String postId}) {
    return _firestore
        .collection('posts')
        .doc(postId)
        .snapshots()
        .map((doc) => Post.fromSnapshot(doc));
  }

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

  Stream<List<Post>> postsByPostId(List<String> postIdList) {
    return _firestore
        .collection('posts')
        .where('postId', whereIn: postIdList)
        .snapshots()
        .flatMap((e) => Stream.fromIterable(e.docs)
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
      final photo = await storage.uploadImageData(
        file,
        'posts',
        postId,
      );

      final post = Post(
        description: description,
        uid: user.uid,
        postId: postId,
        datePublished: DateTime.now(),
        postUrl: photo.url,
        width: photo.width,
        height: photo.height,
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

  Stream<List<Like>> likes({required Post post}) {
    return _firestore
        .collection('posts')
        .doc(post.postId)
        .collection('likes')
        .snapshots()
        .flatMap((snapshot) => Stream.fromIterable(snapshot.docs)
            .map((doc) => Like.fromSnapshot(doc))
            .toList()
            .asStream());
  }

  Stream<bool> isLiked({required String postId, required String uid}) {
    return _firestore
        .collection('posts')
        .doc(postId)
        .collection('likes')
        .doc(uid)
        .snapshots()
        .map((event) => event.exists);
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
          transaction.set(
            ref,
            Like(
              uid: user.uid,
              postId: post.postId,
              to: post.uid,
              datePublished: DateTime.now(),
            ).toJson(),
          );
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
          commentId: commentId,
          postId: post.postId,
          uid: user.uid,
          to: post.uid,
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
      final postRef = _firestore.collection('posts').doc(post.postId);
      _deleteCollection(postRef, 'likes');
      _deleteCollection(postRef, 'bookmarks');
      _deleteCollection(postRef, 'comments');
      await postRef.delete();
    } catch (e) {
      log(e.toString());
    }
  }

  Future<void> _deleteCollection(DocumentReference ref, String id) async {
    final collectionRef = ref.collection(id);
    final snapshot = await collectionRef.get();
    for (final doc in snapshot.docs) {
      collectionRef.doc(doc.id).delete();
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

  Stream<List<Activity>> activities({required String to}) {
    final comments = _firestore
        .collectionGroup('comments')
        .where('to', isEqualTo: to)
        .orderBy('datePublished', descending: true)
        .limit(50)
        .snapshots()
        .flatMap((snapshot) => Stream.fromIterable(snapshot.docs)
            .map((doc) => Comment.fromSnapshot(doc))
            .toList()
            .asStream());

    final likes = _firestore
        .collectionGroup('likes')
        .where('to', isEqualTo: to)
        .orderBy('datePublished', descending: true)
        .limit(50)
        .snapshots()
        .flatMap((snapshot) => Stream.fromIterable(snapshot.docs)
            .map((doc) => Like.fromSnapshot(doc))
            .toList()
            .asStream());

    return Rx.combineLatest2(comments, likes, (List<Comment> a, List<Like> b) {
      final list = <Activity>[
        ...a.where((e) => e.uid != to),
        ...b.where((e) => e.uid != to),
      ];
      list.sort(
        (a, b) => b.datePublished.compareTo(a.datePublished),
      );
      return list;
    });
  }

  Future<void> bookmarkPost(
      {required String postId, required String uid}) async {
    final bookmarks = _firestore
        .collection('posts')
        .doc(postId)
        .collection('bookmarks')
        .doc(uid);
    final bookmark = await bookmarks.get();
    if (bookmark.exists) {
      await bookmarks.delete();
    } else {
      await bookmarks.set(
        Bookmark(
          uid: uid,
          postId: postId,
        ).toJson(),
      );
    }
  }

  Stream<bool> isBookmark({required String postId, required String uid}) {
    return _firestore
        .collection('posts')
        .doc(postId)
        .collection('bookmarks')
        .doc(uid)
        .snapshots()
        .map((event) => event.exists);
  }

  Stream<List<Bookmark>> bookmarks({required String uid}) {
    return _firestore
        .collectionGroup('bookmarks')
        .where('uid', isEqualTo: uid)
        .snapshots()
        .flatMap((snapshot) => Stream.fromIterable(snapshot.docs)
            .map((doc) => Bookmark.fromSnapshot(doc))
            .toList()
            .asStream());
  }
}
