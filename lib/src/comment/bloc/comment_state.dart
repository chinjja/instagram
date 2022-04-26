part of 'comment_cubit.dart';

enum CommentStatus {
  initial,
  loading,
  success,
  failure,
}

class CommentState extends Equatable {
  final CommentStatus status;
  final List<CommentData> list;
  final bool hasReachedMax;

  const CommentState({
    this.status = CommentStatus.initial,
    this.list = const [],
    this.hasReachedMax = false,
  });

  CommentState copyWith({
    CommentStatus? status,
    List<CommentData>? list,
    bool? hasReachedMax,
  }) {
    return CommentState(
      status: status ?? this.status,
      list: list ?? this.list,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }

  @override
  List<Object?> get props => [status, list, hasReachedMax];
}
