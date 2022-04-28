part of 'user_bloc.dart';

enum UserStatus {
  initial,
  loading,
  success,
  failure,
}

class UserState extends Equatable {
  final UserStatus status;
  final int postCount;
  final int followingCount;
  final int followersCount;
  final List<Post> posts;
  final bool hasReachedMax;
  final User? user;
  final User auth;
  final bool isFollowing;
  final bool isFollowers;

  const UserState({
    this.status = UserStatus.initial,
    this.postCount = 0,
    this.followersCount = 0,
    this.followingCount = 0,
    this.posts = const [],
    this.hasReachedMax = false,
    this.user,
    required this.auth,
    this.isFollowers = false,
    this.isFollowing = false,
  });

  bool get isOwner {
    if (user == null) return false;
    return auth.uid == user!.uid;
  }

  UserState copyWith({
    UserStatus? status,
    int? postCount,
    int? followingCount,
    int? followersCount,
    List<Post>? posts,
    bool? hasReachedMax,
    User? user,
    User? auth,
    bool? isFollowers,
    bool? isFollowing,
  }) {
    return UserState(
      status: status ?? this.status,
      postCount: postCount ?? this.postCount,
      followersCount: followersCount ?? this.followersCount,
      followingCount: followingCount ?? this.followingCount,
      posts: posts ?? this.posts,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      user: user ?? this.user,
      auth: auth ?? this.auth,
      isFollowers: isFollowers ?? this.isFollowers,
      isFollowing: isFollowing ?? this.isFollowing,
    );
  }

  @override
  List<Object?> get props => [
        status,
        postCount,
        followersCount,
        followingCount,
        posts,
        hasReachedMax,
        user,
        auth,
        isFollowers,
        isFollowing,
      ];
}
