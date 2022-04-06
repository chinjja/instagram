import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String email;
  final String uid;
  final String username;
  final String? state;
  final String? photoUrl;
  final String? token;

  const User({
    required this.email,
    required this.uid,
    this.photoUrl,
    required this.username,
    this.state,
    this.token,
  });

  Map<String, dynamic> toJson() => {
        'username': username,
        'state': state,
        'uid': uid,
        'email': email,
        'photoUrl': photoUrl,
        'token': token,
      };

  static User fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    return User(
      username: data['username'],
      state: data['state'],
      uid: data['uid'],
      email: data['email'],
      photoUrl: data['photoUrl'],
      token: data['token'],
    );
  }
}
