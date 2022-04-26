import 'package:equatable/equatable.dart';
import 'package:instagram/src/repo/models/model.dart';

class ChatData extends Equatable {
  final DateTime date;
  final Chat chat;
  final List<User> members;
  final String lastMessage;
  final bool isNew;

  const ChatData({
    required this.date,
    required this.chat,
    required this.members,
    required this.lastMessage,
    required this.isNew,
  });

  @override
  List<Object?> get props => [date, chat, members, lastMessage, isNew];
}
