import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:instagram/src/models/converter/timerstamp_converter.dart';
import 'package:json_annotation/json_annotation.dart';

part 'activity.g.dart';

@JsonSerializable()
class Activity {
  final String activityId;
  final String postId;
  final String type;
  final String fromUid;
  final String toUid;
  @TimestampConverter()
  final DateTime date;
  final Map<String, dynamic> data;

  const Activity({
    required this.activityId,
    required this.postId,
    required this.type,
    required this.fromUid,
    required this.toUid,
    required this.date,
    required this.data,
  });

  factory Activity.fromJson(Map<String, dynamic> json) =>
      _$ActivityFromJson(json);
  Map<String, dynamic> toJson() => _$ActivityToJson(this);
}
