// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Post _$PostFromJson(Map<String, dynamic> json) => Post(
      description: json['description'] as String,
      uid: json['uid'] as String,
      postId: json['postId'] as String?,
      date: const TimestampConverter().fromJson(json['date'] as Timestamp),
      postUrl: json['postUrl'] as String?,
      aspectRatio: (json['aspectRatio'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$PostToJson(Post instance) => <String, dynamic>{
      'description': instance.description,
      'uid': instance.uid,
      'postId': instance.postId,
      'date': const TimestampConverter().toJson(instance.date),
      'postUrl': instance.postUrl,
      'aspectRatio': instance.aspectRatio,
    };
