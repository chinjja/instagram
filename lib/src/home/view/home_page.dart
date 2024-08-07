import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:instagram/main.dart';
import 'package:instagram/src/auth/bloc/auth_cubit.dart';
import 'package:instagram/src/bookmark/view/bookmark_page.dart';
import 'package:instagram/src/home/cubit/home_cubit.dart';
import 'package:instagram/src/activity/view/activity_page.dart';
import 'package:instagram/src/chat/view/chat_page.dart';
import 'package:instagram/src/repo/providers/provider.dart';
import 'package:instagram/src/search/view/search_page.dart';
import 'package:instagram/src/post/view/view.dart';
import 'package:instagram/src/user/view/user_page.dart';
import 'package:instagram/src/widgets/keep_alive_widget.dart';
import 'package:rxdart/rxdart.dart';

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
  final _subscriptions = CompositeSubscription();

  @override
  void initState() {
    super.initState();
    final s = FirebaseAuth.instance.authStateChanges().listen(
      (user) {
        if (user == null) return;
        _init(user);
      },
    );
    _subscriptions.add(s);
  }

  Future _init(User user) async {
    await FirebaseMessaging.instance.requestPermission();
    final token = await FcmProvider().getToken();
    if (token != null) {
      userProvider.updateFcmToken(uid: user.uid, token: token);
    }
    if (mounted) {
      final a = FirebaseMessaging.instance.onTokenRefresh.listen((token) {
        userProvider.updateFcmToken(uid: user.uid, token: token);
      });

      _subscriptions.add(a);
      final b = FirebaseMessaging.onMessage
          .where((event) => event.notification != null)
          .cast<RemoteMessage>()
          .listen((message) {
        showDialog(
          context: context,
          barrierColor: null,
          barrierDismissible: false,
          builder: (context) {
            final notification = message.notification;
            return NotificationDialog(
              chatId: message.data['chatId']!,
              title: notification?.title ?? '',
              body: notification?.body ?? '',
            );
          },
        );
      });
      _subscriptions.add(b);
    }
  }

  @override
  void dispose() {
    _subscriptions.dispose();
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
                child: UserPage(
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

class NotificationDialog extends StatefulWidget {
  final String chatId;
  final String title;
  final String body;

  const NotificationDialog({
    super.key,
    required this.chatId,
    required this.title,
    required this.body,
  });

  @override
  State<NotificationDialog> createState() => _NotificationDialogState();
}

class _NotificationDialogState extends State<NotificationDialog> {
  @override
  Widget build(BuildContext context) {
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.of(context).pop();
      }
    });
    return Align(
      alignment: Alignment.topCenter,
      child: GestureDetector(
        onTap: () {
          Navigator.of(context).pop();
        },
        child: Card(
          elevation: 4,
          child: ListTile(
            leading: const FlutterLogo(),
            title: Text(widget.title),
            subtitle: Text(widget.body),
          ),
        ),
      ),
    );
  }
}
