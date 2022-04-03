import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:instagram/src/pages/home_page.dart';
import 'package:instagram/src/pages/welcome.dart';
import 'package:instagram/src/resources/auth_methods.dart';
import 'package:instagram/src/resources/firestore_methods.dart';
import 'package:instagram/src/resources/storage_methods.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FirebaseOptions? options;
  if (kIsWeb) {
    options = const FirebaseOptions(
        apiKey: 'AIzaSyCgl15S12vqf2MiWtmpZPBds5BX_nBJ3P4',
        appId: '1:479650638727:web:ee9a57c60970a302c24122',
        messagingSenderId: '479650638727',
        projectId: 'instagram-21e39',
        storageBucket: 'instagram-21e39.appspot.com',
        authDomain: 'instagram-21e39.firebaseapp.com');
  }
  await Firebase.initializeApp(options: options);
  runApp(const MyApp());
}

final _storage = StorageMethods();
final _firestore = FirestoreMethods(storage: _storage);
final _auth = AuthMethods(storage: _storage, firestore: _firestore);

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider.value(value: _storage),
        Provider.value(value: _firestore),
        Provider.value(value: _auth),
      ],
      child: MaterialApp(
        title: 'Instagram Demo',
        theme: ThemeData.dark(),
        home: FirebaseAuth.instance.currentUser == null
            ? const WelcomePage()
            : const HomePage(),
      ),
    );
  }
}
