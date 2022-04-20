part of 'bookmark_cubit.dart';

enum BookmarkStatus {
  initial,
  loading,
  success,
  failure,
  fetching,
}

class BookmarkState extends Equatable {
  final BookmarkStatus status;
  final List<Bookmark> list;
  final bool hasReachedMax;

  const BookmarkState({
    this.status = BookmarkStatus.initial,
    this.list = const [],
    this.hasReachedMax = false,
  });

  BookmarkState copyWith({
    BookmarkStatus? status,
    List<Bookmark>? list,
    bool? hasReachedMax,
  }) {
    return BookmarkState(
      status: status ?? this.status,
      list: list ?? this.list,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }

  @override
  List<Object?> get props => [status, list, hasReachedMax];
}
