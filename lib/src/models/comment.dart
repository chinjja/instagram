import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:instagram/src/converter/timerstamp_converter.dart';
import 'package:json_annotation/json_annotation.dart';

part 'comment.g.dart';

@JsonSerializable()
class Comment {
  final String commentId;
  final String uid;
  final String to;
  @TimestampConverter()
  final DateTime date;
  final String text;

  const Comment({
    required this.commentId,
    required this.uid,
    required this.to,
    required this.date,
    required this.text,
  });

  factory Comment.fromJson(Map<String, dynamic> json) =>
      _$CommentFromJson(json);
  Map<String, dynamic> toJson() => _$CommentToJson(this);
}
