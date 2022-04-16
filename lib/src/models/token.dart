import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:instagram/src/models/converter/timerstamp_converter.dart';
import 'package:json_annotation/json_annotation.dart';

part 'token.g.dart';

@JsonSerializable()
class Token {
  final String tokenId;
  @TimestampConverter()
  final DateTime date;

  const Token({
    required this.tokenId,
    required this.date,
  });

  factory Token.fromJson(Map<String, dynamic> json) => _$TokenFromJson(json);
  Map<String, dynamic> toJson() => _$TokenToJson(this);
}
