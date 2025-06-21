import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/habit_provider.dart';
import '../providers/user_provider.dart';
import '../models/habit_model.dart';

class AddHabitScreen extends StatefulWidget {
  const AddHabitScreen({super.key});

  @override
  State<AddHabitScreen> createState() => _AddHabitScreenState();
}

class _AddHabitScreenState extends State<AddHabitScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isShared = false;
  int? _selectedPartnerId;
  final List<TimeOfDay> _reminderTimes = [];

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final currentUser = userProvider.currentUser!;
    final partners = userProvider.users.where((u) => u.id != currentUser.id).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Add New Habit')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Habit Title',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 20),
              SwitchListTile(
                title: const Text('Shared Habit'),
                subtitle: const Text('Both users can see and complete this habit'),
                value: _isShared,
                onChanged: (value) {
                  setState(() {
                    _isShared = value;
                    if (!value) {
                      _selectedPartnerId = null;
                    }
                  });
                },
              ),
              if (_isShared)
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: DropdownButtonFormField<int>(
                    decoration: const InputDecoration(
                      labelText: 'Select Partner',
                      border: OutlineInputBorder(),
                    ),
                    items: partners.map((user) {
                      return DropdownMenuItem<int>(
                        value: user.id,
                        child: Text(user.name),
                      );
                    }).toList(),
                    value: partners.any((u) => u.id == _selectedPartnerId) ? _selectedPartnerId : null,
                    onChanged: (val) {
                      setState(() {
                        _selectedPartnerId = val;
                      });
                    },
                    validator: (val) {
                      if (_isShared && val == null) {
                        return 'Please select a partner';
                      }
                      return null;
                    },
                  ),
                ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Reminder Times',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: _addReminderTime,
                    child: const Text('Add Time'),
                  ),
                ],
              ),
              if (_reminderTimes.isNotEmpty)
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _reminderTimes.map((time) {
                    return Chip(
                      label: Text(time.format(context)),
                      onDeleted: () {
                        setState(() {
                          _reminderTimes.remove(time);
                        });
                      },
                    );
                  }).toList(),
                ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _createHabit,
                  child: const Text('Create Habit'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _addReminderTime() async {
    final TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (time != null) {
      setState(() {
        _reminderTimes.add(time);
      });
    }
  }

  Future<void> _createHabit() async {
    if (_formKey.currentState!.validate()) {
      final userProvider = context.read<UserProvider>();
      final habitProvider = context.read<HabitProvider>();
      final currentUser = userProvider.currentUser!;

      final habit = Habit(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        userId: _isShared ? null : userProvider.currentUser!.id,
        isShared: _isShared,
        partnerId: _isShared ? _selectedPartnerId : null,
        reminderTimes: _reminderTimes.map((time) => '${time.hour}:${time.minute}').toList(),
        createdAt: DateTime.now(),
        isActive: true,
      );

      await habitProvider.addHabit(habit);

      _titleController.clear();
      _descriptionController.clear();
      setState(() {
        _isShared = false;
        _selectedPartnerId = null;
        _reminderTimes.clear();
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Habit created successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}

