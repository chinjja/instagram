import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:instagram/src/repo/models/converter/timerstamp_converter.dart';
import 'package:json_annotation/json_annotation.dart';

part 'chat.g.dart';

@JsonSerializable()
class Chat extends Equatable {
  final String chatId;
  final List<String> users;
  final bool group;
  final String? title;
  final String? owner;
  final String? photoUrl;
  final String? tag;
  @TimestampConverter()
  final DateTime date;

  const Chat({
    required this.chatId,
    required this.users,
    required this.group,
    required this.title,
    required this.owner,
    required this.photoUrl,
    required this.tag,
    required this.date,
  });

  factory Chat.fromJson(Map<String, dynamic> json) => _$ChatFromJson(json);
  Map<String, dynamic> toJson() => _$ChatToJson(this);

  @override
  List<Object?> get props => [
        chatId,
        users,
        group,
        title,
        owner,
        photoUrl,
        tag,
        date,
      ];
}
