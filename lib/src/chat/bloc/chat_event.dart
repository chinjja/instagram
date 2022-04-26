part of 'chat_bloc.dart';

abstract class ChatEvent extends Equatable {
  const ChatEvent();

  @override
  List<Object?> get props => [];
}

class ChatSubscriptionRequested extends ChatEvent {}

class ChatDeleted extends ChatEvent {
  final Chat chat;
  const ChatDeleted({required this.chat});
}
