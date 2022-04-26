// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChatUser _$ChatUserFromJson(Map<String, dynamic> json) => ChatUser(
      uid: json['uid'] as String,
      date: const TimestampConverter().fromJson(json['date'] as Timestamp),
    );

Map<String, dynamic> _$ChatUserToJson(ChatUser instance) => <String, dynamic>{
      'uid': instance.uid,
      'date': const TimestampConverter().toJson(instance.date),
    };
