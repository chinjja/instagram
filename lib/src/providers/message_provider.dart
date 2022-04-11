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
      datePublished: Timestamp.now(),
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

  Stream<Message?> last({required String chatId, Timestamp? timestamp}) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .where('datePublished', isGreaterThan: timestamp)
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
    final unsubscription =
        last(chatId: chatId, timestamp: timestamp).listen((event) async {
      if (event != null) {
        final list = await _subjects[chatId]!.first;
        _subjects[chatId]!.add([event, ...list]);
      }
    });
    return unsubscription;
  }

  Stream<List<Message>> lasts({required String chatId}) {
    return _subjects[chatId]!;
  }
}
