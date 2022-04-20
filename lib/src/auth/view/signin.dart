import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:instagram/src/auth/bloc/auth_cubit.dart';

class SigninView extends StatelessWidget {
  const SigninView({Key? key}) : super(key: key);

  static Route route() {
    return MaterialPageRoute(builder: (_) => const SigninView());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Instagram',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 32),
                BlocBuilder<AuthCubit, AuthState>(builder: (context, state) {
                  return Stack(
                    children: [
                      InkWell(
                        onTap: state.status == AuthStatus.unauthenticated
                            ? () {
                                context.read<AuthCubit>().signInWithGoogle();
                              }
                            : null,
                        child: Image.asset(
                          'assets/images/google_signin.png',
                        ),
                      ),
                      if (state.status == AuthStatus.authenticating)
                        const Positioned.fill(
                            child: Center(child: CircularProgressIndicator()))
                    ],
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
