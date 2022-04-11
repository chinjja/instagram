import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:instagram/src/models/user.dart';
import 'package:instagram/src/pages/activity_page.dart';
import 'package:instagram/src/pages/bookmark_page.dart';
import 'package:instagram/src/pages/chat_page.dart';
import 'package:instagram/src/pages/feed_page.dart';
import 'package:instagram/src/pages/profile_page.dart';
import 'package:instagram/src/pages/search_page.dart';
import 'package:instagram/src/widgets/get_user.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final tabController = PageController();
  final chatController = PageController();
  int _page = 0;

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
          physics: _page == 0 ? null : const NeverScrollableScrollPhysics(),
          controller: chatController,
          children: [
            Scaffold(
              body: PageView(
                physics: const NeverScrollableScrollPhysics(),
                controller: tabController,
                children: [
                  FeedPage(
                    currentUser: currentUser,
                    onShowChat: () {
                      chatController.animateToPage(
                        1,
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.ease,
                      );
                    },
                  ),
                  const SearchPage(),
                  ActivityPage(
                    currentUser: currentUser,
                  ),
                  BookmarkPage(
                    currentUser: currentUser,
                  ),
                  ProfilePage(
                    user: currentUser,
                  ),
                ],
              ),
              bottomNavigationBar: CupertinoTabBar(
                currentIndex: _page,
                items: [
                  _nav(0, Icons.home, Icons.home_outlined),
                  _nav(1, Icons.search, Icons.search_outlined),
                  _nav(2, Icons.favorite, Icons.favorite_outline),
                  _nav(3, Icons.bookmark, Icons.bookmark_outline),
                  _nav(4, Icons.person, Icons.person_outline),
                ],
                onTap: (page) {
                  setState(() {
                    tabController.jumpToPage(page);
                    _page = page;
                  });
                },
              ),
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

  BottomNavigationBarItem _nav(int index, IconData active, IconData inactive) {
    final theme = Theme.of(context);
    return BottomNavigationBarItem(
      icon: Icon(
        _page == index ? active : inactive,
      ),
      backgroundColor: theme.canvasColor,
    );
  }
}
