import 'package:equatable/equatable.dart';
import 'package:instagram/src/repo/models/model.dart';

class PostData extends Equatable {
  final bool isCreating;
  final bool isDeleting;
  final User? user;
  final Post post;
  final int likeCount;
  final int commentCount;
  final bool isLiked;
  final bool isBookmarked;

  const PostData({
    this.isCreating = false,
    this.isDeleting = false,
    this.user,
    required this.post,
    this.likeCount = 0,
    this.commentCount = 0,
    this.isLiked = false,
    this.isBookmarked = false,
  });

  @override
  List<Object?> get props => [
        isCreating,
        isDeleting,
        user,
        post,
        likeCount,
        commentCount,
        isLiked,
        isBookmarked,
      ];

  PostData copyWith({
    bool? isCreating,
    bool? isDeleting,
    User? user,
    Post? post,
    int? likeCount,
    int? commentCount,
    bool? isLiked,
    bool? isBookmarked,
  }) {
    return PostData(
      isCreating: isCreating ?? this.isCreating,
      isDeleting: isDeleting ?? this.isDeleting,
      user: user ?? this.user,
      post: post ?? this.post,
      likeCount: likeCount ?? this.likeCount,
      commentCount: commentCount ?? this.commentCount,
      isLiked: isLiked ?? this.isLiked,
      isBookmarked: isBookmarked ?? this.isBookmarked,
    );
  }
}
