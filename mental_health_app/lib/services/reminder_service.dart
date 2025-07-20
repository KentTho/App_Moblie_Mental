// lib/services/reminder_service.dart
import 'dart:convert';
import 'package:mental_health_app/models/reminder_model.dart';
import 'package:mental_health_app/services/api_service.dart'; // Assuming this path

class ReminderService {
  final ApiService _apiService = ApiService();

  Future<Reminder> createReminder(Reminder reminder) async {
    final response = await _apiService.post('/reminders', reminder.toJson());

    if (response.statusCode == 201) {
      return Reminder.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to create reminder: ${response.body}');
    }
  }

  Future<List<Reminder>> getUserReminders(String userId) async {
    final response = await _apiService.get('/reminders/user/$userId');

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Reminder.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load reminders: ${response.body}');
    }
  }

  Future<Reminder> getReminder(String reminderId) async {
    final response = await _apiService.get('/reminders/$reminderId');

    if (response.statusCode == 200) {
      return Reminder.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load reminder: ${response.body}');
    }
  }

  Future<Reminder> updateReminder(String reminderId, Reminder reminder) async {
    final response = await _apiService.put('/reminders/$reminderId', reminder.toUpdateJson());

    if (response.statusCode == 200) {
      return Reminder.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to update reminder: ${response.body}');
    }
  }

  Future<void> deleteReminder(String reminderId) async {
    final response = await _apiService.delete('/reminders/$reminderId');

    if (response.statusCode != 204) {
      throw Exception('Failed to delete reminder: ${response.body}');
    }
  }
}
