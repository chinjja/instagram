import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:instagram/src/repo/models/bookmark.dart';
import 'package:instagram/src/repo/models/model.dart';
import 'package:instagram/src/repo/models/user.dart';
import 'package:instagram/src/resources/firestore_methods.dart';

part 'bookmark_state.dart';

class BookmarkCubit extends Cubit<BookmarkState> {
  BookmarkCubit(
    this._methods, {
    required this.auth,
  }) : super(const BookmarkState());
  final limit = 6;
  final FirestoreMethods _methods;
  final User auth;

  bool _isFetching = false;

  Future<Post?> getPost(Bookmark bookmark) {
    return _methods.posts.get(postId: bookmark.postId);
  }

  Future<void> refresh() async {
    final list = await _methods.bookmarks.fetch(
      uid: auth.uid,
      limit: limit,
    );
    emit(state.copyWith(
      status: BookmarkStatus.success,
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
      if (state.status == BookmarkStatus.initial) {
        emit(state.copyWith(status: BookmarkStatus.loading));
        await refresh();
      } else if (state.list.isNotEmpty) {
        emit(state.copyWith(status: BookmarkStatus.fetching));
        final list = await _methods.bookmarks.fetch(
          uid: auth.uid,
          cursor: state.list.last,
          limit: limit,
        );
        emit(state.copyWith(
          status: BookmarkStatus.success,
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
}
