part of 'add_chat_bloc.dart';

abstract class AddChatEvent extends Equatable {
  const AddChatEvent();
  @override
  List<Object?> get props => [];
}

class AddChatSubmitted extends AddChatEvent {}

class AddChatFetchRequested extends AddChatEvent {
  final User auth;
  const AddChatFetchRequested({required this.auth});
  @override
  List<Object?> get props => [auth];
}

class AddChatFriendToggled extends AddChatEvent {
  final User friend;
  const AddChatFriendToggled({required this.friend});
  @override
  List<Object?> get props => [friend];
}
