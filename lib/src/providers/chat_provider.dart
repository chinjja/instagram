import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:instagram/src/models/chat.dart';
import 'package:instagram/src/models/chat_user.dart';
import 'package:instagram/src/providers/message_provider.dart';
import 'package:instagram/src/resources/firestore_methods.dart';
import 'package:instagram/src/resources/storage_methods.dart';
import 'package:instagram/src/utils/utils.dart';
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

    final users = <String, ChatUser>{};
    for (final member in members) {
      users[member] = ChatUser(timestamp: Timestamp.now());
    }
    final chatId = const Uuid().v1();
    final chat = Chat(
      chatId: chatId,
      members: users,
      group: group,
      title: title,
      owner: owner,
      photoUrl: photoUrl,
      tag: group ? null : _tag(members),
      datePublished: Timestamp.now(),
    );
    log('create chat: $chatId');

    await _firestore
        .collection(_chats)
        .doc(chatId)
        .set(serverTimestamp(chat.toJson()));
    return chat;
  }

  Future<void> delete({required String chatId}) async {
    log('delete chat: $chatId');

    await _firestore.collection(_chats).doc(chatId).delete();
  }

  Stream<Chat> at({required String chatId}) {
    return _firestore
        .collection(_chats)
        .doc(chatId)
        .snapshots()
        .map((doc) => Chat.fromSnapshot(doc));
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

  Stream<Chat> findDirectChat({
    required String uid,
    required String to,
  }) {
    return _firestore
        .collection(_chats)
        .where('tag', isEqualTo: _tag([uid, to]))
        .snapshots()
        .flatMap((snapshot) => Stream.fromIterable(snapshot.docs)
            .map((doc) => Chat.fromSnapshot(doc))
            .first
            .asStream());
  }

  Stream<List<Chat>> all({required List<String> chatIds}) {
    return FirestoreMethods.buffer(
        chatIds,
        (List<String> ids) => _firestore
            .collection(_chats)
            .where('chatId', whereIn: ids)
            .snapshots()
            .flatMap((value) => Stream.fromIterable(value.docs)
                .map((doc) => Chat.fromSnapshot(doc))
                .toList()
                .asStream()));
  }

  Stream<List<Chat>> chats({required String uid}) {
    return _firestore
        .collection(_chats)
        .where('members.$uid', isNull: false)
        .snapshots()
        .flatMap((snapshot) => Stream.fromIterable(snapshot.docs)
            .map((doc) => Chat.fromSnapshot(doc))
            .toList()
            .asStream());
  }

  Future<void> checkMessage({required Chat chat, required String uid}) async {
    log('check message: $uid');
    final data = chat.members[uid]!.toJson();
    data['timestamp'] = FieldValue.serverTimestamp();
    await _firestore.collection(_chats).doc(chat.chatId).update({
      'members.$uid': data,
    });
  }
}
