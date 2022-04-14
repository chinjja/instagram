import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:instagram/src/models/user.dart';
import 'package:instagram/src/pages/activity_page.dart';
import 'package:instagram/src/pages/bookmark_page.dart';
import 'package:instagram/src/pages/feed_page.dart';
import 'package:instagram/src/pages/profile_page.dart';
import 'package:instagram/src/pages/search_page.dart';
import 'package:instagram/src/widgets/keep_alive_widget.dart';

class NavPage extends StatefulWidget {
  const NavPage({
    Key? key,
    required this.user,
    required this.onShowChat,
    required this.onTabChanged,
  }) : super(key: key);
  final User user;
  final void Function() onShowChat;
  final void Function(int tab) onTabChanged;
  @override
  State<NavPage> createState() => _NavPageState();
}

class _NavPageState extends State<NavPage> {
  final tabController = PageController();
  int _page = 0;
  final pageKey = const PageStorageKey('feed');
  final pageBucket = PageStorageBucket();

  @override
  Widget build(BuildContext context) {
    final user = widget.user;

    return Scaffold(
      body: PageView(
        physics: const NeverScrollableScrollPhysics(),
        controller: tabController,
        children: [
          KeepAliveWidget(
            child: PageStorage(
              key: pageKey,
              bucket: pageBucket,
              child: FeedPage(
                currentUser: user,
                onShowChat: widget.onShowChat,
              ),
            ),
          ),
          const KeepAliveWidget(child: SearchPage()),
          KeepAliveWidget(
            child: ActivityPage(
              currentUser: user,
            ),
          ),
          KeepAliveWidget(
            child: BookmarkPage(
              currentUser: user,
            ),
          ),
          KeepAliveWidget(
            child: ProfilePage(
              user: user,
            ),
          ),
        ],
      ),
      bottomNavigationBar: StatefulBuilder(builder: (context, setState) {
        return CupertinoTabBar(
          currentIndex: _page,
          items: [
            _nav(0, Icons.home, Icons.home_outlined),
            _nav(1, Icons.search, Icons.search_outlined),
            _nav(2, Icons.favorite, Icons.favorite_outline),
            _nav(3, Icons.bookmark, Icons.bookmark_outline),
            _nav(4, Icons.person, Icons.person_outline),
          ],
          onTap: (page) {
            if (_page != page) {
              setState(() {
                tabController.jumpToPage(page);
                _page = page;
              });
              widget.onTabChanged(page);
            }
          },
        );
      }),
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
