part of 'home_cubit.dart';

enum HomeStatus {
  nav,
  chat,
}

enum NavStatus {
  feed,
  search,
  activity,
  bookmark,
  profile,
}

extension NavEnumX<T extends NavStatus> on Iterable<T> {
  NavStatus byIndex(int index) {
    switch (index) {
      case 0:
        return NavStatus.feed;
      case 1:
        return NavStatus.search;
      case 2:
        return NavStatus.activity;
      case 3:
        return NavStatus.bookmark;
      case 4:
        return NavStatus.profile;
      default:
        throw Exception('invalid index: $index');
    }
  }
}

class HomeState extends Equatable {
  final HomeStatus status;
  final NavStatus nav;

  const HomeState({
    this.status = HomeStatus.nav,
    this.nav = NavStatus.feed,
  });

  HomeState copyWith({
    HomeStatus? status,
    NavStatus? nav,
  }) {
    return HomeState(
      status: status ?? this.status,
      nav: nav ?? this.nav,
    );
  }

  @override
  List<Object?> get props => [status, nav];
}
