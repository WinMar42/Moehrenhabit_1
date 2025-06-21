import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'models/habit_model.dart';
import 'models/user_model.dart';
import 'services/database_service.dart';
import 'services/notification_service.dart';
import 'screens/home_screen.dart';
import 'providers/habit_provider.dart';
import 'providers/user_provider.dart';
import 'screens/opening_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize services
  await DatabaseService.instance.initDatabase();
  await NotificationService.instance.initialize();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => HabitProvider()),
      ],
      child: MaterialApp(
        title: 'Habit Tracker',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
        ),
        home: const OpeningScreen(),
      ),
    );
  }
}

