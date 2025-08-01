// lib/services/reminder_service.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mental_health_app/change_notifiers/auth_provider.dart';
import 'package:mental_health_app/models/reminder_model.dart';
import 'package:mental_health_app/services/api_service.dart';
import 'package:provider/provider.dart'; // Assuming this path

class ReminderService {
  final ApiService _apiService = ApiService();
  final AuthProvider _authProvider;
  
 ReminderService(BuildContext context) : _authProvider = Provider.of<AuthProvider>(context, listen: false);

  Future<Reminder> createReminder(Reminder reminder) async {
    final response = await _apiService.post(
       '/api/reminders/', // ✅ Thêm /api
      reminder.toJson(),
      headers: {'Authorization': 'Bearer ${_authProvider.firebaseToken}'},
    );

    if (response.statusCode == 201) {
      return Reminder.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to create reminder: ${response.body}');
    }
  }

  Future<List<Reminder>> getUserReminders(String userId) async {
    final response = await _apiService.get(
      '/api/reminders/user/$userId', // ✅ Thêm /api
      headers: {'Authorization': 'Bearer ${_authProvider.firebaseToken}'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Reminder.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load reminders: ${response.body}');
    }
  }

  Future<Reminder> getReminder(String reminderId) async {
    final response = await _apiService.get(
      '/api/reminders/$reminderId', // ✅ Thêm /api
      headers: {'Authorization': 'Bearer ${_authProvider.firebaseToken}'},
      );

    if (response.statusCode == 200) {
      return Reminder.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load reminder: ${response.body}');
    }
  }

  Future<Reminder> updateReminder(String reminderId, Reminder reminder) async {
    final response = await _apiService.put(
      '/api/reminders/$reminderId', // ✅ Thêm /api
      reminder.toUpdateJson()
    );

    if (response.statusCode == 200) {
      return Reminder.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to update reminder: ${response.body}');
    }
  }

  Future<void> deleteReminder(String reminderId) async {
    final response = await _apiService.delete(
      '/api/reminders/$reminderId', // ✅ Thêm /api
      );

    if (response.statusCode != 204) {
      throw Exception('Failed to delete reminder: ${response.body}');
    }
  }
}
