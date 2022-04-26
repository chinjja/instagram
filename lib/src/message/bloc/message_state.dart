part of 'message_bloc.dart';

enum MessageStatus {
  initial,
  loading,
  success,
  failure,
}

class MessageState extends Equatable {
  final MessageStatus status;
  final Chat? chat;
  final List<MessageData> messages;
  final bool hasReachedMax;
  final List<User> members;

  const MessageState({
    this.status = MessageStatus.initial,
    this.chat,
    this.messages = const [],
    this.hasReachedMax = false,
    this.members = const [],
  });

  MessageState copyWith({
    MessageStatus? status,
    Chat? chat,
    List<MessageData>? messages,
    bool? hasReachedMax,
    List<User>? members,
  }) {
    return MessageState(
      status: status ?? this.status,
      chat: chat ?? this.chat,
      messages: messages ?? this.messages,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      members: members ?? this.members,
    );
  }

  @override
  List<Object?> get props => [status, chat, messages, hasReachedMax, members];
}
