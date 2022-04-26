import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit() : super(const HomeState());

  void nav([NavStatus nav = NavStatus.feed]) {
    emit(state.copyWith(status: HomeStatus.nav, nav: nav));
  }

  void chat() {
    emit(state.copyWith(status: HomeStatus.chat));
  }

  void feed() {
    if (state.status != HomeStatus.nav) return;
    emit(state.copyWith(nav: NavStatus.feed));
  }

  void search() {
    if (state.status != HomeStatus.nav) return;
    emit(state.copyWith(nav: NavStatus.search));
  }

  void activity() {
    if (state.status != HomeStatus.nav) return;
    emit(state.copyWith(nav: NavStatus.activity));
  }

  void bookmark() {
    if (state.status != HomeStatus.nav) return;
    emit(state.copyWith(nav: NavStatus.bookmark));
  }

  void profile() {
    if (state.status != HomeStatus.nav) return;
    emit(state.copyWith(nav: NavStatus.profile));
  }
}
