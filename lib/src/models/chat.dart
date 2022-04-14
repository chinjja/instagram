import 'package:cloud_firestore/cloud_firestore.dart';

class Chat {
  final String chatId;
  final List<String> users;
  final bool group;
  final String? title;
  final String? owner;
  final String? photoUrl;
  final String? tag;
  final Timestamp datePublished;

  const Chat({
    required this.chatId,
    required this.users,
    required this.group,
    required this.title,
    required this.owner,
    required this.photoUrl,
    required this.tag,
    required this.datePublished,
  });

  Map<String, dynamic> toJson() => {
        'chatId': chatId,
        'users': users,
        'group': group,
        'title': title,
        'owner': owner,
        'photoUrl': photoUrl,
        'tag': tag,
        'datePublished': datePublished,
      };

  static Chat fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    return Chat(
      chatId: data['chatId'],
      users: List.castFrom(data['users']),
      group: data['group'],
      title: data['title'],
      owner: data['owner'],
      photoUrl: data['photoUrl'],
      tag: data['tag'],
      datePublished: data['datePublished'],
    );
  }
}
