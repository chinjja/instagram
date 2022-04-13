import 'dart:developer';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:instagram/src/models/activities.dart';
import 'package:instagram/src/models/bookmarks.dart';
import 'package:instagram/src/models/my_post.dart';
import 'package:instagram/src/models/user.dart' as model;
import 'package:instagram/src/providers/activity_provider.dart';
import 'package:instagram/src/providers/bookmark_provider.dart';
import 'package:instagram/src/providers/my_post_provider.dart';
import 'package:instagram/src/resources/firestore_methods.dart';
import 'package:instagram/src/resources/storage_methods.dart';
import 'package:rxdart/rxdart.dart';

class UserProvider {
  UserProvider({
    required this.storage,
    required this.activityProvider,
    required this.bookmarkProvider,
    required this.myPostProvider,
  });
  final _firestore = FirebaseFirestore.instance;
  final StorageMethods storage;
  final ActivityProvider activityProvider;
  final BookmarkProvider bookmarkProvider;
  final MyPostProvider myPostProvider;
  final _cache = <String, model.User>{};

  Stream<List<model.User>> search({
    required String username,
    required int limit,
  }) {
    return _firestore
        .collection('users')
        .where('username', isGreaterThanOrEqualTo: username)
        .limit(limit)
        .snapshots()
        .flatMap((e) => Stream.fromIterable(e.docs)
            .map((event) => model.User.fromSnapshot(event))
            .toList()
            .asStream())
        .doOnError((_, e) => log(e.toString()));
  }

  Stream<List<model.User>> all({required List<String> uids}) {
    return FirestoreMethods.buffer(
        uids,
        (List<String> uid) => _firestore
            .collection('users')
            .where('uid', whereIn: uid)
            .snapshots()
            .flatMap((e) => Stream.fromIterable(e.docs)
                .map((event) => model.User.fromSnapshot(event))
                .doOnData((e) => _cache[e.uid] = e)
                .toList()
                .asStream())
            .doOnError((_, e) => log(e.toString())));
  }

  model.User? get({required String uid}) {
    return _cache[uid];
  }

  Stream<model.User> at({required String uid}) {
    return _firestore
        .collection('users')
        .doc(uid)
        .snapshots()
        .where((doc) => doc.data() != null)
        .map((doc) => model.User.fromSnapshot(doc))
        .doOnData((e) => _cache[e.uid] = e)
        .doOnError((_, e) => log(e.toString()));
  }

  Future<void> follow({
    required String uid,
    required String to,
    required bool follow,
  }) async {
    final batch = _firestore.batch();
    if (follow) {
      log('unfollow user: $uid -> $to');
      batch.update(_firestore.collection('users').doc(uid), {
        'following': FieldValue.arrayUnion([to]),
      });
      batch.update(_firestore.collection('users').doc(to), {
        'followers': FieldValue.arrayUnion([uid]),
      });
    } else {
      log('follow user: $uid -> $to');
      batch.update(_firestore.collection('users').doc(uid), {
        'following': FieldValue.arrayRemove([to]),
      });
      batch.update(_firestore.collection('users').doc(to), {
        'followers': FieldValue.arrayRemove([uid]),
      });
    }
    await batch.commit();
  }

  Future<void> update(
    model.User user, {
    Uint8List? photo,
    String? username,
    String? state,
    String? website,
  }) async {
    final data = <String, Object?>{};
    if (photo != null) {
      final result = await storage.uploadImageData(
        photo,
        'profile/photo',
        user.uid,
      );
      data['photoUrl'] = result.url;
    }
    if (username != null) {
      data['username'] = username;
    }
    if (state != null) {
      data['state'] = state;
    }
    if (website != null) {
      data['website'] = website;
    }
    log('update user: ${user.uid}');
    await _firestore.collection('users').doc(user.uid).update(data);
  }

  Future<bool> create(UserCredential credential) async {
    final user = credential.user!;
    final data = await _firestore
        .collection('users')
        .where('uid', isEqualTo: user.uid)
        .get();
    if (data.docs.isEmpty) {
      log('create user: ${user.uid}');
      final batch = _firestore.batch();
      batch.set(
          _firestore.collection('users').doc(user.uid),
          model.User(
            email: user.email!,
            uid: user.uid,
            photoUrl: user.photoURL,
            username: user.displayName ?? user.email!,
            following: [],
            followers: [],
          ).toJson());

      activityProvider.create(batch, uid: user.uid);
      bookmarkProvider.create(batch, id: user.uid);
      myPostProvider.create(batch, uid: user.uid);
      await batch.commit();
      return true;
    }
    return false;
  }

  Stream<Activities> activities({required String uid}) {
    return activityProvider.at(uid: uid);
  }

  Future<void> bookmark(
      {required String postId,
      required String postUrl,
      required String uid}) async {
    await bookmarkProvider.bookmark(postId: postId, postUrl: postUrl, id: uid);
  }

  Future<void> unbookmark({required String postId, required String uid}) async {
    await bookmarkProvider.unbookmark(postId: postId, id: uid);
  }

  Stream<Bookmarks> bookmarks({required String uid}) {
    return bookmarkProvider.at(id: uid);
  }

  void addPost(
    WriteBatch batch, {
    required String postId,
    required String postUrl,
    required String uid,
  }) {
    myPostProvider.add(batch, postId: postId, postUrl: postUrl, uid: uid);
  }

  void removePost(
    WriteBatch batch, {
    required String postId,
    required String uid,
  }) {
    myPostProvider.remove(batch, postId: postId, uid: uid);
  }

  Stream<MyPosts> posts({required String uid}) {
    return myPostProvider.at(uid: uid);
  }
}
