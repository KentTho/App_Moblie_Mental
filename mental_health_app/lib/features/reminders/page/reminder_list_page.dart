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
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
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
      appBar: AppBar(
        title: const Text('Journaling Reminders'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Consumer<ReminderProvider>(
        builder: (context, reminderProvider, child) {
          if (reminderProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (reminderProvider.errorMessage != null) {
            return Center(
              child: Text(
                'Error: ${reminderProvider.errorMessage}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          }
          if (reminderProvider.reminders.isEmpty) {
            return const Center(
              child: Text(
                'No reminders set yet. Tap + to add one!',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: reminderProvider.reminders.length,
            itemBuilder: (context, index) {
              final reminder = reminderProvider.reminders[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  title: Text(
                    reminder.message,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 5),
                      Text(
                        'Scheduled: ${DateFormat('MMM dd, yyyy - hh:mm a').format(reminder.scheduledTime)}',
                        style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                      ),
                      Text(
                        'Status: ${reminder.isActive ? 'Active' : 'Inactive'}',
                        style: TextStyle(
                          fontSize: 14,
                          color: reminder.isActive ? Colors.green : Colors.red,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _navigateToReminderForm(reminder: reminder),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
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
        backgroundColor: Colors.deepPurple,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
