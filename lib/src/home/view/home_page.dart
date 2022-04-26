import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:instagram/src/auth/bloc/auth_cubit.dart';
import 'package:instagram/src/bookmark/view/bookmark_page.dart';
import 'package:instagram/src/home/cubit/home_cubit.dart';
import 'package:instagram/src/activity/view/activity_page.dart';
import 'package:instagram/src/chat/view/chat_page.dart';
import 'package:instagram/src/pages/profile_page.dart';
import 'package:instagram/src/pages/search_page.dart';
import 'package:instagram/src/post/view/view.dart';
import 'package:instagram/src/widgets/keep_alive_widget.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  static Route route() {
    return MaterialPageRoute(
      builder: (_) => const HomePage(),
      settings: const RouteSettings(name: '/'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HomeCubit(),
      child: const HomeView(),
    );
  }
}

class HomeView extends StatefulWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final controller = PageController();
  int tab = 0;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isFeed = context.select(
      (HomeCubit cubit) => cubit.state.nav == NavStatus.feed,
    );

    return BlocConsumer<HomeCubit, HomeState>(
      builder: (context, state) {
        return PageView(
          physics: isFeed ? null : const NeverScrollableScrollPhysics(),
          controller: controller,
          onPageChanged: (page) {
            if (page == 1) {
              context.read<HomeCubit>().chat();
            } else {
              context.read<HomeCubit>().nav();
            }
          },
          children: const [
            KeepAliveWidget(
              child: NavView(),
            ),
            ChatPage(),
          ],
        );
      },
      listener: (context, state) {
        final tab = state.status == HomeStatus.chat ? 1 : 0;

        controller.animateToPage(
          tab,
          duration: const Duration(milliseconds: 250),
          curve: Curves.ease,
        );
      },
    );
  }
}

class NavView extends StatefulWidget {
  const NavView({
    Key? key,
  }) : super(key: key);
  @override
  State<NavView> createState() => _NavViewState();
}

class _NavViewState extends State<NavView> {
  final tabController = PageController();

  @override
  Widget build(BuildContext context) {
    final auth = context.select((AuthCubit cubit) => cubit.user);
    final page = context.select((HomeCubit cubit) => cubit.state.nav.index);

    return BlocConsumer<HomeCubit, HomeState>(
      builder: (context, state) {
        return Scaffold(
          body: PageView(
            physics: const NeverScrollableScrollPhysics(),
            controller: tabController,
            children: [
              KeepAliveWidget(
                child: PostPage(
                  showActions: true,
                  onShowChat: () {
                    context.read<HomeCubit>().chat();
                  },
                ),
              ),
              const KeepAliveWidget(child: SearchPage()),
              const KeepAliveWidget(child: ActivityPage()),
              const KeepAliveWidget(child: BookmarkPage()),
              KeepAliveWidget(
                child: ProfilePage(
                  user: auth,
                ),
              ),
            ],
          ),
          bottomNavigationBar: StatefulBuilder(builder: (context, setState) {
            return CupertinoTabBar(
              currentIndex: page,
              items: [
                _nav(page, NavStatus.feed, Icons.home, Icons.home_outlined),
                _nav(page, NavStatus.search, Icons.search,
                    Icons.search_outlined),
                _nav(page, NavStatus.activity, Icons.favorite,
                    Icons.favorite_outline),
                _nav(page, NavStatus.bookmark, Icons.bookmark,
                    Icons.bookmark_outline),
                _nav(page, NavStatus.profile, Icons.person,
                    Icons.person_outline),
              ],
              onTap: (page) {
                context.read<HomeCubit>().nav(NavStatus.values.byIndex(page));
              },
            );
          }),
        );
      },
      listener: (context, state) {
        tabController.jumpToPage(state.nav.index);
      },
    );
  }

  BottomNavigationBarItem _nav(
      int page, NavStatus nav, IconData active, IconData inactive) {
    final theme = Theme.of(context);
    return BottomNavigationBarItem(
      icon: Icon(
        page == nav.index ? active : inactive,
      ),
      backgroundColor: theme.canvasColor,
    );
  }
}
