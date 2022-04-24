part of 'post_cubit.dart';

enum PostStatus {
  initial,
  loading,
  success,
  failure,
}

class PostState extends Equatable {
  final PostStatus status;
  final List<PostData> posts;
  final bool hasReachedMax;

  const PostState({
    this.status = PostStatus.initial,
    this.posts = const [],
    this.hasReachedMax = false,
  });

  PostState copyWith({
    PostStatus? status,
    List<PostData>? posts,
    bool? hasReachedMax,
  }) {
    return PostState(
      status: status ?? this.status,
      posts: posts ?? this.posts,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }

  @override
  List<Object?> get props => [
        status,
        posts,
        hasReachedMax,
      ];
}
