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

  static User fromJson(Map<String, dynamic> json) {
    return User(
      username: json['username'],
      state: json['state'],
      website: json['website'],
      uid: json['uid'],
      email: json['email'],
      photoUrl: json['photoUrl'],
      following: List.castFrom(json['following'] ?? []),
      followers: List.castFrom(json['followers'] ?? []),
    );
  }
}
