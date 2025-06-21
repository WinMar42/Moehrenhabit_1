import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../providers/habit_provider.dart';
import '../models/user_model.dart';
import 'user_setup_screen.dart';
import 'habit_list_screen.dart';
import 'add_habit_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await context.read<UserProvider>().loadUsers();
    await context.read<HabitProvider>().loadHabits();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        if (userProvider.users.isEmpty) {
          return const UserSetupScreen();
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Habit Tracker'),
            actions: [
              PopupMenuButton<User>(
                onSelected: (User user) {
                  userProvider.setCurrentUser(user);
                  context.read<HabitProvider>().loadHabitsForUser(user.id!);
                },
                itemBuilder: (BuildContext context) {
                  return userProvider.users.map((User user) {
                    return PopupMenuItem<User>(
                      value: user,
                      child: Text(user.name),
                    );
                  }).toList();
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(userProvider.currentUser?.name ?? 'User'),
                      const Icon(Icons.arrow_drop_down),
                    ],
                  ),
                ),
              ),
            ],
          ),
          body: IndexedStack(
            index: _selectedIndex,
            children: const [
              HabitListScreen(),
              AddHabitScreen(),
            ],
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.list),
                label: 'Habits',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.add),
                label: 'Add Habit',
              ),
            ],
          ),
        );
      },
    );
  }
}

