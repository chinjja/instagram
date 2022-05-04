import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:instagram/src/auth/bloc/auth_cubit.dart';
import 'package:instagram/src/message/bloc/message_bloc.dart';
import 'package:instagram/src/message/models/chat_info.dart';
import 'package:instagram/src/repo/models/chat.dart';
import 'package:instagram/src/resources/firestore_methods.dart';
import 'package:instagram/src/message/view/message_card.dart';
import 'package:instagram/src/utils/utils.dart';
import 'package:instagram/src/widgets/send_text_field.dart';
import 'package:instagram/src/widgets/user_list_tile.dart';
import 'package:intl/intl.dart';

class MessagePage extends StatelessWidget {
  static Route route({Chat? chat, ChatInfo? info}) {
    return MaterialPageRoute(builder: (context) {
      return MessagePage(chat: chat, info: info);
    });
  }

  const MessagePage({
    Key? key,
    required this.chat,
    required this.info,
  }) : super(key: key);

  final Chat? chat;
  final ChatInfo? info;

  @override
  Widget build(BuildContext context) {
    final auth = context.select((AuthCubit cubit) => cubit.user);
    return BlocProvider(
      create: (context) {
        final bloc = MessageBloc(
          context.read<FirestoreMethods>(),
          auth: auth,
          info: info,
        );
        if (chat != null) {
          bloc.add(MessageSubscripted(chat: chat!));
        }
        return bloc;
      },
      child: const MessageView(),
    );
  }
}

class MessageView extends StatelessWidget {
  const MessageView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final auth = context.select((AuthCubit cubit) => cubit.user);

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const MessageTitle(),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: BlocBuilder<MessageBloc, MessageState>(
                builder: (context, state) {
                  switch (state.status) {
                    case MessageStatus.success:
                      return MessageList(state: state);
                    case MessageStatus.loading:
                      return const Center(child: CircularProgressIndicator());
                    default:
                      return const SizedBox();
                  }
                },
              ),
            ),
            SendTextField(
              user: auth,
              hintText: '메시지 보내기...',
              sendText: '보내기',
              onTap: (text) async {
                context.read<MessageBloc>().add(MessageSend(text: text));
              },
            ),
          ],
        ),
      ),
      endDrawer: const Drawer(
        child: SafeArea(
          child: MessageMemberList(),
        ),
      ),
    );
  }
}

class MessageTitle extends StatelessWidget {
  const MessageTitle({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final auth = context.select((AuthCubit cubit) => cubit.user);

    return BlocBuilder<MessageBloc, MessageState>(
      builder: (context, state) {
        final chat = state.chat;
        switch (state.status) {
          case MessageStatus.success:
            if (chat == null) {
              return const SizedBox();
            } else if (chat.group) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(chat.title ?? '그룹채팅'),
                  const SizedBox(width: 8),
                  Text(
                    '${state.members.length}',
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              );
            } else {
              final other = opposite(state.members, auth);
              return Text(other?.username ?? '');
            }
          default:
            return const SizedBox();
        }
      },
    );
  }
}

class MessageMemberList extends StatelessWidget {
  const MessageMemberList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MessageBloc, MessageState>(builder: (context, state) {
      switch (state.status) {
        case MessageStatus.success:
          return Column(
            children: [
              ListTile(
                title: Text('참여자: ${state.members.length}'),
                subtitle: Text(
                    '개설일: ${state.chat == null ? '' : DateFormat.yMd().format(state.chat!.date)}'),
              ),
              const Divider(),
              Expanded(
                child: ListView.builder(
                  itemExtent: 60,
                  itemCount: state.members.length,
                  itemBuilder: (context, index) {
                    final user = state.members[index];
                    return UserListTile(
                      key: ValueKey(user),
                      user: user,
                    );
                  },
                ),
              ),
            ],
          );
        default:
          return const SizedBox();
      }
    });
  }
}

class MessageList extends StatefulWidget {
  const MessageList({
    Key? key,
    required this.state,
  }) : super(key: key);

  final MessageState state;

  @override
  State<MessageList> createState() => _MessageListState();
}

class _MessageListState extends State<MessageList> {
  final _controller = ScrollController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onChanged);
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_onChanged)
      ..dispose();
    super.dispose();
  }

  void _onChanged() {
    if (widget.state.hasReachedMax || !_controller.hasClients) return;

    if (_controller.offset >= _controller.position.maxScrollExtent - 120) {
      context.read<MessageBloc>().add(const MessageFetched());
    }
  }

  @override
  Widget build(BuildContext context) {
    final messages = widget.state.messages;
    if (messages.isEmpty) {
      return const Center(child: Text('포스트가 없습니다.'));
    }
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      controller: _controller,
      reverse: true,
      padding: const EdgeInsets.symmetric(vertical: 4),
      itemCount: messages.length + (widget.state.hasReachedMax ? 0 : 1),
      itemBuilder: (context, index) {
        if (index == messages.length) {
          return const Center(child: CircularProgressIndicator());
        }
        final message = messages[index];
        return MessageCard(
          key: Key(message.message.messageId),
          message: message,
          prevMessage:
              index == messages.length - 1 ? null : messages[index + 1],
        );
      },
    );
  }
}
