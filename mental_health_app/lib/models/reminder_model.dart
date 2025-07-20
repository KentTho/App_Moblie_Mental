// lib/models/reminder_model.dart
// For @required
// For UUID generation (if needed client-side)

class Reminder {
  final String? id; // Optional for creation, required for existing reminders
  final String userId;
  final String message;
  final DateTime scheduledTime;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Reminder({
    this.id,
    required this.userId,
    required this.message,
    required this.scheduledTime,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  factory Reminder.fromJson(Map<String, dynamic> json) {
    return Reminder(
      id: json['id'],
      userId: json['user_id'],
      message: json['message'],
      scheduledTime: DateTime.parse(json['scheduled_time']),
      isActive: json['is_active'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'message': message,
      'scheduled_time': scheduledTime.toIso8601String(),
      'is_active': isActive,
    };
  }

  Map<String, dynamic> toUpdateJson() {
    return {
      'message': message,
      'scheduled_time': scheduledTime.toIso8601String(),
      'is_active': isActive,
    };
  }
}
