part of 'message_bloc.dart';

abstract class MessageEvent extends Equatable {
  const MessageEvent();
  @override
  List<Object?> get props => [];
}

class MessageSubscripted extends MessageEvent {
  final Chat chat;
  const MessageSubscripted({required this.chat});
  @override
  List<Object?> get props => [chat];
}

class MessageFetched extends MessageEvent {
  const MessageFetched();
}

class MessageSend extends MessageEvent {
  final String text;
  const MessageSend({required this.text});
  @override
  List<Object?> get props => [text];
}
