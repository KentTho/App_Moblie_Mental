// lib/change_notifiers/auth_provider.dart
import 'package:flutter/material.dart';

class AuthProvider with ChangeNotifier {
  String? _userId;

  // String get userId => _userId ?? "1"; // fallback là "1"
  String? get userId => _userId;


  void setUserId(String id) {
    _userId = id;
    notifyListeners();
  }
}
