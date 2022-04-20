import 'package:equatable/equatable.dart';
import 'package:instagram/src/repo/models/model.dart';

class PostData extends Equatable {
  final User user;
  final Post post;
  final int likeCount;
  final int commentCount;
  final bool isLiked;
  final bool isBookmarked;

  const PostData({
    required this.user,
    required this.post,
    required this.likeCount,
    required this.commentCount,
    required this.isLiked,
    required this.isBookmarked,
  });

  @override
  List<Object?> get props => [
        user,
        post,
        likeCount,
        commentCount,
        isLiked,
        isBookmarked,
      ];

  PostData copyWith({
    User? user,
    Post? post,
    int? likeCount,
    int? commentCount,
    bool? isLiked,
    bool? isBookmarked,
  }) {
    return PostData(
      user: user ?? this.user,
      post: post ?? this.post,
      likeCount: likeCount ?? this.likeCount,
      commentCount: commentCount ?? this.commentCount,
      isLiked: isLiked ?? this.isLiked,
      isBookmarked: isBookmarked ?? this.isBookmarked,
    );
  }
}
