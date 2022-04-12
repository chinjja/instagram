import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:instagram/src/models/activity.dart';

class Activities {
  final String uid;
  final List<Activity> list;

  const Activities({
    required this.uid,
    required this.list,
  });

  Map<String, dynamic> toJson() => {
        'uid': uid,
        'list': list.map((e) => e.toJson()).toList(),
      };

  static Activities fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    final list = <Activity>[];
    for (final json in data['list']) {
      list.add(Activity.fromJson(json));
    }
    return Activities(
      uid: data['uid'],
      list: list,
    );
  }
}
