import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../services/database_service.dart';

class AuthProvider with ChangeNotifier {
  User? _currentUser;
  bool _isLoading = false;
  bool _isInitializing = false;
  String _errorMessage = '';

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isInitializing => _isInitializing;
  String get errorMessage => _errorMessage;
  bool get isAuthenticated => _currentUser != null;

  // Método para inicializar la base de datos
  Future<bool> initializeDatabase() async {
    _isInitializing = true;
    notifyListeners();

    try {
      // Esto creará la base de datos si no existe
      await DatabaseService().database;
      _isInitializing = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Error al inicializar la base de datos: $e';
      _isInitializing = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> login(String username, String password) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      // Primero nos aseguramos de que la base de datos esté lista
      await DatabaseService().database;
      
      final user = await DatabaseService().authenticateUser(username, password);
      
      if (user != null) {
        _currentUser = user;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Usuario o contraseña incorrectos';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Error al iniciar sesión: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void logout() {
    _currentUser = null;
    _errorMessage = '';
    notifyListeners();
  }

  void clearError() {
    _errorMessage = '';
    notifyListeners();
  }
}