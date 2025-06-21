class Habit {
  final int? id;
  final String title;
  final String description;
  final int? userId; // null for shared habits
  final bool isShared;
  final int? partnerId;
  final List<String> reminderTimes;
  final DateTime createdAt;
  final bool isActive;

  Habit({
    this.id,
    required this.title,
    required this.description,
    this.userId,
    required this.isShared,
    this.partnerId, 
    required this.reminderTimes,
    required this.createdAt,
    this.isActive = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'user_id': userId,
      'is_shared': isShared ? 1 : 0,
      'partnerId': partnerId, 
      'reminder_times': reminderTimes.join(','),
      'created_at': createdAt.millisecondsSinceEpoch,
      'is_active': isActive ? 1 : 0,
    };
  }
  factory Habit.fromMap(Map<String, dynamic> map) {
    int? parseNullableInt(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      if (value is String && value.isNotEmpty) return int.tryParse(value);
      return null;
    }

    List<String> parseReminderTimes(dynamic value) {
      if (value == null) return [];
      if (value is String) {
        return value
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();
      }
      if (value is List) {
        return List<String>.from(value.map((e) => e.toString()));
      }
      return [];
    }

    return Habit(
      id: parseNullableInt(map['id']) ?? 0,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      userId: parseNullableInt(map['user_id']),
      isShared: map['is_shared'] == 1,
      partnerId: parseNullableInt(map['partnerId']),
      reminderTimes: parseReminderTimes(map['reminder_times']),
      createdAt: map['created_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['created_at'])
          : DateTime.now(),
      isActive: map['is_active'] == 1,
    );
  }
}

class HabitCompletion {
  final int? id;
  final int habitId;
  final int userId;
  final DateTime completedAt;
  final String? note;

  HabitCompletion({
    this.id,
    required this.habitId,
    required this.userId,
    required this.completedAt,
    this.note,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'habit_id': habitId,
      'user_id': userId,
      'completed_at': completedAt.millisecondsSinceEpoch,
      'note': note,
    };
  }

  factory HabitCompletion.fromMap(Map<String, dynamic> map) {
    int? parseNullableInt(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      if (value is String && value.isNotEmpty) return int.tryParse(value);
      return null;
    }

    int parseIntWithDefault(dynamic value, int defaultValue) {
      if (value == null) return defaultValue;
      if (value is int) return value;
      if (value is String && value.isNotEmpty) return int.tryParse(value) ?? defaultValue;
      return defaultValue;
    }

    int parseTimestamp(dynamic value) {
      if (value == null) return DateTime.now().millisecondsSinceEpoch;
      if (value is int) return value;
      if (value is String && value.isNotEmpty) return int.tryParse(value) ?? DateTime.now().millisecondsSinceEpoch;
      return DateTime.now().millisecondsSinceEpoch;
    }

    return HabitCompletion(
      id: parseNullableInt(map['id']),
      habitId: parseIntWithDefault(map['habit_id'], 0),
      userId: parseIntWithDefault(map['user_id'], 0),
      completedAt: DateTime.fromMillisecondsSinceEpoch(parseTimestamp(map['completed_at'])),
      note: map['note'],
    );
  }
}

