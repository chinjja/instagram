import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:instagram/src/activity/models/activity_data.dart';
import 'package:instagram/src/repo/models/activity.dart';
import 'package:instagram/src/repo/models/post.dart';
import 'package:instagram/src/repo/models/user.dart';
import 'package:instagram/src/resources/firestore_methods.dart';
import 'package:rxdart/rxdart.dart';
part 'activity_event.dart';

part 'activity_state.dart';

class ActivityBloc extends Bloc<ActivityEvent, ActivityState> {
  final FirestoreMethods _methods;
  bool _isFetching = false;
  final _limit = 15;
  User auth;

  ActivityBloc(
    FirestoreMethods methods, {
    required this.auth,
  })  : _methods = methods,
        super(const ActivityState()) {
    on<ActivityFetched>(
      (event, emit) async {
        if (state.hasReachedMax || _isFetching) return;
        _isFetching = true;
        try {
          late List<ActivityData> list;
          if (state.status == ActivityStatus.initial) {
            emit(state.copyWith(status: ActivityStatus.loading));
            list = await _fetch();
          } else if (state.list.isNotEmpty) {
            list = await _fetch(cursor: state.list.last.activity);
          }
          emit(state.copyWith(
            status: ActivityStatus.success,
            list: [
              ...state.list,
              ...list,
            ],
            hasReachedMax: list.length < _limit,
          ));
        } finally {
          _isFetching = false;
        }
      },
    );

    on<ActivityDeleted>(
      (event, emit) {
        _methods.activities.delete(activityId: event.activity.activityId);
        final copy = state.list
            .where((e) => e.activity.activityId != event.activity.activityId)
            .toList();
        emit(state.copyWith(status: ActivityStatus.success, list: copy));
      },
    );

    on<ActivityRefresh>(
      (event, emit) {
        emit(const ActivityState());
        add(const ActivityFetched());
      },
    );
  }

  Future<List<ActivityData>> _fetch({Activity? cursor}) async {
    final data = await _methods.activities.fetch(
      toUid: auth.uid,
      cursor: cursor,
      limit: _limit,
    );
    return await _map(data);
  }

  Future<ActivityData> get(Activity item) async {
    return ActivityData(
      activity: item,
      fromUid: (await _methods.users.get(uid: item.fromUid))!,
      toUid: (await _methods.users.get(uid: item.toUid))!,
    );
  }

  Future<List<ActivityData>> _map(List<Activity> list) async {
    final streams = list.map((post) {
      return get(post).asStream();
    }).toList();
    return await Rx.concatEager(streams).toList();
  }

  Future<Post?> getPost({required String postId}) {
    return _methods.posts.get(postId: postId);
  }
}
