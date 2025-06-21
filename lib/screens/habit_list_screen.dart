import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/habit_provider.dart';
import '../providers/user_provider.dart';
import '../models/habit_model.dart';
import '../models/user_model.dart';
import '../widgets/sunflower_fireworks.dart';

class HabitListScreen extends StatelessWidget {
  const HabitListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<HabitProvider, UserProvider>(
      builder: (context, habitProvider, userProvider, child) {
        if (habitProvider.habits.isEmpty) {
          return const Center(
            child: Text('No habits yet. Add some habits to get started!'),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            await habitProvider.loadHabitsForUser(userProvider.currentUser!.id!);
          },
          child: ListView.builder(
            itemCount: habitProvider.habits.length,
            itemBuilder: (context, index) {
              final habit = habitProvider.habits[index];
              return HabitCard(
                habit: habit,
                currentUser: userProvider.currentUser!,
              );
            },
          ),
        );
      },
    );
  }
}

class HabitCard extends StatefulWidget {
  final Habit habit;
  final User currentUser;

  const HabitCard({
    super.key,
    required this.habit,
    required this.currentUser,
  });

  @override
  State<HabitCard> createState() => _HabitCardState();
}

class _HabitCardState extends State<HabitCard> {
  bool _isCompletedToday = false;
  bool _partnerCompletedToday = false;

  @override
  void initState() {
    super.initState();
    _checkCompletion();
  }

  Future<void> _checkCompletion() async {
    final habitProvider = context.read<HabitProvider>();
    final userId = widget.currentUser.id!;
    final partnerId = widget.habit.partnerId;

    final isCompleted = await habitProvider.isHabitCompletedToday(widget.habit.id!, userId);

    bool partnerCompleted = false;
    if (widget.habit.isShared && partnerId != null) {
      partnerCompleted = await habitProvider.isHabitCompletedToday(widget.habit.id!, partnerId);
    }

    if (!mounted) return;
    setState(() {
      _isCompletedToday = isCompleted;
      _partnerCompletedToday = partnerCompleted;
    });
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final habitProvider = Provider.of<HabitProvider>(context, listen: false);

    return Card(
      margin: const EdgeInsets.all(8.0),
      child: ListTile(
        title: Text(widget.habit.title),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.habit.description),
            const SizedBox(height: 4),
            Text(
              widget.habit.isShared ? 'Shared Habit' : 'Personal Habit',
              style: TextStyle(
                fontSize: 12,
                color: widget.habit.isShared ? Colors.blue : Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            widget.habit.isShared
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildStatusCircle(_isCompletedToday, isSelf: true),
                      const SizedBox(width: 8),
                      _buildStatusCircle(_partnerCompletedToday, isSelf: false),
                    ],
                  )
                : GestureDetector(
                    onTap: _isCompletedToday ? null : _completeHabit,
                    child: _buildStatusCircle(_isCompletedToday, isSelf: true),
                  ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () async {
                final userId = userProvider.currentUser!.id!;
                await habitProvider.deleteHabit(widget.habit.id!, userId);
                await habitProvider.loadHabitsForUser(userId);
              },
              tooltip: 'Habit löschen',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCircle(bool completed, {required bool isSelf}) {
    return GestureDetector(
      onTap: isSelf && !completed ? _completeHabit : null,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: completed ? Colors.green : Colors.grey[300],
        ),
        child: Icon(
          completed ? Icons.check : (isSelf ? Icons.touch_app : Icons.person),
          color: completed ? Colors.white : Colors.grey[600],
          size: 20,
        ),
      ),
    );
  }

  Future<void> _completeHabit() async {
    final habitProvider = context.read<HabitProvider>();
    final userId = widget.currentUser.id!;
    final partnerId = widget.habit.partnerId;

    await habitProvider.completeHabit(widget.habit.id!, userId);
    await _checkCompletion();

    if (!mounted) return;

    final bothCompleted = widget.habit.isShared && _partnerCompletedToday && _isCompletedToday;

    if (bothCompleted) {
      // Animation zeigen
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const SunflowerFireworks(),
      );

      await Future.delayed(const Duration(seconds: 5));
      if (!mounted) return;
      Navigator.of(context).pop();
    }

    // Snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${widget.habit.title} completed!'),
        backgroundColor: Colors.green,
      ),
    );
  }
}
