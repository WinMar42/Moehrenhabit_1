import 'package:flutter/material.dart';
import '../models/habit_model.dart';
import '../services/database_service.dart';

class HabitProvider with ChangeNotifier {
  List<Habit> _habits = [];
  List<HabitCompletion> _completions = [];

  List<Habit> get habits => _habits;
  List<HabitCompletion> get completions => _completions;

  Future<void> loadHabits() async {
    _habits = await DatabaseService.instance.getHabits();
    notifyListeners();
  }

  Future<void> loadHabitsForUser(int userId) async {
    _habits = await DatabaseService.instance.getHabitsForUser(userId);
    notifyListeners();
  }

  Future<void> addHabit(Habit habit) async {
    await DatabaseService.instance.insertHabit(habit);
    await loadHabits();
  }

  Future<void> completeHabit(int habitId, int userId, {String? note}) async {
    final completion = HabitCompletion(
      habitId: habitId,
      userId: userId,
      completedAt: DateTime.now(),
      note: note,
    );
    await DatabaseService.instance.insertHabitCompletion(completion);
    notifyListeners();
  }

  Future<bool> isHabitCompletedToday(int habitId, int userId) async {
    return await DatabaseService.instance.isHabitCompletedToday(habitId, userId);
  }

Future<void> deleteHabit(int habitId, int userId) async {
  await DatabaseService.instance.deleteHabit(habitId);
  await loadHabitsForUser(userId);
}

}
