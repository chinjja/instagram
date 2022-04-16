import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:instagram/src/converter/timerstamp_converter.dart';
import 'package:json_annotation/json_annotation.dart';

part 'post.g.dart';

@JsonSerializable()
class Post {
  final String description;
  final String uid;
  final String postId;
  @TimestampConverter()
  final DateTime date;
  final String postUrl;
  final double aspectRatio;

  const Post({
    required this.description,
    required this.uid,
    required this.postId,
    required this.date,
    required this.postUrl,
    required this.aspectRatio,
  });

  factory Post.fromJson(Map<String, dynamic> json) => _$PostFromJson(json);
  Map<String, dynamic> toJson() => _$PostToJson(this);
}
