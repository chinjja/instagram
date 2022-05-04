import 'dart:async';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:instagram/src/repo/models/model.dart';
import 'package:rxdart/rxdart.dart';
import 'package:uuid/uuid.dart';

class MessageProvider {
  MessageProvider();
  final _firestore = FirebaseFirestore.instance;

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
      date: DateTime.now(),
    );
    final data = message.toJson();
    data['date'] = FieldValue.serverTimestamp();
    log('create message: $messageId');
    await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .doc(messageId)
        .set(data);
    return message;
  }

  Future<List<Message>> fetch({
    required String chatId,
    required int limit,
    Message? cursor,
  }) async {
    Timestamp? timestamp;
    if (cursor != null) {
      timestamp = Timestamp.fromDate(cursor.date);
    }
    final snapshot = await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .where('date', isLessThan: timestamp)
        .orderBy('date', descending: true)
        .limit(limit)
        .get();
    return snapshot.docs.map((doc) => Message.fromJson(doc.data())).toList();
  }

  Stream<Message?> latest({required String chatId}) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('date', descending: true)
        .limit(1)
        .snapshots()
        .flatMap((snapshot) => Stream.fromIterable(snapshot.docs)
            .map((doc) => Message.fromJson(doc.data()))
            .cast<Message?>()
            .defaultIfEmpty(null)
            .first
            .asStream());
  }
}
