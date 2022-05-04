import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:instagram/src/repo/models/model.dart';
import 'package:instagram/src/post/models/models.dart';
import 'package:instagram/src/resources/firestore_methods.dart';
import 'package:rxdart/rxdart.dart';

part 'post_state.dart';

class PostCubit extends Cubit<PostState> {
  PostCubit(
    this._methods, {
    required this.auth,
    this.byUser,
    this.showActions = false,
    this.fixed,
  }) : super(const PostState());
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

  void create(Post post) async {
    final copy = [
      PostData(
        isCreating: true,
        post: post,
      ),
      ...state.posts
    ];
    emit(state.copyWith(status: PostStatus.success, posts: copy));

    final data = await get(await _methods.posts.add(post));
    final index = state.posts.indexWhere((p) => p.post.postId == post.postId);
    final copy2 = [...state.posts];
    copy2[index] = data;
    emit(state.copyWith(status: PostStatus.success, posts: copy2));
  }

  void delete(PostData data) async {
    final index = state.posts.indexWhere(
      (p) => p.post.postId == data.post.postId,
    );
    if (index != -1) {
      final cpy1 = [...state.posts];
      final post = cpy1[index];
      cpy1[index] = post.copyWith(isDeleting: true);
      emit(state.copyWith(posts: cpy1));
      await _methods.posts.delete(post: data.post);
      final copy =
          state.posts.where((p) => p.post.postId != data.post.postId).toList();
      emit(state.copyWith(posts: copy));
    }
  }

  Future<void> refresh() async {
    if (fixed != null) return;

    emit(state.copyWith(
      status: PostStatus.loading,
      posts: [],
      hasReachedMax: false,
    ));
    await _fetch();
  }

  void fetch() async {
    if (state.hasReachedMax || _isFetching) return;
    _isFetching = true;
    try {
      if (state.status == PostStatus.initial) {
        await refresh();
      } else if (state.posts.isNotEmpty) {
        await _fetch(cursor: state.posts.last.post);
      }
    } finally {
      await Future.delayed(const Duration(milliseconds: 100));
      _isFetching = false;
    }
  }

  Future<void> _fetch({Post? cursor}) async {
    final data = await _methods.posts.fetch(
      byUser: byUser,
      cursor: cursor,
      limit: limit,
    );
    final posts = await _map(data);
    emit(state.copyWith(
      status: PostStatus.success,
      posts: [
        ...state.posts,
        ...posts,
      ],
      hasReachedMax: posts.length < limit,
    ));
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
