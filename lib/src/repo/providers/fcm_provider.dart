import 'dart:convert';
import 'dart:developer';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;

class FcmProvider {
  late final String _fcmServiceKey;

  FcmProvider() {
    _init();
  }

  Future _init() async {
    _fcmServiceKey =
        'AAAAb61n64c:APA91bFpLYd5UMp1xmk30yIc43zXxzCXkiCDDrkuH09NLUYttbsArJjcFuV1NDFuYr6YATTwSR6TgCh-Jm0JsF5MX-HPyJFpXRsJmJqocBZEmkET0z9Sq2zXOgQR1RR4AHF4L-LmQPx8';
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
              'click_action': Uri.base.toString(),
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
      log('error $e');
      return false;
    }
  }
}
