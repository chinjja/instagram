part of 'chat_bloc.dart';

enum ChatStatus {
  initial,
  loading,
  success,
  failure,
}

class ChatState extends Equatable {
  final ChatStatus status;
  final List<ChatData> list;

  const ChatState({
    this.status = ChatStatus.initial,
    this.list = const [],
  });

  ChatState copyWith({
    ChatStatus? status,
    List<ChatData>? list,
  }) {
    return ChatState(
      status: status ?? this.status,
      list: list ?? this.list,
    );
  }

  @override
  List<Object?> get props => [
        status,
        list,
      ];
}
