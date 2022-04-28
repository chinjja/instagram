part of 'search_bloc.dart';

enum SearchStatus {
  initial,
  loading,
  success,
  failure,
}

class SearchState extends Equatable {
  final SearchStatus status;
  final List<User> list;
  final bool hasReachedMax;
  final String username;

  const SearchState({
    this.status = SearchStatus.initial,
    this.list = const [],
    this.hasReachedMax = false,
    this.username = '',
  });

  List<User> get filtered {
    if (username.isEmpty) return list;
    return list.where((e) => e.username.startsWith(username)).toList();
  }

  SearchState copyWith({
    SearchStatus? status,
    List<User>? list,
    bool? hasReachedMax,
    String? username,
  }) {
    return SearchState(
      status: status ?? this.status,
      list: list ?? this.list,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      username: username ?? this.username,
    );
  }

  @override
  List<Object?> get props => [status, list, hasReachedMax, username];
}
