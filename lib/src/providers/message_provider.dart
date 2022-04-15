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

  final _latestChat = <String, BehaviorSubject<Message?>>{};
  final _latestSubs = <String, StreamSubscription>{};

  Stream<Message?> latest({required String chatId}) {
    return _latestChat.putIfAbsent(chatId, () {
      final subject = BehaviorSubject<Message?>();

      _latestSubs[chatId] = _latest(chatId: chatId).listen((event) {
        subject.add(event);
      });
      return subject;
    });
  }

  void cancelLatest({required String chatId}) {
    _latestSubs[chatId]?.cancel();
    _latestSubs.remove(chatId);
    _latestChat[chatId]?.close();
    _latestChat.remove(chatId);
  }

  void cancelAllLatest() {
    for (final e in _latestChat.entries) {
      _latestSubs[e.key]?.cancel();
      e.value.close();
    }
    _latestSubs.clear();
    _latestChat.clear();
  }

  Stream<Message?> _latest({required String chatId}) {
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

  final _subjects = <String, BehaviorSubject<List<Message>>>{};

  StreamSubscription listenLasts(
      {required String chatId, required Timestamp timestamp}) {
    _subjects[chatId] = BehaviorSubject.seeded([]);
    final unsubscription = latest(chatId: chatId).listen((event) async {
      if (event != null) {
        if (event.date.compareTo(timestamp) > 0) {
          final list = await _subjects[chatId]!.first;
          _subjects[chatId]!.add([event, ...list]);
        }
      }
    });
    return unsubscription;
  }

  Stream<List<Message>> lasts({required String chatId}) {
    return _subjects[chatId]!;
  }
}
