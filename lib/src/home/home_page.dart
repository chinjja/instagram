import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:instagram/src/auth/bloc/auth_cubit.dart';
import 'package:instagram/src/pages/chat_page.dart';
import 'package:instagram/src/home/nav_page.dart';
import 'package:instagram/src/widgets/keep_alive_widget.dart';

class HomeView extends StatefulWidget {
  const HomeView({Key? key}) : super(key: key);

  static Route route() {
    return MaterialPageRoute(builder: (_) => const HomeView());
  }

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final chatController = PageController();
  int tab = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    chatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        if (state.status != AuthStatus.authenticated) {
          return const SizedBox();
        }
        return PageView(
          physics: tab == 0 ? null : const NeverScrollableScrollPhysics(),
          controller: chatController,
          children: [
            KeepAliveWidget(
              child: NavPage(
                user: state.user!,
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
              user: state.user!,
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
