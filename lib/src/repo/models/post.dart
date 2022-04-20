import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:instagram/src/repo/models/converter/timerstamp_converter.dart';
import 'package:json_annotation/json_annotation.dart';

part 'post.g.dart';

@JsonSerializable()
class Post extends Equatable {
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

  @override
  List<Object?> get props => [
        description,
        uid,
        postId,
        date,
        postUrl,
        aspectRatio,
      ];
}

class PostCreateDto {
  final String uid;
  final String description;
  final Uint8List file;
  const PostCreateDto({
    required this.uid,
    required this.description,
    required this.file,
  });
}
