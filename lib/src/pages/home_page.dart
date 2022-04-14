import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:instagram/src/models/user.dart' as model;
import 'package:instagram/src/pages/chat_page.dart';
import 'package:instagram/src/pages/nav_page.dart';
import 'package:instagram/src/resources/firestore_methods.dart';
import 'package:instagram/src/widgets/keep_alive_widget.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final _firestore = context.read<FirestoreMethods>();
  final chatController = PageController();
  StreamSubscription? subscription;
  int tab = 0;
  model.User? user;

  @override
  void initState() {
    super.initState();
    subscription = _firestore.users
        .at(uid: FirebaseAuth.instance.currentUser!.uid)
        .listen((event) {
      if (user != event) {
        setState(() {
          user = event;
        });
      }
    });
  }

  @override
  void dispose() {
    subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return user == null
        ? const Center(
            child: CircularProgressIndicator(),
          )
        : PageView(
            physics: tab == 0 ? null : const NeverScrollableScrollPhysics(),
            controller: chatController,
            children: [
              KeepAliveWidget(
                child: NavPage(
                  user: user!,
                  onShowChat: () {
                    chatController.animateToPage(
                      1,
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.ease,
                    );
                  },
                  onTabChanged: (value) {
                    if (tab != value) {
                      setState(() {
                        tab = value;
                      });
                    }
                  },
                ),
              ),
              ChatPage(
                user: user!,
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
  }
}
