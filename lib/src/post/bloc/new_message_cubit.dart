import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:instagram/src/auth/bloc/auth_cubit.dart';
import 'package:instagram/src/resources/firestore_methods.dart';
import 'package:rxdart/rxdart.dart';

class NewMessageCubit extends Cubit<bool> {
  NewMessageCubit(this.authBloc, this._methods) : super(false) {
    Rx.merge([
      authBloc.stream,
      Stream.value(authBloc.state),
    ]).listen((e) {
      final uid = e.user?.uid;
      if (uid == null) {
        _subscription?.cancel();
        _subscription = null;
      } else {
        _subscription ??= _methods.chats
            .chats(uid: uid)
            .flatMap((chats) =>
                Stream.fromIterable(chats).flatMap((chat) => Rx.combineLatest2(
                      _methods.messages.latest(chatId: chat.chatId),
                      _methods.chats.userOrNull(chatId: chat.chatId, uid: uid),
                      (a, b) => (chatId: chat.chatId, message: a, my: b),
                    )))
            .scan((accumulated, value, index) {
              final message = value.message;
              final my = value.my;
              if (message == null || my == null) {
                accumulated[value.chatId] = false;
              } else {
                accumulated[value.chatId] = message.date.isAfter(my.date);
              }
              return accumulated;
            }, <String, bool>{})
            .map((e) => e.values.any((x) => x))
            .listen(
              (event) {
                emit(event);
              },
            );
      }
    });
  }
  final AuthCubit authBloc;
  final FirestoreMethods _methods;
  StreamSubscription? _subscription;

  @override
  Future<void> close() {
    _subscription?.cancel();
    _subscription = null;
    return super.close();
  }
}
