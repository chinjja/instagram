import 'package:equatable/equatable.dart';
import 'package:instagram/src/repo/models/activity.dart';
import 'package:instagram/src/repo/models/user.dart';

class ActivityData extends Equatable {
  final Activity activity;
  final User fromUid;
  final User toUid;

  const ActivityData({
    required this.activity,
    required this.fromUid,
    required this.toUid,
  });
  @override
  List<Object?> get props => [activity, fromUid, toUid];
}
