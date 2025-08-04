// lib/change_notifiers/reminder_provider.dart
import 'package:flutter/material.dart';
import 'package:mental_health_app/models/reminder_model.dart';
import 'package:mental_health_app/services/reminder_service.dart';
import 'package:provider/provider.dart';
import 'package:mental_health_app/change_notifiers/auth_provider.dart'; // Assuming this path

class ReminderProvider with ChangeNotifier {
  late final ReminderService _reminderService;
  bool _isInitialized = false;

  List<Reminder> _reminders = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Reminder> get reminders => _reminders;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  ReminderProvider();

  void init(BuildContext context) {
    if (!_isInitialized) {
      _reminderService = ReminderService(context);
      _isInitialized = true;
    }
  }

  Future<void> fetchReminders(BuildContext context) async {
    print("⚙️ ReminderProvider: fetchReminders gọi");
    if (!_isInitialized) {
      print("❗ ReminderProvider chưa init, gọi init()");
      init(context);
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userId = authProvider.userId;

      if (userId == null) {
        _errorMessage = "User not logged in.";
        _isLoading = false;
        notifyListeners();
        return;
      }

      print("✅ Gọi ReminderService.getUserReminders");
      _reminders = await _reminderService.getUserReminders(userId);
    } catch (e) {
      _errorMessage = 'Error fetching reminders: $e';
      print('Error fetching reminders: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addReminder(BuildContext context, Reminder reminder) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final UserId = authProvider.userId;

      if (UserId == null) {
        _errorMessage = "User not logged in.";
        _isLoading = false;
        notifyListeners();
        return;
      }

      final newReminder = Reminder(
        userId: UserId,
        message: reminder.message,
        scheduledTime: reminder.scheduledTime,
        isActive: reminder.isActive,
      );

      final createdReminder = await _reminderService.createReminder(newReminder);
      _reminders.add(createdReminder);
    } catch (e) {
      _errorMessage = 'Error adding reminder: $e';
      print('Error adding reminder: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateReminder(String reminderId, Reminder updatedReminder) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final Reminder result = await _reminderService.updateReminder(reminderId, updatedReminder);
      final index = _reminders.indexWhere((r) => r.id == reminderId);
      if (index != -1) {
        _reminders[index] = result;
      }
    } catch (e) {
      _errorMessage = 'Error updating reminder: $e';
      print('Error updating reminder: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteReminder(String reminderId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _reminderService.deleteReminder(reminderId);
      _reminders.removeWhere((r) => r.id == reminderId);
    } catch (e) {
      _errorMessage = 'Error deleting reminder: $e';
      print('Error deleting reminder: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

}