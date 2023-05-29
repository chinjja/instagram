import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

class FcmProvider {
  late final String _fcmServiceKey;

  FcmProvider() {
    _init();
  }

  Future _init() async {
    String jsonString =
        await rootBundle.loadString('assets/google-services.json');
    Map<String, dynamic> jsonMap = json.decode(jsonString);
    _fcmServiceKey = jsonMap['fcm_server_key'];
  }

  Future<String?> getToken() => FirebaseMessaging.instance.getToken(
        vapidKey:
            'BBfFhncqyverYPK2ex6wYX-Ofo2CPol5VpanTBmU9st3pSP6NC20G-yMY8pxkDrloBFghoPlbUmCY-JvzTImsrg',
      );

  Future<bool> send({
    required List<String> userTokens,
    required String title,
    required String body,
    required String chatId,
  }) async {
    try {
      final response = await http.post(
          Uri.parse('https://fcm.googleapis.com/fcm/send'),
          headers: <String, String>{
            'Content-Type': 'application/json',
            'Authorization': 'key=$_fcmServiceKey'
          },
          body: jsonEncode({
            'notification': {
              'title': title,
              'body': body,
              'click_action': 'https://instagram-21e39.web.app',
            },
            'data': {'chatId': chatId},
            'content_available': true,
            'priority': 'high',
            // 상대방 토큰 값, to -> 단일, registration_ids -> 여러명
            // 'to': userToken
            'registration_ids': userTokens,
          }));
      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (e) {
      print('error $e');
      return false;
    }
  }
}
