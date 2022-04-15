import 'package:cloud_firestore/cloud_firestore.dart';

class ChatUser {
  final String uid;
  final Timestamp date;

  const ChatUser({
    required this.uid,
    required this.date,
  });

  Map<String, dynamic> toJson() => {
        'uid': uid,
        'date': date,
      };

  static ChatUser fromJson(Map<String, dynamic> json) {
    return ChatUser(
      uid: json['uid'],
      date: json['date'] ?? Timestamp.now(),
    );
  }

  ChatUser copyWith({Timestamp? date}) {
    return ChatUser(uid: uid, date: date ?? this.date);
  }
}
