// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'activity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Activity _$ActivityFromJson(Map<String, dynamic> json) => Activity(
      activityId: json['activityId'] as String,
      postId: json['postId'] as String,
      type: json['type'] as String,
      fromUid: json['fromUid'] as String,
      toUid: json['toUid'] as String,
      date: const TimestampConverter().fromJson(json['date'] as Timestamp),
      data: json['data'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$ActivityToJson(Activity instance) => <String, dynamic>{
      'activityId': instance.activityId,
      'postId': instance.postId,
      'type': instance.type,
      'fromUid': instance.fromUid,
      'toUid': instance.toUid,
      'date': const TimestampConverter().toJson(instance.date),
      'data': instance.data,
    };
