import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:instagram/src/models/chat.dart';
import 'package:instagram/src/models/chat_user.dart';
import 'package:instagram/src/providers/message_provider.dart';
import 'package:instagram/src/resources/firestore_methods.dart';
import 'package:instagram/src/resources/storage_methods.dart';
import 'package:rxdart/rxdart.dart';
import 'package:uuid/uuid.dart';

class ChatProvider {
  static const _chats = 'chats';

  ChatProvider({required this.storage, required this.messages});
  final _firestore = FirebaseFirestore.instance;
  final MessageProvider messages;
  final StorageMethods storage;

  Future<Chat> create({
    required Set<String> members,
    String? owner,
    String? title,
    String? photoUrl,
    required bool group,
  }) async {
    if (members.length < 2) {
      throw 'members is greater than 1';
    }

    if (!group) {
      if (members.length != 2) {
        throw 'direct chat requires two member';
      }

      final exists =
          await existsDirectChat(uid: members.first, to: members.last).first;
      if (exists) {
        throw 'direct exists';
      }
    }

    final chatId = const Uuid().v1();
    final chat = Chat(
      chatId: chatId,
      users: members.toList(),
      group: group,
      title: title,
      owner: owner,
      photoUrl: photoUrl,
      tag: group ? null : _tag(members),
      date: DateTime.now(),
    );
    final data = chat.toJson();
    data['date'] = FieldValue.serverTimestamp();

    final batch = _firestore.batch();
    batch.set(_firestore.collection(_chats).doc(chatId), data);
    for (final member in members) {
      _addUser(batch, chat: chat, uid: member);
    }

    log('create chat: $chatId');
    await batch.commit();
    return chat;
  }

  Future<void> delete({required String chatId}) async {
    final batch = _firestore.batch();
    final doc = _firestore.collection('chats').doc(chatId);
    FirestoreMethods.deleteCollection(batch, doc, 'users');
    batch.delete(doc);

    log('delete chat: $chatId');
    await batch.commit();
  }

  Stream<Chat?> at({required String chatId}) {
    return _firestore
        .collection(_chats)
        .doc(chatId)
        .snapshots()
        .where((doc) => doc.data() != null)
        .map((doc) => Chat.fromJson(doc.data()!));
  }

  String _tag(Iterable<String> uids) {
    final list = uids.toList();
    list.sort();
    return list.join('-');
  }

  Stream<bool> existsDirectChat({
    required String uid,
    required String to,
  }) {
    return _firestore
        .collection(_chats)
        .where('tag', isEqualTo: _tag([uid, to]))
        .snapshots()
        .map((event) => event.size == 1)
        .defaultIfEmpty(false);
  }

  Future<Chat?> findDirectChat({
    required String uid,
    required String to,
  }) async {
    final snapshot = await _firestore
        .collection(_chats)
        .where('tag', isEqualTo: _tag([uid, to]))
        .get();

    return snapshot.size == 0 ? null : Chat.fromJson(snapshot.docs[0].data());
  }

  Stream<List<Chat>> all({required List<String> chatIds}) {
    return FirestoreMethods.buffer(
        chatIds,
        (List<String> ids) => _firestore
            .collection(_chats)
            .where('chatId', whereIn: ids)
            .snapshots()
            .flatMap((value) => Stream.fromIterable(value.docs)
                .map((doc) => Chat.fromJson(doc.data()))
                .toList()
                .asStream()));
  }

  Stream<List<Chat>> chats({required String uid}) {
    return _firestore
        .collection(_chats)
        .where('users', arrayContains: uid)
        .snapshots()
        .flatMap((snapshot) => Stream.fromIterable(snapshot.docs)
            .map((doc) => Chat.fromJson(doc.data()))
            .toList()
            .asStream());
  }

  Stream<ChatUser> user({required String chatId, required String uid}) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('users')
        .doc(uid)
        .snapshots()
        .where((snapshot) => snapshot.data() != null)
        .map((snapshot) => ChatUser.fromJson(snapshot.data()!));
  }

  Future<ChatUser?> getUser(
      {required String chatId, required String uid}) async {
    final snapshot = await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('users')
        .doc(uid)
        .get();

    return snapshot.exists ? null : ChatUser.fromJson(snapshot.data()!);
  }

  Future<ChatUser> addUser({
    required Chat chat,
    required String uid,
  }) async {
    final batch = _firestore.batch();
    final user = _addUser(batch, chat: chat, uid: uid);

    batch.update(_firestore.collection('chats').doc(chat.chatId), {
      'users': FieldValue.arrayUnion([uid]),
    });
    await batch.commit();
    return user;
  }

  ChatUser _addUser(
    WriteBatch batch, {
    required Chat chat,
    required String uid,
  }) {
    final user = ChatUser(uid: uid, date: DateTime.now());
    final data = user.toJson();
    data['date'] = FieldValue.serverTimestamp();

    log('add user to chat: $uid');
    batch.set(
        _firestore
            .collection('chats')
            .doc(chat.chatId)
            .collection('users')
            .doc(uid),
        data);

    return user;
  }

  Future<void> removeUser({
    required Chat chat,
    required String uid,
  }) async {
    final batch = _firestore.batch();
    _removeUser(batch, chat: chat, uid: uid);
    batch.update(_firestore.collection('chats').doc(chat.chatId), {
      'users': FieldValue.arrayRemove([uid]),
    });
    await batch.commit();
  }

  void _removeUser(
    WriteBatch batch, {
    required Chat chat,
    required String uid,
  }) async {
    log('add user to chat: $uid');
    batch.delete(_firestore
        .collection('chats')
        .doc(chat.chatId)
        .collection('users')
        .doc(uid));
  }

  Future<void> updateUserTimestamp({
    required Chat chat,
    required String uid,
  }) async {
    log('check message: $uid');
    await _firestore
        .collection(_chats)
        .doc(chat.chatId)
        .collection('users')
        .doc(uid)
        .set({
      'date': FieldValue.serverTimestamp(),
    });
  }
}
