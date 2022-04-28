import 'dart:developer';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:instagram/src/repo/models/user.dart' as model;
import 'package:instagram/src/resources/firestore_methods.dart';
import 'package:instagram/src/resources/storage_methods.dart';
import 'package:rxdart/rxdart.dart';

class UserProvider {
  static const maxDistribution = 5;

  UserProvider({
    required this.storage,
  });
  final _firestore = FirebaseFirestore.instance;
  final StorageMethods storage;
  final _cache = <String, model.User>{};

  Future<model.User> getCurrentUser() async {
    final user = await get(uid: currentUid);
    return user!;
  }

  String get currentUid => FirebaseAuth.instance.currentUser!.uid;

  Future<List<model.User>> list() async {
    final snapshot = await _firestore.collection('users').get();

    final list =
        snapshot.docs.map((e) => model.User.fromJson(e.data())).toList();
    for (final user in list) {
      _cache[user.uid] = user;
    }
    return list;
  }

  Stream<List<model.User>> all({required List<String> uids}) {
    return FirestoreMethods.buffer(
        uids,
        (List<String> uid) => _firestore
            .collection('users')
            .where('uid', whereIn: uid)
            .snapshots()
            .flatMap((snapshot) => Stream.fromIterable(snapshot.docs)
                .map((doc) => model.User.fromJson(doc.data()))
                .doOnData((e) => _cache[e.uid] = e)
                .toList()
                .asStream())
            .doOnError((_, e) => log(e.toString())));
  }

  Future<model.User?> get({required String uid, bool force = false}) async {
    final user = _cache[uid];
    if (!force && user != null) return user;
    final snapshot = await _firestore.collection('users').doc(uid).get();
    if (snapshot.exists) {
      return _cache[uid] = model.User.fromJson(snapshot.data()!);
    }
    return null;
  }

  Stream<model.User> at({required String uid}) {
    return _firestore
        .collection('users')
        .doc(uid)
        .snapshots()
        .where((doc) => doc.data() != null)
        .map((doc) => model.User.fromJson(doc.data()!))
        .doOnData((e) => _cache[e.uid] = e)
        .doOnError((_, e) => log(e.toString()));
  }

  Future<bool> toggleFollowing({
    required String uid,
    required String to,
  }) async {
    final batch = _firestore.batch();
    final follow = await isFollowers(uid: uid, to: to);
    if (!follow) {
      log('unfollow user: $uid -> $to');
      batch.update(_firestore.collection('users').doc(uid), {
        'following': FieldValue.arrayUnion([to]),
      });
      batch.set(
          _firestore
              .collection('users')
              .doc(to)
              .collection('followers')
              .doc(uid),
          {
            'uid': uid,
          });
      batch.set(
          _firestore
              .collection('users')
              .doc(to)
              .collection('followers-count')
              .doc(math.Random().nextInt(maxDistribution).toString()),
          {'count': FieldValue.increment(1)},
          SetOptions(merge: true));
    } else {
      log('follow user: $uid -> $to');
      batch.update(_firestore.collection('users').doc(uid), {
        'following': FieldValue.arrayRemove([to]),
      });
      batch.delete(_firestore
          .collection('users')
          .doc(to)
          .collection('followers')
          .doc(uid));
      batch.set(
          _firestore
              .collection('users')
              .doc(to)
              .collection('followers-count')
              .doc(math.Random().nextInt(maxDistribution).toString()),
          {'count': FieldValue.increment(-1)},
          SetOptions(merge: true));
    }
    await batch.commit();
    return !follow;
  }

  Future<bool> isFollowers({
    required String uid,
    required String to,
  }) async {
    final snapshot = await _firestore
        .collection('users')
        .doc(to)
        .collection('followers')
        .doc(uid)
        .get();
    return snapshot.exists;
  }

  Future<List<String>> fetchFollowers(
      {required String uid, required int limit, User? cursor}) async {
    final followers = await _firestore
        .collection('users')
        .doc(uid)
        .collection('followers')
        .where('uid', isGreaterThan: cursor?.uid)
        .orderBy('uid')
        .limit(limit)
        .get();

    return followers.docs.map((e) => e['uid'] as String).toList();
  }

  Future<int> getFollowersCount({required String uid}) async {
    final snapshot = await _firestore
        .collection('users')
        .doc(uid)
        .collection('followers-count')
        .get();
    int count = 0;
    for (final doc in snapshot.docs) {
      count += doc['count'] as int;
    }
    return count;
  }

  Future<model.User> update(
    model.User user, {
    Uint8List? photo,
    String? username,
    String? state,
    String? website,
  }) async {
    final data = <String, String>{};
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
    _cache.remove(user.uid);

    return model.User(
      email: user.email,
      uid: user.uid,
      photoUrl: data['photoUrl'] ?? user.photoUrl,
      username: data['username'] ?? user.username,
      state: data['state'] ?? user.state,
      website: data['website'] ?? user.website,
      following: [...user.following],
      postCount: user.postCount,
    );
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
            following: const [],
            postCount: 0,
          ).toJson());

      await batch.commit();
      return true;
    }
    return false;
  }
}
