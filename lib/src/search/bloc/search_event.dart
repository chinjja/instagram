part of 'search_bloc.dart';

abstract class SearchEvent extends Equatable {
  const SearchEvent();
  @override
  List<Object?> get props => [];
}

class SearchUsernameChanged extends SearchEvent {
  final String username;
  const SearchUsernameChanged({required this.username});
  @override
  List<Object?> get props => [username];
}

class SearchRefresh extends SearchEvent {
  const SearchRefresh();
}
