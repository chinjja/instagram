import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'bookmark.g.dart';

@JsonSerializable()
class Bookmark extends Equatable {
  final String postId;
  final String postUrl;

  const Bookmark({
    required this.postId,
    required this.postUrl,
  });

  factory Bookmark.fromJson(Map<String, dynamic> json) =>
      _$BookmarkFromJson(json);
  Map<String, dynamic> toJson() => _$BookmarkToJson(this);

  @override
  List<Object?> get props => [
        postId,
        postUrl,
      ];
}
