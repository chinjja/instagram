import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:instagram/src/repo/models/converter/timerstamp_converter.dart';
import 'package:json_annotation/json_annotation.dart';

part 'comment.g.dart';

@JsonSerializable()
class Comment extends Equatable {
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

  factory Comment.fromJson(Map<String, dynamic> json) {
    if (json['date'] == null) {
      json['date'] = Timestamp.now();
    }
    return _$CommentFromJson(json);
  }
  Map<String, dynamic> toJson() => _$CommentToJson(this);

  @override
  List<Object?> get props => [commentId, uid, to, date, text];
}
