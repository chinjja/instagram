import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String messageId;
  final String chatId;
  final String uid;
  final String text;
  final Timestamp date;

  const Message({
    required this.messageId,
    required this.chatId,
    required this.uid,
    required this.text,
    required this.date,
  });

  Map<String, dynamic> toJson() => {
        'messageId': messageId,
        'chatId': chatId,
        'uid': uid,
        'text': text,
        'date': date,
      };

  static Message fromSnapshot(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data()!;
    return Message(
      messageId: data['messageId'],
      chatId: data['chatId'],
      uid: data['uid'],
      text: data['text'],
      date: data['date'],
    );
  }
}
