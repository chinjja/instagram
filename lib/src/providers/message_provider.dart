import 'dart:async';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:instagram/src/models/message.dart';
import 'package:instagram/src/resources/storage_methods.dart';
import 'package:instagram/src/utils/utils.dart';
import 'package:rxdart/rxdart.dart';
import 'package:uuid/uuid.dart';

class MessageProvider {
  MessageProvider({required this.storage});
  final _firestore = FirebaseFirestore.instance;
  final StorageMethods storage;

  Future<Message> send({
    required String chatId,
    required String uid,
    required String text,
  }) async {
    final message = await create(chatId: chatId, uid: uid, text: text);
    return message;
  }

  Future<Message> create({
    required String chatId,
    required String uid,
    required String text,
  }) async {
    text = text.trim();
    if (text.isEmpty) {
      throw 'text must be greater than 0';
    }
    final messageId = const Uuid().v1();
    final message = Message(
      messageId: messageId,
      chatId: chatId,
      uid: uid,
      text: text,
      date: Timestamp.now(),
    );
    final data = serverTimestamp(message.toJson());
    log('create message: $messageId');
    await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .doc(messageId)
        .set(data);
    return message;
  }

  Stream<List<Message>> all({
    required String chatId,
    Timestamp? start,
    Timestamp? end,
    required int limit,
  }) {
    assert(start != null || end != null);
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .where('datePublished', isLessThanOrEqualTo: start)
        .where('datePublished', isGreaterThan: end)
        .orderBy('datePublished', descending: true)
        .limit(limit)
        .snapshots()
        .flatMap((snapshot) => Stream.fromIterable(snapshot.docs)
            .map((doc) => Message.fromSnapshot(doc))
            .toList()
            .asStream());
  }

  Future<List<Message>> list({
    required String chatId,
    Timestamp? start,
    Timestamp? end,
    required int limit,
  }) async {
    assert(start != null || end != null);
    final snapshot = await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .where('datePublished', isLessThanOrEqualTo: start)
        .where('datePublished', isGreaterThan: end)
        .orderBy('datePublished', descending: true)
        .limit(limit)
        .get();
    return snapshot.docs.map((doc) => Message.fromSnapshot(doc)).toList();
  }

  QueryDocumentSnapshot? _latestDocument;
  Future<List<Message>> first({
    required String chatId,
    required int limit,
    required Timestamp start,
  }) async {
    final snapshot = await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .where('datePublished', isLessThanOrEqualTo: start)
        .orderBy('datePublished', descending: true)
        .limit(limit)
        .get();
    _latestDocument = snapshot.size == 0 ? null : snapshot.docs.last;
    return snapshot.docs.map((doc) => Message.fromSnapshot(doc)).toList();
  }

  Future<List<Message>> next({
    required String chatId,
    required int limit,
  }) async {
    final snapshot = await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('datePublished', descending: true)
        .startAfterDocument(_latestDocument!)
        .limit(limit)
        .get();
    _latestDocument = snapshot.size == 0 ? _latestDocument : snapshot.docs.last;
    return snapshot.docs.map((doc) => Message.fromSnapshot(doc)).toList();
  }

  Stream<Message?> latest({required String chatId}) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('datePublished', descending: true)
        .limit(1)
        .snapshots()
        .flatMap((snapshot) => Stream.fromIterable(snapshot.docs)
            .map((doc) => Message.fromSnapshot(doc))
            .cast<Message?>()
            .defaultIfEmpty(null)
            .first
            .asStream());
  }
}
