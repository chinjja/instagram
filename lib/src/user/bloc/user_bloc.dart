import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:instagram/src/repo/models/model.dart';
import 'package:instagram/src/resources/firestore_methods.dart';

part 'user_event.dart';
part 'user_state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final FirestoreMethods _methods;
  final _limit = 6;
  var _isFetching = false;

  UserBloc(
    FirestoreMethods methods, {
    required User auth,
  })  : _methods = methods,
        super(UserState(auth: auth)) {
    on<UserLoaded>(
      (event, emit) async {
        if (state.status != UserStatus.initial) return;

        emit(state.copyWith(
          status: UserStatus.loading,
          user: event.user,
        ));

        final loadUser = await _methods.users.get(
          uid: event.user.uid,
          force: true,
        ) as User;
        late User loadAuth;
        if (loadUser.uid == state.auth.uid) {
          loadAuth = loadUser;
        } else {
          loadAuth = await _methods.users.get(
            uid: state.auth.uid,
            force: true,
          ) as User;
        }
        emit(state.copyWith(
          status: UserStatus.success,
          user: loadUser,
          auth: loadAuth,
          followersCount: await _methods.users.getFollowersCount(
            uid: event.user.uid,
          ),
          followingCount: loadUser.following.length,
          postCount: loadUser.postCount,
          isFollowers: await _methods.users.isFollowers(
            to: auth.uid,
            uid: event.user.uid,
          ),
          isFollowing: loadAuth.following.contains(loadUser.uid),
        ));

        final list = await _methods.posts.fetch(
          byUser: state.user!,
          limit: _limit,
        );
        emit(state.copyWith(
          posts: list,
          hasReachedMax: list.length < _limit,
        ));
      },
    );

    on<UserPostFetch>(
      (event, emit) async {
        if (state.hasReachedMax || _isFetching) return;
        _isFetching = true;
        try {
          final list = await _methods.posts.fetch(
            byUser: state.user!,
            cursor: state.posts.last,
            limit: _limit,
          );
          final copy = [...state.posts, ...list];
          emit(state.copyWith(
            status: UserStatus.success,
            posts: copy,
            hasReachedMax: list.length < _limit,
          ));
        } finally {
          _isFetching = false;
        }
      },
    );

    on<UserRefresh>(
      (event, emit) {
        final user = state.user;
        if (user == null) return;
        emit(state.copyWith(status: UserStatus.initial));
        add(UserLoaded(user: user));
      },
    );

    on<UserToggleFollowing>(
      (event, emit) async {
        final user = state.user;
        if (user == null || user.uid == state.auth.uid) return;

        final following = await _methods.users.toggleFollowing(
          uid: state.auth.uid,
          to: user.uid,
        );

        if (following) {
          emit(state.copyWith(
            followersCount: state.followersCount + 1,
            isFollowing: true,
          ));
        } else {
          emit(state.copyWith(
            followersCount: state.followersCount - 1,
            isFollowing: false,
          ));
        }
      },
    );

    on<UserProfileUpdated>(
      (event, emit) async {
        emit(state.copyWith(
          user: event.user,
        ));
      },
    );
  }
}
