import 'dart:developer';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:instagram/src/repo/models/user.dart' as model;
import 'package:instagram/src/resources/firestore_methods.dart';
import 'package:instagram/src/resources/storage_methods.dart';
import 'package:rxdart/rxdart.dart';

class UserProvider {
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

  Future<List<model.User>> search({
    required String username,
    required int limit,
  }) async {
    final snapshot = await _firestore
        .collection('users')
        .where('username', isGreaterThanOrEqualTo: username)
        .limit(limit)
        .get();

    return snapshot.docs.map((e) => model.User.fromJson(e.data())).toList();
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

  Future<model.User?> get({required String uid}) async {
    final user = _cache[uid];
    if (user != null) return user;
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
      username: data['username'] ?? user.username,
      state: data['state'] ?? user.state,
      website: data['website'] ?? user.website,
      following: [...user.following],
      followers: [...user.followers],
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
            following: [],
            followers: [],
          ).toJson());

      await batch.commit();
      return true;
    }
    return false;
  }
}
