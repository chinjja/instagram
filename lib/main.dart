import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:instagram/src/pages/home_page.dart';
import 'package:instagram/src/pages/welcome.dart';
import 'package:instagram/src/resources/auth_methods.dart';
import 'package:instagram/src/resources/firestore_methods.dart';
import 'package:instagram/src/resources/messaging_methods.dart';
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
  FirebaseMessaging.onBackgroundMessage(onBackgroundMessage);
  if (!kIsWeb) {
    channel = const AndroidNotificationChannel(
      'high_importance_channel', // id
      'High Importance Notifications', // title
      description:
          'This channel is used for important notifications.', // description
      importance: Importance.high,
    );

    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    /// Create an Android Notification Channel.
    ///
    /// We use this channel in the `AndroidManifest.xml` file to override the
    /// default FCM channel to enable heads up notifications.
    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
    FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }
  runApp(const MyApp());
}

late AndroidNotificationChannel channel;
late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

Future<void> onBackgroundMessage(RemoteMessage message) async {
  log('onBackgroundMessage ${message.from}');
}

final _storage = StorageMethods();
final _messaging = MessagingMethods();
final _firestore = FirestoreMethods(storage: _storage, messaging: _messaging);
final _auth = AuthMethods(storage: _storage, firestore: _firestore);

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    FirebaseMessaging.instance.requestPermission();
    FirebaseMessaging.instance.getInitialMessage().then((message) {
      log('initial message: ${message?.data}');
    });
    FirebaseMessaging.onMessage.listen((message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;
      if (notification != null && android != null && !kIsWeb) {
        flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              channel.id,
              channel.name,
              channelDescription: channel.description,
              icon: 'launch_background',
            ),
          ),
        );
      }
      log('on message ${message.data}');
    });
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      log('on message opended app ${message.data}');
    });
    FirebaseAuth.instance.authStateChanges().listen((user) async {
      if (user != null) {
        final token = await _messaging.token;
        log('update token: $token');
        _firestore.updateToken(uid: user.uid, token: token);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider.value(value: _storage),
        Provider.value(value: _firestore),
        Provider.value(value: _auth),
        Provider.value(value: _messaging),
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
