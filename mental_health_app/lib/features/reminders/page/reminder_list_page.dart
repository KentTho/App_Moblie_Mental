// lib/features/reminders/page/reminder_list_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mental_health_app/change_notifiers/reminder_provider.dart';
import 'package:mental_health_app/models/reminder_model.dart';
import 'package:mental_health_app/features/reminders/page/reminder_form_page.dart'; // For navigation
import 'package:intl/intl.dart'; // For date formatting

class ReminderListPage extends StatefulWidget {
  const ReminderListPage({super.key});

  @override
  State<ReminderListPage> createState() => _ReminderListPageState();
}

class _ReminderListPageState extends State<ReminderListPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ReminderProvider>(context, listen: false).fetchReminders(context);
    });
  }

  void _navigateToReminderForm({Reminder? reminder}) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReminderFormPage(reminder: reminder),
      ),
    );
    // Refresh reminders after returning from form
    if (mounted) {
      Provider.of<ReminderProvider>(context, listen: false).fetchReminders(context);
    }
  }

  void _confirmDelete(BuildContext context, String reminderId) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Delete Reminder'),
          content: const Text('Are you sure you want to delete this reminder?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              child: const Text('Delete', style: TextStyle(color: Color(0xFFE53935))),
              onPressed: () {
                Provider.of<ReminderProvider>(context, listen: false).deleteReminder(reminderId);
                Navigator.of(dialogContext).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Journaling Reminders'),
        backgroundColor: const Color(0xFF4CAF50), // xanh lá chủ đạo
      ),
      body: Consumer<ReminderProvider>(
        builder: (context, reminderProvider, child) {
          if (reminderProvider.isLoading) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF4CAF50)));
          }
          if (reminderProvider.errorMessage != null) {
            return Center(
              child: Text(
                'Error: ${reminderProvider.errorMessage}',
                style: const TextStyle(color: Color(0xFFE53935)),
              ),
            );
          }
          if (reminderProvider.reminders.isEmpty) {
            return const Center(
              child: Text(
                'No reminders set yet. Tap + to add one!',
                style: TextStyle(fontSize: 16, color: Color(0xFF9CA3AF)),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: reminderProvider.reminders.length,
            itemBuilder: (context, index) {
              final reminder = reminderProvider.reminders[index];
              return Container(
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF4CAF50).withOpacity(0.1),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  title: Text(
                    reminder.message,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 6),
                      Text(
                        'Scheduled: ${DateFormat('MMM dd, yyyy - hh:mm a').format(reminder.scheduledTime)}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF6B7280), // xám nhạt
                        ),
                      ),
                      Text(
                        'Status: ${reminder.isActive ? 'Active' : 'Inactive'}',
                        style: TextStyle(
                          fontSize: 14,
                          color: reminder.isActive ? const Color(0xFF4CAF50) : const Color(0xFFE53935),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Color(0xFF3B82F6)), // xanh dương pastel
                        onPressed: () => _navigateToReminderForm(reminder: reminder),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Color(0xFFE53935)), // đỏ nhấn mạnh
                        onPressed: () => _confirmDelete(context, reminder.id!),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToReminderForm(),
        backgroundColor: const Color(0xFF4CAF50), // xanh lá
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
