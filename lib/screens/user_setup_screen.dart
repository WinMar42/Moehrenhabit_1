import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../models/user_model.dart';

class UserSetupScreen extends StatefulWidget {
  const UserSetupScreen({super.key});

  @override
  State<UserSetupScreen> createState() => _UserSetupScreenState();
}

class _UserSetupScreenState extends State<UserSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _user1NameController = TextEditingController();
  final _user1EmailController = TextEditingController();
  final _user2NameController = TextEditingController();
  final _user2EmailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Setup Users'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const Text(
                'Setup two users for the habit tracker',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              const Text('User 1'),
              TextFormField(
                controller: _user1NameController,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _user1EmailController,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              const Text('User 2'),
              TextFormField(
                controller: _user2NameController,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _user2EmailController,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _createUsers,
                child: const Text('Create Users'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _createUsers() async {
    if (_formKey.currentState!.validate()) {
      final userProvider = context.read<UserProvider>();
      
      final user1 = User(
        name: _user1NameController.text,
        email: _user1EmailController.text,
        createdAt: DateTime.now(),
      );
      
      final user2 = User(
        name: _user2NameController.text,
        email: _user2EmailController.text,
        createdAt: DateTime.now(),
      );

      await userProvider.addUser(user1);
      await userProvider.addUser(user2);
    }
  }
}
