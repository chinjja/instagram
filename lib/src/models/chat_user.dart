import 'package:cloud_firestore/cloud_firestore.dart';

class ChatUser {
  final Timestamp timestamp;

  const ChatUser({
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
        'timestamp': timestamp,
      };

  static ChatUser fromJson(Map<String, dynamic> json) {
    return ChatUser(
      timestamp: json['timestamp'],
    );
  }

  ChatUser copyWith({Timestamp? timestamp}) {
    return ChatUser(timestamp: timestamp ?? this.timestamp);
  }
}
