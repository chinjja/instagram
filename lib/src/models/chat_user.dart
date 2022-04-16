import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:instagram/src/converter/timerstamp_converter.dart';
import 'package:json_annotation/json_annotation.dart';

part 'chat_user.g.dart';

@JsonSerializable()
class ChatUser {
  final String uid;
  @TimestampConverter()
  final DateTime date;

  const ChatUser({
    required this.uid,
    required this.date,
  });

  factory ChatUser.fromJson(Map<String, dynamic> json) =>
      _$ChatUserFromJson(json);
  Map<String, dynamic> toJson() => _$ChatUserToJson(this);
}
