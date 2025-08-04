import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;


class FCMService {
  static Future<void> sendTokenToServer(String bearerToken) async {
    final fcmToken = await FirebaseMessaging.instance.getToken();
    if (fcmToken == null) {
      print("❌ FCM token null");
      return;
    }

    final response = await http.put(
      Uri.parse('http://10.0.2.2:8000/user/update-fcm-token'),
      headers: {
        'Authorization': 'Bearer $bearerToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'fcm_token': fcmToken}),
    );

    if (response.statusCode == 200) {
      print("✅ FCM token gửi thành công");
    } else {
      print("❌ Gửi FCM token thất bại: ${response.body}");
    }
  }
}
