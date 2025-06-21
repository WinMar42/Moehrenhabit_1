import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/database_service.dart';

class UserProvider with ChangeNotifier {
  List<User> _users = [];
  User? _currentUser;

  List<User> get users => _users;
  User? get currentUser => _currentUser;

  Future<void> loadUsers() async {
    _users = await DatabaseService.instance.getUsers();
    if (_users.isNotEmpty && _currentUser == null) {
      _currentUser = _users.first;
    }
    notifyListeners();
  }

  Future<void> addUser(User user) async {
    await DatabaseService.instance.insertUser(user);
    await loadUsers();
  }

  void setCurrentUser(User user) {
    _currentUser = user;
    notifyListeners();
  }
}
