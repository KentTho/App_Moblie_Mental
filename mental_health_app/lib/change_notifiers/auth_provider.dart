// lib/change_notifiers/auth_provider.dart
import 'package:flutter/material.dart';

class AuthProvider with ChangeNotifier {
  String? _userId;
  String? _firebaseToken; // Thêm trường lưu token

  String? get userId => _userId;
  String? get firebaseToken => _firebaseToken; // Getter cho token

  void setUserId(String id, String token) {
    _userId = id;
    _firebaseToken = token; // Lưu cả token khi login
    notifyListeners();
  }

  void clearUserId() {
    _userId = null;
    _firebaseToken = null; 
    notifyListeners();
  }

  bool get isLoggedIn => _userId != null;
}

