// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'comment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Comment _$CommentFromJson(Map<String, dynamic> json) => Comment(
      commentId: json['commentId'] as String,
      uid: json['uid'] as String,
      to: json['to'] as String,
      date: const TimestampConverter().fromJson(json['date'] as Timestamp),
      text: json['text'] as String,
    );

Map<String, dynamic> _$CommentToJson(Comment instance) => <String, dynamic>{
      'commentId': instance.commentId,
      'uid': instance.uid,
      'to': instance.to,
      'date': const TimestampConverter().toJson(instance.date),
      'text': instance.text,
    };
