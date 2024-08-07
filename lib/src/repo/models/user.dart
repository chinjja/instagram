import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

@JsonSerializable()
class User extends Equatable {
  final String email;
  final String uid;
  final String username;
  final String? state;
  final String? website;
  final String? photoUrl;
  final List<String> following;
  final int postCount;
  final Map<String, int> fcmToken;

  const User({
    required this.email,
    required this.uid,
    this.photoUrl,
    required this.username,
    this.state,
    this.website,
    required this.following,
    required this.postCount,
    this.fcmToken = const {},
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);

  @override
  List<Object?> get props => [
        email,
        uid,
        username,
        state,
        website,
        photoUrl,
        following,
        postCount,
        fcmToken,
      ];
}
