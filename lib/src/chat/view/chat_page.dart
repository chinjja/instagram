import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:instagram/src/auth/bloc/auth_cubit.dart';
import 'package:instagram/src/chat/bloc/chat_bloc.dart';
import 'package:instagram/src/home/cubit/home_cubit.dart';
import 'package:instagram/src/repo/models/model.dart';
import 'package:instagram/src/message/view/message_page.dart';
import 'package:instagram/src/add_chat/view/add_chat_page.dart';
import 'package:instagram/src/resources/firestore_methods.dart';
import 'package:instagram/src/chat/view/chat_card.dart';

class ChatPage extends StatelessWidget {
  const ChatPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final auth = context.select((AuthCubit cubit) => cubit.user);
    return BlocProvider(
      create: (context) => ChatBloc(
        context.read<FirestoreMethods>(),
        auth: auth,
      )..add(ChatSubscriptionRequested()),
      child: const ChatView(),
    );
  }
}

class ChatView extends StatelessWidget {
  const ChatView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final auth = context.select((AuthCubit cubit) => cubit.user);

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () {
          context.read<HomeCubit>().nav();
        }),
        title: const Text('메시지'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(context, AddChatPage.route());
            },
            icon: const Icon(Icons.add),
          )
        ],
      ),
      body: BlocBuilder<ChatBloc, ChatState>(
        builder: (context, state) {
          switch (state.status) {
            case ChatStatus.loading:
              return const Center(
                child: CircularProgressIndicator(),
              );
            case ChatStatus.failure:
              return const Center(
                child: Text('oops!'),
              );
            case ChatStatus.success:
              if (state.list.isEmpty) {
                return const Center(
                  child: Text('메시지가 없습니다.'),
                );
              } else {
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  itemExtent: 70,
                  itemCount: state.list.length,
                  itemBuilder: (context, index) {
                    final data = state.list[index];
                    return Dismissible(
                      key: Key(data.chat.chatId),
                      background: Container(
                        color: Colors.red,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        alignment: Alignment.centerLeft,
                        child: const Icon(Icons.delete_forever),
                      ),
                      secondaryBackground: Container(
                        color: Colors.red,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        alignment: Alignment.centerRight,
                        child: const Icon(Icons.delete_forever),
                      ),
                      onDismissed: (details) {
                        context
                            .read<ChatBloc>()
                            .add(ChatDeleted(chat: data.chat));
                      },
                      child: ChatCard(
                        data: data,
                        onTap: () {
                          _joinChat(context, auth, data.chat);
                        },
                      ),
                    );
                  },
                );
              }
            default:
              return const SizedBox();
          }
        },
      ),
    );
  }

  void _joinChat(BuildContext context, User user, Chat chat) {
    Navigator.push(
      context,
      MessagePage.route(chat: chat),
    );
  }
}
