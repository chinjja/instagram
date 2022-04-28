import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:instagram/src/repo/models/model.dart';
import 'package:instagram/src/resources/firestore_methods.dart';

part 'search_event.dart';
part 'search_state.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final FirestoreMethods _methods;
  SearchBloc(FirestoreMethods methods)
      : _methods = methods,
        super(const SearchState()) {
    on<SearchUsernameChanged>(
      (event, emit) {
        emit(state.copyWith(username: event.username));
      },
    );

    on<SearchRefresh>(
      (event, emit) async {
        emit(state.copyWith(status: SearchStatus.loading));

        final list = await _methods.users.list();
        emit(state.copyWith(status: SearchStatus.success, list: list));
      },
    );
  }
}
