import 'package:flutter/foundation.dart';
import '../models/module_model.dart';
import '../services/database_service.dart';

class ModuleProvider with ChangeNotifier {
  List<Module> _modules = [];
  bool _isLoading = false;
  String _errorMessage = '';

  List<Module> get modules => _modules;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  Future<void> loadModules() async {
    _isLoading = true;
    notifyListeners();

    try {
      _modules = await DatabaseService().getModules();
      _errorMessage = '';
    } catch (e) {
      _errorMessage = 'Error al cargar módulos: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<Module> getModulesBySection(String section) {
    return _modules.where((module) => module.seccion == section).toList();
  }

  void clearError() {
    _errorMessage = '';
    notifyListeners();
  }
}