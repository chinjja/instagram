import 'package:firebase_messaging/firebase_messaging.dart';

class MessagingMethods {
  final _messaging = FirebaseMessaging.instance;

  Future<String?> get token => _messaging.getToken();
}
