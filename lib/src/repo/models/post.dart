
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:image/image.dart';
import 'package:instagram/src/repo/models/converter/timerstamp_converter.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';

part 'post.g.dart';

@JsonSerializable()
class Post extends Equatable {
  final String description;
  final String uid;
  final String postId;
  @TimestampConverter()
  final DateTime date;
  final String? postUrl;
  final double aspectRatio;

  @JsonKey(ignore: true)
  final Image? postImage;

  Post({
    required this.description,
    required this.uid,
    String? postId,
    required this.date,
    this.postUrl,
    double? aspectRatio,
    this.postImage,
  })  : assert(
          postId == null || postId.isNotEmpty,
          'id can not be null and should be empty',
        ),
        assert(postImage != null || postUrl != null),
        assert(postImage != null || aspectRatio != null),
        postId = postId ?? const Uuid().v4(),
        aspectRatio = aspectRatio ?? (postImage!.width / postImage.height);

  factory Post.fromJson(Map<String, dynamic> json) {
    if (json['date'] == null) {
      json['date'] = Timestamp.now();
    }
    return _$PostFromJson(json);
  }
  Map<String, dynamic> toJson() => _$PostToJson(this);

  Post copyWith({
    String? description,
    String? uid,
    DateTime? date,
    String? postUrl,
    double? aspectRatio,
  }) {
    return Post(
      description: description ?? this.description,
      uid: uid ?? this.uid,
      date: date ?? this.date,
      postUrl: postUrl ?? this.postUrl,
      aspectRatio: aspectRatio ?? this.aspectRatio,
      postId: postId,
      postImage: postImage,
    );
  }

  @override
  List<Object?> get props => [
        description,
        uid,
        postId,
        date,
        postUrl,
        aspectRatio,
        postImage,
      ];
}
