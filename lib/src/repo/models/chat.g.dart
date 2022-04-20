// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Chat _$ChatFromJson(Map<String, dynamic> json) => Chat(
      chatId: json['chatId'] as String,
      users: (json['users'] as List<dynamic>).map((e) => e as String).toList(),
      group: json['group'] as bool,
      title: json['title'] as String?,
      owner: json['owner'] as String?,
      photoUrl: json['photoUrl'] as String?,
      tag: json['tag'] as String?,
      date: const TimestampConverter().fromJson(json['date'] as Timestamp),
    );

Map<String, dynamic> _$ChatToJson(Chat instance) => <String, dynamic>{
      'chatId': instance.chatId,
      'users': instance.users,
      'group': instance.group,
      'title': instance.title,
      'owner': instance.owner,
      'photoUrl': instance.photoUrl,
      'tag': instance.tag,
      'date': const TimestampConverter().toJson(instance.date),
    };
