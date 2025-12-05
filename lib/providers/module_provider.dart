import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/module_service.dart';
import '../services/database_service.dart';

class ModuleProvider with ChangeNotifier {
  List<Module> _modules = [];
  late ModuleService _moduleService;
  bool _isLoading = false;

  List<Module> get modules => _modules;
  bool get isLoading => _isLoading;

  ModuleProvider() {
    _initializeService();
  }

  Future<void> _initializeService() async {
    final db = await DatabaseService().database;
    _moduleService = ModuleService(db);
  }

  Future<void> loadModules() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      await _initializeService(); // Asegurar que el servicio esté inicializado
      final modulesList = await _moduleService.getModules();
      _modules = modulesList;
    } catch (e) {
      print('Error cargando módulos: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadActiveModules() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      await _initializeService();
      final modulesList = await _moduleService.getActiveModules();
      _modules = modulesList;
    } catch (e) {
      print('Error cargando módulos activos: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<int> addModule(Module module) async {
    try {
      await _initializeService();
      
      // Verificar si el nombre ya existe
      final exists = await _moduleService.moduleNameExists(module.nombre);
      if (exists) {
        throw Exception('Ya existe un módulo con el nombre "${module.nombre}"');
      }
      
      final id = await _moduleService.createModule(module);
      if (id > 0) {
        // CORREGIDO: Usar copyWith en lugar de asignar directamente
        final moduleWithId = module.copyWith(id: id);
        _modules.add(moduleWithId);
        _sortModules();
        notifyListeners();
      }
      return id;
    } catch (e) {
      print('Error agregando módulo: $e');
      rethrow;
    }
  }

  Future<bool> updateModule(Module updatedModule) async {
    try {
      await _initializeService();
      
      // Verificar si el nombre ya existe (excluyendo el actual)
      final exists = await _moduleService.moduleNameExists(updatedModule.nombre, excludeId: updatedModule.id);
      if (exists) {
        throw Exception('Ya existe un módulo con el nombre "${updatedModule.nombre}"');
      }
      
      final result = await _moduleService.updateModule(updatedModule);
      if (result > 0) {
        final index = _modules.indexWhere((m) => m.id == updatedModule.id);
        if (index != -1) {
          // CORREGIDO: Reemplazar directamente el módulo actualizado
          _modules[index] = updatedModule;
        }
        _sortModules();
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      print('Error actualizando módulo: $e');
      rethrow;
    }
  }

  Future<bool> deleteModule(int id) async {
    try {
      await _initializeService();
      final result = await _moduleService.deleteModule(id);
      if (result > 0) {
        _modules.removeWhere((m) => m.id == id);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      print('Error eliminando módulo: $e');
      return false;
    }
  }

  Future<bool> toggleModuleStatus(int id) async {
    try {
      await _initializeService();
      final module = _modules.firstWhere((m) => m.id == id);
      final newStatus = !module.activo;
      
      final result = newStatus 
          ? await _moduleService.activateModule(id)
          : await _moduleService.deactivateModule(id);
      
      if (result > 0) {
        // CORREGIDO: Usar copyWith para actualizar el estado
        final updatedModule = module.copyWith(activo: newStatus);
        final index = _modules.indexWhere((m) => m.id == id);
        if (index != -1) {
          _modules[index] = updatedModule;
        }
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      print('Error cambiando estado del módulo: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>> getModuleStats() async {
    try {
      await _initializeService();
      return await _moduleService.getModuleStats();
    } catch (e) {
      print('Error obteniendo estadísticas: $e');
      return {};
    }
  }

  Future<bool> reorderModulesInSection(String section, List<Module> modules) async {
    try {
      await _initializeService();
      final success = await _moduleService.reorderModules(modules);
      if (success) {
        // CORREGIDO: Usar copyWith para actualizar el orden
        for (var module in modules) {
          final index = _modules.indexWhere((m) => m.id == module.id);
          if (index != -1) {
            _modules[index] = _modules[index].copyWith(orden: module.orden);
          }
        }
        _sortModules();
        notifyListeners();
      }
      return success;
    } catch (e) {
      print('Error reordenando módulos: $e');
      return false;
    }
  }

  List<Module> getModulesBySection(String seccion) {
    return _modules
        .where((module) => module.seccion == seccion)
        .toList()
        ..sort((a, b) => a.orden.compareTo(b.orden));
  }

  List<String> getSeccionesUnicas() {
    return _modules
        .map((m) => m.seccion)
        .toSet()
        .toList()
        ..sort();
  }

  Module? getModuleById(int id) {
    try {
      return _modules.firstWhere((module) => module.id == id);
    } catch (e) {
      return null;
    }
  }

  Module? getModuleByName(String nombre) {
    try {
      return _modules.firstWhere((module) => module.nombre == nombre);
    } catch (e) {
      return null;
    }
  }

  Future<int> getNextOrderForSection(String seccion) async {
    try {
      await _initializeService();
      return await _moduleService.getNextOrderForSection(seccion);
    } catch (e) {
      print('Error obteniendo siguiente orden: $e');
      return 0;
    }
  }

  List<Module> searchModules(String query) {
    if (query.isEmpty) return _modules;
    
    final lowercaseQuery = query.toLowerCase();
    return _modules.where((module) {
      return module.nombre.toLowerCase().contains(lowercaseQuery) ||
             module.seccion.toLowerCase().contains(lowercaseQuery) ||
             (module.ruta?.toLowerCase().contains(lowercaseQuery) ?? false);
    }).toList();
  }

  void _sortModules() {
    _modules.sort((a, b) {
      final sectionCompare = a.seccion.compareTo(b.seccion);
      if (sectionCompare != 0) return sectionCompare;
      return a.orden.compareTo(b.orden);
    });
  }
}