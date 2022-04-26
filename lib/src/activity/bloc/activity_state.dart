part of 'activity_bloc.dart';

enum ActivityStatus {
  initial,
  loading,
  success,
  failure,
}

class ActivityState extends Equatable {
  final ActivityStatus status;
  final List<ActivityData> list;
  final bool hasReachedMax;

  const ActivityState({
    this.status = ActivityStatus.initial,
    this.list = const [],
    this.hasReachedMax = false,
  });

  ActivityState copyWith({
    ActivityStatus? status,
    List<ActivityData>? list,
    bool? hasReachedMax,
  }) {
    return ActivityState(
      status: status ?? this.status,
      list: list ?? this.list,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }

  @override
  List<Object?> get props => [status, list, hasReachedMax];
}
