import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../models/role_model.dart';
import '../services/database_service.dart';

class UserProvider with ChangeNotifier {
  List<User> _users = [];
  List<Role> _roles = [];
  bool _isLoading = false;
  String _errorMessage = '';

  List<User> get users => _users;
  List<Role> get roles => _roles;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  Future<void> loadUsers() async {
    _isLoading = true;
    notifyListeners();

    try {
      _users = await DatabaseService().getUsers();
      _errorMessage = '';
    } catch (e) {
      _errorMessage = 'Error al cargar usuarios: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadRoles() async {
    try {
      _roles = await DatabaseService().getRoles();
    } catch (e) {
      _errorMessage = 'Error al cargar roles: $e';
    }
    notifyListeners();
  }

  Future<bool> createUser(User user) async {
    try {
      await DatabaseService().createUser(user);
      await loadUsers(); // Recargar la lista
      return true;
    } catch (e) {
      _errorMessage = 'Error al crear usuario: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateUser(User user) async {
    try {
      await DatabaseService().updateUser(user);
      await loadUsers(); // Recargar la lista
      return true;
    } catch (e) {
      _errorMessage = 'Error al actualizar usuario: $e';
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _errorMessage = '';
    notifyListeners();
  }
}