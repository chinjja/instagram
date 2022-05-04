import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:instagram/src/repo/models/model.dart';
import 'package:instagram/src/resources/firestore_methods.dart';

part 'add_chat_event.dart';
part 'add_chat_state.dart';

class AddChatBloc extends Bloc<AddChatEvent, AddChatState> {
  final FirestoreMethods _methods;
  AddChatBloc(this._methods) : super(const AddChatState()) {
    on<AddChatFetchRequested>(
      (event, emit) async {
        emit(state.copyWith(status: AddChatStatus.loading));
        try {
          final auth =
              await _methods.users.get(uid: event.auth.uid, force: true);
          final friends = <User>[];
          for (final friend in auth?.following ?? <String>[]) {
            final user = await _methods.users.get(uid: friend);
            if (user != null) {
              friends.add(user);
            }
          }
          emit(state.copyWith(status: AddChatStatus.success, friends: friends));
        } catch (e) {
          emit(state.copyWith(status: AddChatStatus.failure));
        }
      },
    );
    on<AddChatSubmitted>(
      (event, emit) {
        if (state.status == AddChatStatus.success) {
          emit(state.copyWith(submission: AddChatStatus.loading));
          if (state.selected.isEmpty) {
            emit(state.copyWith(submission: AddChatStatus.failure));
          } else {
            emit(state.copyWith(submission: AddChatStatus.success));
          }
        }
      },
    );
    on<AddChatFriendToggled>(
      (event, emit) {
        if (state.status == AddChatStatus.success) {
          if (state.selected.contains(event.friend)) {
            final copy = {...state.selected};
            copy.remove(event.friend);
            emit(state.copyWith(status: AddChatStatus.success, selected: copy));
          } else {
            final copy = {...state.selected};
            copy.add(event.friend);
            emit(state.copyWith(status: AddChatStatus.success, selected: copy));
          }
        }
      },
    );
  }
}
