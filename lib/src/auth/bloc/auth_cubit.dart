import 'dart:developer';

import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:instagram/src/repo/models/model.dart' as model;
import 'package:instagram/src/resources/firestore_methods.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit(this._methods) : super(const AuthState());

  final FirestoreMethods _methods;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  void init() async {
    if (state.status == AuthStatus.unknown) {
      if (FirebaseAuth.instance.currentUser == null) {
        emit(state.copyWith(status: AuthStatus.unauthenticated));
      } else {
        final modelUser = await _methods.users.get(
          uid: FirebaseAuth.instance.currentUser!.uid,
        );
        emit(state.copyWith(
          status: AuthStatus.authenticated,
          user: modelUser,
        ));
      }
    }
  }

  model.User get user => state.user!;

  Future<void> signInWithGoogle() async {
    emit(state.copyWith(status: AuthStatus.authenticating));
    UserCredential credential;
    try {
      if (kIsWeb) {
        final authProvider = GoogleAuthProvider();
        credential = await _auth.signInWithPopup(authProvider);
      } else {
        final googleSignIn = GoogleSignIn();
        final user = await googleSignIn.signIn();
        final auth = await user!.authentication;
        final oauth = GoogleAuthProvider.credential(
          accessToken: auth.accessToken,
          idToken: auth.idToken,
        );
        credential = await _auth.signInWithCredential(oauth);
      }
      final user = credential.user;
      if (user != null) {
        await _methods.users.create(credential);
        final modelUser = await _methods.users.get(uid: user.uid);
        emit(state.copyWith(status: AuthStatus.authenticated, user: modelUser));
        return;
      }
    } catch (e) {
      log(e.toString());
    }
    emit(state.copyWith(status: AuthStatus.unauthenticated, user: null));
  }

  Future<void> signout() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final token = await _methods.fcmProvider.getToken();
      if (token != null) {
        await _methods.users.removeFcmToken(uid: user.uid, token: token);
      }
    }
    await _auth.signOut();
    emit(state.copyWith(status: AuthStatus.unauthenticated, user: null));
  }
}
