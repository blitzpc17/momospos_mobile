import 'package:flutter/foundation.dart';
import '../models/role_model.dart';
import '../services/database_service.dart';

class RoleProvider with ChangeNotifier {
  List<Role> _roles = [];
  bool _isLoading = false;
  String _errorMessage = '';

  List<Role> get roles => _roles;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  Future<void> loadRoles() async {
    _isLoading = true;
    notifyListeners();

    try {
      _roles = await DatabaseService().getRoles();
      _errorMessage = '';
    } catch (e) {
      _errorMessage = 'Error al cargar roles: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createRole(Role role) async {
    try {
      await DatabaseService().createRole(role);
      await loadRoles();
      return true;
    } catch (e) {
      _errorMessage = 'Error al crear rol: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateRole(Role role) async {
    try {
      await DatabaseService().updateRole(role);
      await loadRoles();
      return true;
    } catch (e) {
      _errorMessage = 'Error al actualizar rol: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteRole(int id) async {
    try {
      await DatabaseService().deleteRole(id);
      await loadRoles();
      return true;
    } catch (e) {
      _errorMessage = 'Error al eliminar rol: $e';
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _errorMessage = '';
    notifyListeners();
  }
}