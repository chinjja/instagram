import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

@JsonSerializable()
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

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);
}
