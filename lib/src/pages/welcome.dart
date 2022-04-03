import 'package:flutter/material.dart';
import 'package:instagram/src/pages/home_page.dart';
import 'package:instagram/src/resources/auth_methods.dart';
import 'package:provider/provider.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({Key? key}) : super(key: key);

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  late final _auth = context.read<AuthMethods>();

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
                InkWell(
                  onTap: _oauth,
                  child: Image.asset(
                    'assets/images/google_signin.png',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _oauth() async {
    final user = await _auth.signInWithGoogle(context);
    if (user != null) {
      _goHomePage();
    }
  }

  void _goHomePage() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const HomePage()),
      (route) => false,
    );
  }
}
