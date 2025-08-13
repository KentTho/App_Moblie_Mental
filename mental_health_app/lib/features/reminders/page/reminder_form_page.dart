// lib/features/reminders/page/reminder_form_page.dart
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mental_health_app/change_notifiers/reminder_provider.dart';
import 'package:mental_health_app/models/reminder_model.dart';
import 'package:intl/intl.dart'; // For date formatting

class ReminderFormPage extends StatefulWidget {
  final Reminder? reminder; // Null for new, not null for edit

  const ReminderFormPage({super.key, this.reminder});

  @override
  State<ReminderFormPage> createState() => _ReminderFormPageState();
}

class _ReminderFormPageState extends State<ReminderFormPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _messageController;
  late DateTime _scheduledDateTime;
  late bool _isActive;

  @override
  void initState() {
    super.initState();
    _messageController = TextEditingController(text: widget.reminder?.message ?? '');
    _scheduledDateTime = widget.reminder?.scheduledTime ?? DateTime.now().add(const Duration(hours: 1));
    _isActive = widget.reminder?.isActive ?? true;
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _scheduledDateTime,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF4CAF50), // xanh lá chủ đạo
              onPrimary: Colors.white,
              onSurface: Colors.black87,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: const Color(0xFF4CAF50)),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _scheduledDateTime) {
      setState(() {
        _scheduledDateTime = DateTime(
          picked.year,
          picked.month,
          picked.day,
          _scheduledDateTime.hour,
          _scheduledDateTime.minute,
        );
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_scheduledDateTime),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF4CAF50),
              onPrimary: Colors.white,
              onSurface: Colors.black87,
            ),
            timePickerTheme: TimePickerThemeData(
              dialHandColor: Color(0xFF4CAF50),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _scheduledDateTime = DateTime(
          _scheduledDateTime.year,
          _scheduledDateTime.month,
          _scheduledDateTime.day,
          picked.hour,
          picked.minute,
        );
      });
    }
  }

  Future<void> scheduleNotification(Reminder reminder) async {
    await AwesomeNotifications().createNotification(
      schedule: NotificationCalendar(
        year: reminder.scheduledTime.year,
        month: reminder.scheduledTime.month,
        day: reminder.scheduledTime.day,
        hour: reminder.scheduledTime.hour,
        minute: reminder.scheduledTime.minute,
        second: 0,
        millisecond: 0,
        repeats: false,
        preciseAlarm: true,
      ),
      content: NotificationContent(
        id: reminder.scheduledTime.millisecondsSinceEpoch.remainder(100000),
        channelKey: 'reminder_channel',
        title: '🧠 Reminder',
        body: reminder.message,
        notificationLayout: NotificationLayout.Default,
      ),
    );
  }

  void _saveReminder() async {
    if (_formKey.currentState!.validate()) {
      final reminderProvider = Provider.of<ReminderProvider>(context, listen: false);

      final newReminder = Reminder(
        userId: '',
        message: _messageController.text,
        scheduledTime: _scheduledDateTime,
        isActive: _isActive,
      );

      Reminder? savedReminder;

      if (widget.reminder == null) {
        savedReminder = await reminderProvider.addReminder(context, newReminder);
      } else {
        final updatedReminder = Reminder(
          id: widget.reminder!.id,
          userId: widget.reminder!.userId,
          message: _messageController.text,
          scheduledTime: _scheduledDateTime,
          isActive: _isActive,
        );
        await reminderProvider.updateReminder(widget.reminder!.id!, updatedReminder);
        savedReminder = updatedReminder;
      }

      if (_isActive && savedReminder != null) {
        await scheduleNotification(savedReminder);
      }

      if (reminderProvider.errorMessage == null) {
        Navigator.of(context).pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(reminderProvider.errorMessage!)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(widget.reminder == null ? 'Add New Reminder' : 'Edit Reminder'),
        backgroundColor: const Color(0xFF4CAF50),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _messageController,
                decoration: InputDecoration(
                  labelText: 'Reminder Message',
                  hintText: 'e.g., Time to journal!',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  prefixIcon: const Icon(Icons.message, color: Color(0xFF4CAF50)),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a message';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => _selectDate(context),
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'Date',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          prefixIcon: const Icon(Icons.calendar_today, color: Color(0xFF4CAF50)),
                        ),
                        child: Text(
                          DateFormat('MMM dd, yyyy').format(_scheduledDateTime),
                          style: const TextStyle(fontSize: 16, color: Color(0xFF1A1A1A)),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: InkWell(
                      onTap: () => _selectTime(context),
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'Time',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          prefixIcon: const Icon(Icons.access_time, color: Color(0xFF4CAF50)),
                        ),
                        child: Text(
                          DateFormat('hh:mm a').format(_scheduledDateTime),
                          style: const TextStyle(fontSize: 16, color: Color(0xFF1A1A1A)),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SwitchListTile(
                title: const Text('Active Reminder'),
                value: _isActive,
                onChanged: (bool value) {
                  setState(() {
                    _isActive = value;
                  });
                },
                activeColor: const Color(0xFF4CAF50),
              ),
              const SizedBox(height: 30),
              Center(
                child: Consumer<ReminderProvider>(
                  builder: (context, reminderProvider, child) {
                    return ElevatedButton.icon(
                      onPressed: reminderProvider.isLoading ? null : _saveReminder,
                      icon: reminderProvider.isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Icon(Icons.save, color: Colors.white),
                      label: Text(
                        widget.reminder == null ? 'Add Reminder' : 'Update Reminder',
                        style: const TextStyle(fontSize: 18, color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4CAF50),
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
