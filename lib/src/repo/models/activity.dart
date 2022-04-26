import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:instagram/src/repo/models/converter/timerstamp_converter.dart';
import 'package:json_annotation/json_annotation.dart';

part 'activity.g.dart';

@JsonSerializable()
class Activity extends Equatable {
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

  factory Activity.fromJson(Map<String, dynamic> json) {
    if (json['date'] == null) {
      json['date'] = Timestamp.now();
    }
    return _$ActivityFromJson(json);
  }
  Map<String, dynamic> toJson() => _$ActivityToJson(this);

  @override
  List<Object?> get props => [
        activityId,
        postId,
        type,
        fromUid,
        toUid,
        date,
        data,
      ];
}
