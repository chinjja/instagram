import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:instagram/src/models/user.dart';
import 'package:instagram/src/pages/activity_page.dart';
import 'package:instagram/src/pages/bookmark_page.dart';
import 'package:instagram/src/pages/feed_page.dart';
import 'package:instagram/src/pages/profile_page.dart';
import 'package:instagram/src/pages/search_page.dart';
import 'package:instagram/src/resources/auth_methods.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final _auth = context.read<AuthMethods>();
  final _controlelr = PageController();
  int _page = 0;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
        stream: _auth.currentUser,
        builder: (context, snapshot) {
          return Scaffold(
            body: Builder(
              builder: (context) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                final user = snapshot.data;
                if (user == null) {
                  return Center(
                    child: ElevatedButton(
                      onPressed: () {
                        _auth.signOut();
                      },
                      child: const Text('Sign Out'),
                    ),
                  );
                }
                return PageView(
                  physics: const NeverScrollableScrollPhysics(),
                  controller: _controlelr,
                  children: [
                    FeedPage(
                      user: user,
                    ),
                    const SearchPage(),
                    ActivityPage(
                      user: user,
                    ),
                    BookmarkPage(
                      user: user,
                    ),
                    ProfilePage(
                      user: user,
                    ),
                  ],
                );
              },
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
                  setState(() {
                    _controlelr.jumpToPage(page);
                    _page = page;
                  });
                },
              );
            }),
          );
        });
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
