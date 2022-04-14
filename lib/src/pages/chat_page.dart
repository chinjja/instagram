import 'package:flutter/material.dart';
import 'package:instagram/src/models/chat.dart';
import 'package:instagram/src/models/user.dart';
import 'package:instagram/src/pages/new_message_page.dart';
import 'package:instagram/src/resources/firestore_methods.dart';
import 'package:instagram/src/widgets/chat_card.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({Key? key, required this.user, required this.onHideChat})
      : super(key: key);
  final User user;
  final void Function() onHideChat;

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  late final _firestore = context.read<FirestoreMethods>();

  @override
  Widget build(BuildContext context) {
    final user = widget.user;
    final chatsStream = _firestore.chats.chats(uid: user.uid);
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: widget.onHideChat),
        title: const Text('메시지'),
        actions: [
          IconButton(
            onPressed: _newChat,
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
              );
            },
          );
        },
      ),
    );
  }

  void _newChat() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NewMessagePage(
          currentUser: widget.user,
        ),
      ),
    );
  }
}
