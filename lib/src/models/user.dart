import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String email;
  final String uid;
  final String username;
  final String? state;
  final String? website;
  final String? photoUrl;
  final List<String> following;
  final List<String> followers;

  const User({
    required this.email,
    required this.uid,
    this.photoUrl,
    required this.username,
    this.state,
    this.website,
    required this.following,
    required this.followers,
  });

  bool isFollowers({required String uid}) {
    return followers.contains(uid);
  }

  bool isFollowing({required String uid}) {
    return following.contains(uid);
  }

  Map<String, dynamic> toJson() => {
        'username': username,
        'state': state,
        'website': website,
        'uid': uid,
        'email': email,
        'photoUrl': photoUrl,
        'following': following,
        'followers': followers,
      };

  static User fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    return User(
      username: data['username'],
      state: data['state'],
      website: data['website'],
      uid: data['uid'],
      email: data['email'],
      photoUrl: data['photoUrl'],
      following: List.castFrom(data['following'] ?? []),
      followers: List.castFrom(data['followers'] ?? []),
    );
  }
}
