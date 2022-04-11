import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String messageId;
  final String chatId;
  final String uid;
  final String text;
  final Timestamp datePublished;

  const Message({
    required this.messageId,
    required this.chatId,
    required this.uid,
    required this.text,
    required this.datePublished,
  });

  Map<String, dynamic> toJson() => {
        'messageId': messageId,
        'chatId': chatId,
        'uid': uid,
        'text': text,
        'datePublished': datePublished,
      };

  static Message fromSnapshot(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data()!;
    return Message(
      messageId: data['messageId'],
      chatId: data['chatId'],
      uid: data['uid'],
      text: data['text'],
      datePublished: data['datePublished'],
    );
  }
}
