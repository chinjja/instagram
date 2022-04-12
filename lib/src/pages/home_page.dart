import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:instagram/src/pages/chat_page.dart';
import 'package:instagram/src/pages/nav_page.dart';
import 'package:instagram/src/widgets/get_user.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final chatController = PageController();
  int tab = 0;

  @override
  Widget build(BuildContext context) {
    return GetUser(
      uid: FirebaseAuth.instance.currentUser?.uid,
      builder: (context, snapshot) {
        final currentUser = snapshot;
        if (currentUser == null) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        return PageView(
          physics: tab == 0 ? null : const NeverScrollableScrollPhysics(),
          controller: chatController,
          children: [
            NavPage(
              user: currentUser,
              onShowChat: () {
                chatController.animateToPage(
                  1,
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.ease,
                );
              },
              onTabChanged: (value) {
                setState(() {
                  tab = value;
                });
              },
            ),
            ChatPage(
              user: currentUser,
              onHideChat: () {
                chatController.animateToPage(
                  0,
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.ease,
                );
              },
            ),
          ],
        );
      },
    );
  }
}
