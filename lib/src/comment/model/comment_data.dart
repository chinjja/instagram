import 'package:equatable/equatable.dart';
import 'package:instagram/src/repo/models/model.dart';

class CommentData extends Equatable {
  final User commentUser;
  final Comment comment;

  const CommentData({
    required this.commentUser,
    required this.comment,
  });

  CommentData copyWith({
    User? commentUser,
    Comment? comment,
  }) {
    return CommentData(
      commentUser: commentUser ?? this.commentUser,
      comment: comment ?? this.comment,
    );
  }

  @override
  List<Object?> get props => [commentUser, comment];
}
