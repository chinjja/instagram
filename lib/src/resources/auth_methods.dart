import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:instagram/src/resources/firestore_methods.dart';
import 'package:instagram/src/utils/utils.dart';

class AuthMethods {
  AuthMethods({
    required this.firestore,
  });
  final _auth = FirebaseAuth.instance;
  final FirestoreMethods firestore;

  String? get currentUid => _auth.currentUser?.uid;

  Future<UserCredential?> signInWithGoogle(BuildContext context) async {
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
      if (user == null) {
        return null;
      }
      await firestore.users.create(credential);
      return credential;
    } catch (e) {
      showSnackbar(context, e.toString());
      return null;
    }
  }

  Future<void> signOut([BuildContext? context]) async {
    await _auth.signOut();
    if (context != null) {
      Navigator.popUntil(context, (route) => route.settings.name == '/');
    }
  }
}
