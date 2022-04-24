import 'package:flutter/material.dart';
import 'package:instagram/src/auth/bloc/auth_cubit.dart';
import 'package:instagram/src/home/cubit/home_cubit.dart';
import 'package:instagram/src/repo/models/model.dart';
import 'package:instagram/src/pages/message_page.dart';
import 'package:instagram/src/pages/new_message_page.dart';
import 'package:instagram/src/resources/firestore_methods.dart';
import 'package:instagram/src/widgets/chat_card.dart';
import 'package:provider/provider.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({Key? key}) : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  late final _firestore = context.read<FirestoreMethods>();

  @override
  Widget build(BuildContext context) {
    final user = context.select((AuthCubit cubit) => cubit.user);

    final chatsStream = _firestore.chats.chats(uid: user.uid);
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () {
          context.read<HomeCubit>().nav();
        }),
        title: const Text('메시지'),
        actions: [
          IconButton(
            onPressed: () {
              _newChat(user);
            },
            icon: const Icon(Icons.add),
          )
        ],
      ),
      body: StreamBuilder<List<Chat>>(
        stream: chatsStream,
        builder: (context, snapshot) {
          final chats = snapshot.data;
          if (chats == null) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (chats.isEmpty) {
            return const Center(
              child: Text('메시지가 없습니다.'),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 4),
            itemExtent: 70,
            itemCount: chats.length,
            itemBuilder: (context, index) {
              final chat = chats[index];
              return ChatCard(
                key: ValueKey(chat.chatId),
                chat: chat,
                user: user,
                onTap: () {
                  _joinChat(user, chat);
                },
              );
            },
          );
        },
      ),
    );
  }

  void _newChat(User user) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NewMessagePage(
          currentUser: user,
        ),
      ),
    );
  }

  void _joinChat(User user, Chat chat) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MessagePage(
          group: chat.group,
          chat: chat,
          currentUser: user,
          autoFocus: true,
        ),
      ),
    );
  }
}
