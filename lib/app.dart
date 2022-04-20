import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:instagram/src/auth/bloc/auth_cubit.dart';
import 'package:instagram/src/auth/view/signin.dart';
import 'package:instagram/src/home/home_page.dart';
import 'package:instagram/src/utils/utils.dart';

class App extends StatefulWidget {
  const App({Key? key}) : super(key: key);

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  final _nav = GlobalKey<NavigatorState>();

  NavigatorState get nav => _nav.currentState!;

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        switch (state.status) {
          case AuthStatus.authenticated:
            nav.pushAndRemoveUntil(HomeView.route(), (route) => false);
            break;
          case AuthStatus.unauthenticated:
            nav.pushAndRemoveUntil(SigninView.route(), (route) => false);
            break;
          case AuthStatus.failure:
            showSnackbar(context, 'oops!');
            break;
          default:
            break;
        }
      },
      child: MaterialApp(
        navigatorKey: _nav,
        title: 'Instagram Demo',
        theme: ThemeData.dark(),
        onGenerateRoute: (_) => SplashView.route(),
      ),
    );
  }
}

class SplashView extends StatefulWidget {
  const SplashView({Key? key}) : super(key: key);

  static Route route() => MaterialPageRoute(builder: (_) => const SplashView());
  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  @override
  void initState() {
    super.initState();
    context.read<AuthCubit>().init();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
