import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  static Future<String> fetchUserId(String firebaseUid) async {
    final response = await http.get(Uri.parse("http://10.0.2.2:8000/user/firebase/$firebaseUid"));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data["id"];
    } else {
      throw Exception("Failed to fetch user ID");
    }
  }
}
