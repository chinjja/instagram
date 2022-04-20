// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
      email: json['email'] as String,
      uid: json['uid'] as String,
      photoUrl: json['photoUrl'] as String?,
      username: json['username'] as String,
      state: json['state'] as String?,
      website: json['website'] as String?,
      following:
          (json['following'] as List<dynamic>).map((e) => e as String).toList(),
      followers:
          (json['followers'] as List<dynamic>).map((e) => e as String).toList(),
    );

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
      'email': instance.email,
      'uid': instance.uid,
      'username': instance.username,
      'state': instance.state,
      'website': instance.website,
      'photoUrl': instance.photoUrl,
      'following': instance.following,
      'followers': instance.followers,
    };
