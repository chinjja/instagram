// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'token.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Token _$TokenFromJson(Map<String, dynamic> json) => Token(
      tokenId: json['tokenId'] as String,
      date: const TimestampConverter().fromJson(json['date'] as Timestamp),
    );

Map<String, dynamic> _$TokenToJson(Token instance) => <String, dynamic>{
      'tokenId': instance.tokenId,
      'date': const TimestampConverter().toJson(instance.date),
    };
