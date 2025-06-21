import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/habit_model.dart';
import '../models/user_model.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._internal();
  factory DatabaseService() => instance;
  DatabaseService._internal();

  Database? _database;

  Future<Database> get database async {
    _database ??= await initDatabase();
    return _database!;
  }

  Future<Database> initDatabase() async {
    String path = join(await getDatabasesPath(), 'habit_tracker.db');
    return await openDatabase(
      path,
      version: 2, // Version erhöht
      onCreate: _createDatabase,
      onUpgrade: _upgradeDatabase,  // Upgrade Handler hinzugefügt
    );
  }

  Future<void> _upgradeDatabase(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Beispiel: Spalte 'partnerId' zur Tabelle 'habits' hinzufügen
      await db.execute('ALTER TABLE habits ADD COLUMN partnerId INTEGER');
    }

    // Falls in Zukunft weitere Updates kommen, hier weitere if-Blöcke anfügen.
  }
  
  Future<void> _createDatabase(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT UNIQUE NOT NULL,
        created_at INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE habits (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT,
        user_id INTEGER,
        is_shared INTEGER NOT NULL DEFAULT 0,
        partnerId INTEGER,
        reminder_times TEXT,
        created_at INTEGER NOT NULL,
        is_active INTEGER NOT NULL DEFAULT 1,
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
    ''');

    await db.execute('''
      CREATE TABLE habit_completions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        habit_id INTEGER NOT NULL,
        user_id INTEGER NOT NULL,
        completed_at INTEGER NOT NULL,
        note TEXT,
        FOREIGN KEY (habit_id) REFERENCES habits (id),
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
    ''');
  }

  // User methods
  Future<int> insertUser(User user) async {
    final db = await database;
    return await db.insert('users', user.toMap());
  }

  Future<List<User>> getUsers() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('users');
    return List.generate(maps.length, (i) => User.fromMap(maps[i]));
  }

  Future<User?> getOtherUser(int currentUserId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'id != ?',
      whereArgs: [currentUserId],
      limit: 1,
    );
    return maps.isNotEmpty ? User.fromMap(maps.first) : null;
  }

  // Habit methods
  Future<int> insertHabit(Habit habit) async {
    final db = await database;
    return await db.insert('habits', habit.toMap());
  }

  Future<List<Habit>> getHabits() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'habits',
      where: 'is_active = ?',
      whereArgs: [1],
    );
    return List.generate(maps.length, (i) => Habit.fromMap(maps[i]));
  }

  Future<List<Habit>> getHabitsForUser(int userId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'habits',
      where: 'is_active = ? AND (user_id = ? OR is_shared = ?)',
      whereArgs: [1, userId, 1],
    );
    return List.generate(maps.length, (i) => Habit.fromMap(maps[i]));
  }

  // Habit completion methods
  Future<int> insertHabitCompletion(HabitCompletion completion) async {
    final db = await database;
    return await db.insert('habit_completions', completion.toMap());
  }

  Future<List<HabitCompletion>> getHabitCompletions(int habitId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'habit_completions',
      where: 'habit_id = ?',
      whereArgs: [habitId],
    );
    return List.generate(maps.length, (i) => HabitCompletion.fromMap(maps[i]));
  }

  Future<bool> isHabitCompletedToday(int habitId, int userId) async {
    final db = await database;
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final List<Map<String, dynamic>> maps = await db.query(
      'habit_completions',
      where: 'habit_id = ? AND user_id = ? AND completed_at >= ? AND completed_at < ?',
      whereArgs: [habitId, userId, startOfDay.millisecondsSinceEpoch, endOfDay.millisecondsSinceEpoch],
    );
    return maps.isNotEmpty;
  }

  Future<Map<String, bool>> getSharedHabitCompletionStatus(int habitId) async {
    final users = await getUsers();
    Map<String, bool> completionStatus = {};
    
    for (User user in users) {
      bool isCompleted = await isHabitCompletedToday(habitId, user.id!);
      completionStatus[user.name] = isCompleted;
    }
    
    return completionStatus;
  }

  Future<bool> isSharedHabitCompletelyFinished(int habitId) async {
    final users = await getUsers();
    for (User user in users) {
      bool isCompleted = await isHabitCompletedToday(habitId, user.id!);
      if (!isCompleted) return false;
    }
    return users.isNotEmpty;
  }
  Future<void> completeHabit(int habitId, int userId) async {
  final db = await database;

  final now = DateTime.now();
  final startOfDay = DateTime(now.year, now.month, now.day).millisecondsSinceEpoch;

  // Prüfen, ob der Nutzer heute schon bestätigt hat
  final existing = await db.query(
    'habit_completions',
    where: 'habit_id = ? AND user_id = ? AND completed_at >= ?',
    whereArgs: [habitId, userId, startOfDay],
  );

  if (existing.isEmpty) {
    await db.insert('habit_completions', {
      'habit_id': habitId,
      'user_id': userId,
      'completed_at': now.millisecondsSinceEpoch,
    });
  }
}
Future<void> undoCompletion(int habitId, int userId) async {
  final db = await database;

  final now = DateTime.now();
  final startOfDay = DateTime(now.year, now.month, now.day).millisecondsSinceEpoch;

  await db.delete(
    'habit_completions',
    where: 'habit_id = ? AND user_id = ? AND completed_at >= ?',
    whereArgs: [habitId, userId, startOfDay],
  );
}
// Soft delete: is_active auf 0 setzen
Future<int> deleteHabit(int habitId) async {
  final db = await database;
  return await db.update(
    'habits',
    {'is_active': 0},
    where: 'id = ?',
    whereArgs: [habitId],
  );
}

// Optional: Komplettes Löschen von Habit und dazugehörigen Completions
Future<int> removeHabit(int habitId) async {
  final db = await database;
  await db.delete('habit_completions', where: 'habit_id = ?', whereArgs: [habitId]);
  return await db.delete('habits', where: 'id = ?', whereArgs: [habitId]);
}

}
