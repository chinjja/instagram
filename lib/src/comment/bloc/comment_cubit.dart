import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:instagram/src/comment/model/comment_data.dart';
import 'package:instagram/src/repo/models/model.dart';
import 'package:instagram/src/resources/firestore_methods.dart';
import 'package:rxdart/rxdart.dart';

part 'comment_state.dart';

class CommentCubit extends Cubit<CommentState> {
  CommentCubit(
    FirestoreMethods methods, {
    required this.auth,
    required this.post,
  })  : _methods = methods,
        super(const CommentState());
  final limit = 15;
  final FirestoreMethods _methods;
  final User auth;
  late final User postUser;
  final Post post;

  bool _isFetching = false;

  void create(String text) async {
    final data = await _methods.posts.addComment(
      post: post,
      uid: auth.uid,
      text: text,
    );
    final list = await _map([data]);
    final copy = [...state.list, ...list];
    emit(state.copyWith(status: CommentStatus.success, list: copy));
  }

  Future<void> refresh() async {
    final data = await _methods.comments.fetch(
      postId: post.postId,
      limit: limit,
    );
    final list = await _map(data);
    emit(state.copyWith(
      status: CommentStatus.success,
      list: list,
      hasReachedMax: list.length < limit,
    ));
  }

  void fetch() async {
    if (state.hasReachedMax) return;
    if (_isFetching) {
      return;
    }
    _isFetching = true;

    try {
      if (state.status == CommentStatus.initial) {
        postUser = (await _methods.users.get(uid: post.uid))!;
        emit(state.copyWith(status: CommentStatus.loading));
        await refresh();
      } else if (state.list.isNotEmpty) {
        final data = await _methods.comments.fetch(
          postId: post.postId,
          cursor: state.list.last.comment,
          limit: limit,
        );
        final list = await _map(data);
        emit(state.copyWith(
          list: [
            ...state.list,
            ...list,
          ],
          hasReachedMax: list.length < limit,
        ));
      }
    } finally {
      _isFetching = false;
    }
  }

  Future<List<CommentData>> _map(List<Comment> list) async {
    final streams = list.map((comment) {
      return Future(
        () async => CommentData(
          comment: comment,
          commentUser: (await _methods.users.get(
            uid: comment.uid,
          ))!,
        ),
      ).asStream();
    }).toList();
    return await Rx.concatEager(streams).toList();
  }
}
