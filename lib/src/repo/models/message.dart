import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:instagram/src/repo/models/converter/timerstamp_converter.dart';
import 'package:json_annotation/json_annotation.dart';

part 'message.g.dart';

@JsonSerializable()
class Message extends Equatable {
  final String messageId;
  final String chatId;
  final String uid;
  final String text;
  @TimestampConverter()
  final DateTime date;

  const Message({
    required this.messageId,
    required this.chatId,
    required this.uid,
    required this.text,
    required this.date,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    if (json['date'] == null) {
      json['date'] = Timestamp.now();
    }
    return _$MessageFromJson(json);
  }
  Map<String, dynamic> toJson() => _$MessageToJson(this);

  @override
  List<Object?> get props => [messageId, chatId, uid, text, date];
}
