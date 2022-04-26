part of 'add_chat_bloc.dart';

enum AddChatStatus {
  initial,
  loading,
  success,
  failure,
}

class AddChatState extends Equatable {
  final AddChatStatus status;
  final AddChatStatus submission;
  final List<User> friends;
  final Set<User> selected;

  const AddChatState({
    this.status = AddChatStatus.initial,
    this.submission = AddChatStatus.initial,
    this.friends = const [],
    this.selected = const <User>{},
  });

  AddChatState copyWith({
    AddChatStatus? status,
    AddChatStatus? submission,
    List<User>? friends,
    Set<User>? selected,
  }) {
    return AddChatState(
      status: status ?? this.status,
      submission: submission ?? this.submission,
      friends: friends ?? this.friends,
      selected: selected ?? this.selected,
    );
  }

  @override
  List<Object?> get props => [status, submission, friends, selected];
}
