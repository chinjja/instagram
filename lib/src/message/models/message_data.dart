import 'package:equatable/equatable.dart';
import 'package:instagram/src/repo/models/model.dart';

class MessageData extends Equatable {
  final Message message;
  final User user;

  const MessageData({
    required this.user,
    required this.message,
  });

  @override
  List<Object?> get props => [user, message];
}
