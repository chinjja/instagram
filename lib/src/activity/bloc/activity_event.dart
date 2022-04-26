part of 'activity_bloc.dart';

abstract class ActivityEvent extends Equatable {
  const ActivityEvent();
  @override
  List<Object?> get props => [];
}

class ActivityFetched extends ActivityEvent {
  const ActivityFetched();
}

class ActivityDeleted extends ActivityEvent {
  final Activity activity;
  const ActivityDeleted({required this.activity});
  @override
  List<Object?> get props => [activity];
}

class ActivityRefresh extends ActivityEvent {
  const ActivityRefresh();
}
