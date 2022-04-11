import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:instagram/src/models/chat_user.dart';

class Chat {
  final String chatId;
  final Map<String, ChatUser> members;
  final bool group;
  final String? title;
  final String? owner;
  final String? photoUrl;
  final String? tag;
  final Timestamp datePublished;

  const Chat({
    required this.chatId,
    required this.members,
    required this.group,
    required this.title,
    required this.owner,
    required this.photoUrl,
    required this.tag,
    required this.datePublished,
  });

  Map<String, dynamic> toJson() => {
        'chatId': chatId,
        'members': members.map((key, value) => MapEntry(key, value.toJson())),
        'group': group,
        'title': title,
        'owner': owner,
        'photoUrl': photoUrl,
        'tag': tag,
        'datePublished': datePublished,
      };

  static Chat fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    final members = data['members']
        .map((key, json) => MapEntry(key, ChatUser.fromJson(json)));
    return Chat(
      chatId: data['chatId'],
      members: Map.castFrom(members),
      group: data['group'],
      title: data['title'],
      owner: data['owner'],
      photoUrl: data['photoUrl'],
      tag: data['tag'],
      datePublished: data['datePublished'],
    );
  }
}
