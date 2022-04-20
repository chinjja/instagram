import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:instagram/src/repo/models/model.dart';
import 'package:instagram/src/post/models/models.dart';
import 'package:instagram/src/resources/firestore_methods.dart';
import 'package:rxdart/rxdart.dart';

part 'post_state.dart';

class PostCubit extends Cubit<PostState> {
  PostCubit(
    FirestoreMethods methods, {
    required this.auth,
    this.byUser,
    this.showActions = false,
    this.fixed,
  })  : _methods = methods,
        super(const PostState());
  final limit = 3;
  final FirestoreMethods _methods;
  final List<Post>? fixed;
  final User auth;
  final User? byUser;
  final bool showActions;

  bool _isFetching = false;

  void toggleLike(PostData data) async {
    final index = state.posts.indexWhere(
      (p) => p.post.postId == data.post.postId,
    );
    if (index != -1) {
      await _methods.posts.setLike(
        post: data.post,
        uid: auth.uid,
        value: !data.isLiked,
      );
      final copy = [...state.posts];
      copy[index] = data.copyWith(isLiked: !data.isLiked);
      emit(state.copyWith(posts: copy));
    }
  }

  void toggleBookmark(PostData data) async {
    final index = state.posts.indexWhere(
      (p) => p.post.postId == data.post.postId,
    );
    if (index != -1) {
      await _methods.posts.setBookmark(
        post: data.post,
        uid: auth.uid,
        value: !data.isBookmarked,
      );
      final copy = [...state.posts];
      copy[index] = data.copyWith(isBookmarked: !data.isBookmarked);
      emit(state.copyWith(posts: copy));
    }
  }

  void create(PostCreateDto dto) async {
    emit(state.copyWith(status: PostStatus.creating));
    final data = await _methods.posts.add(dto);
    final posts = await _map([data]);
    final copy = [...posts, ...state.posts];
    emit(state.copyWith(status: PostStatus.success, posts: copy));
  }

  void delete(PostData data) async {
    final index = state.posts.indexWhere(
      (p) => p.post.postId == data.post.postId,
    );
    if (index != -1) {
      await _methods.posts.delete(post: data.post);
      final copy =
          state.posts.where((p) => p.post.postId != data.post.postId).toList();
      emit(state.copyWith(posts: copy));
    }
  }

  Future<void> refresh() async {
    if (fixed != null) return;

    final data = await _methods.posts.fetch(
      byUser: byUser,
      limit: limit,
    );
    final posts = await _map(data);
    emit(state.copyWith(
      status: PostStatus.success,
      posts: posts,
      hasReachedMax: posts.length < limit,
    ));
  }

  void fetch() async {
    if (state.hasReachedMax) return;
    if (_isFetching) {
      return;
    }
    _isFetching = true;

    try {
      if (state.status == PostStatus.initial) {
        emit(state.copyWith(status: PostStatus.loading));
        if (fixed == null) {
          await refresh();
        } else {
          final posts = await _map(fixed!);
          emit(state.copyWith(
            status: PostStatus.success,
            posts: posts,
            hasReachedMax: true,
          ));
        }
      } else if (state.posts.isNotEmpty) {
        final data = await _methods.posts.fetch(
          byUser: byUser,
          cursor: state.posts.last.post,
          limit: limit,
        );
        final posts = await _map(data);
        emit(state.copyWith(
          posts: [
            ...state.posts,
            ...posts,
          ],
          hasReachedMax: posts.length < limit,
        ));
      }
    } finally {
      _isFetching = false;
    }
  }

  Future<PostData> get(Post post) async {
    return PostData(
      post: post,
      user: (await _methods.users.get(
        uid: post.uid,
      ))!,
      likeCount: await _methods.likes.getCount(
        postId: post.postId,
      ),
      commentCount: await _methods.comments.getCount(
        postId: post.postId,
      ),
      isLiked: await _methods.likes.exists(
        uid: auth.uid,
        postId: post.postId,
      ),
      isBookmarked: await _methods.bookmarks.exists(
        uid: auth.uid,
        postId: post.postId,
      ),
    );
  }

  Future<List<PostData>> _map(List<Post> posts) async {
    final streams = posts.map((post) {
      return get(post).asStream();
    }).toList();
    return await Rx.concatEager(streams).toList();
  }
}
