// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Message _$MessageFromJson(Map<String, dynamic> json) => Message(
      messageId: json['messageId'] as String,
      chatId: json['chatId'] as String,
      uid: json['uid'] as String,
      text: json['text'] as String,
      date: const TimestampConverter().fromJson(json['date'] as Timestamp),
    );

Map<String, dynamic> _$MessageToJson(Message instance) => <String, dynamic>{
      'messageId': instance.messageId,
      'chatId': instance.chatId,
      'uid': instance.uid,
      'text': instance.text,
      'date': const TimestampConverter().toJson(instance.date),
    };
