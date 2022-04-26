import 'package:instagram/src/repo/models/model.dart';

class ChatInfo {
  final bool group;
  final List<User> others;

  const ChatInfo({required this.group, required this.others});
}
