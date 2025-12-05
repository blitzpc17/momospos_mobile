import 'package:sqflite/sqflite.dart';
import '../models/models.dart';

class ModuleService {
  final Database _database;

  ModuleService(this._database);

  // Método para obtener todos los módulos
  Future<List<Module>> getModules() async {
    try {
      final result = await _database.rawQuery('''
        SELECT * FROM modulos 
        ORDER BY seccion, orden
      ''');
      
      return result.map((map) => Module.fromMap(map)).toList();
    } catch (e) {
      print('Error en getModules: $e');
      return [];
    }
  }

  // Método para obtener módulos activos
  Future<List<Module>> getActiveModules() async {
    try {
      final result = await _database.rawQuery('''
        SELECT * FROM modulos 
        WHERE activo = 1
        ORDER BY seccion, orden
      ''');
      
      return result.map((map) => Module.fromMap(map)).toList();
    } catch (e) {
      print('Error en getActiveModules: $e');
      return [];
    }
  }

  // Método para obtener módulos por sección
  Future<List<Module>> getModulesBySection(String seccion) async {
    try {
      final result = await _database.rawQuery('''
        SELECT * FROM modulos 
        WHERE seccion = ? AND activo = 1
        ORDER BY orden
      ''', [seccion]);
      
      return result.map((map) => Module.fromMap(map)).toList();
    } catch (e) {
      print('Error en getModulesBySection: $e');
      return [];
    }
  }

  // Método para obtener módulo por ID
  Future<Module?> getModuleById(int id) async {
    try {
      final result = await _database.query(
        'modulos',
        where: 'id = ?',
        whereArgs: [id],
      );
      
      if (result.isNotEmpty) {
        return Module.fromMap(result.first);
      }
      return null;
    } catch (e) {
      print('Error en getModuleById: $e');
      return null;
    }
  }

  // Método para obtener módulo por nombre
  Future<Module?> getModuleByName(String nombre) async {
    try {
      final result = await _database.query(
        'modulos',
        where: 'nombre = ?',
        whereArgs: [nombre],
      );
      
      if (result.isNotEmpty) {
        return Module.fromMap(result.first);
      }
      return null;
    } catch (e) {
      print('Error en getModuleByName: $e');
      return null;
    }
  }

  // Método para crear módulo
  Future<int> createModule(Module module) async {
    try {
      return await _database.insert('modulos', module.toMap());
    } catch (e) {
      print('Error en createModule: $e');
      return 0;
    }
  }

  // Método para actualizar módulo
  Future<int> updateModule(Module module) async {
    try {
      return await _database.update(
        'modulos',
        module.toMap(),
        where: 'id = ?',
        whereArgs: [module.id],
      );
    } catch (e) {
      print('Error en updateModule: $e');
      return 0;
    }
  }

  // Método para eliminar módulo
  Future<int> deleteModule(int id) async {
    try {
      return await _database.delete(
        'modulos',
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      print('Error en deleteModule: $e');
      return 0;
    }
  }

  // Método para desactivar módulo (soft delete)
  Future<int> deactivateModule(int id) async {
    try {
      return await _database.update(
        'modulos',
        {'activo': 0},
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      print('Error en deactivateModule: $e');
      return 0;
    }
  }

  // Método para activar módulo
  Future<int> activateModule(int id) async {
    try {
      return await _database.update(
        'modulos',
        {'activo': 1},
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      print('Error en activateModule: $e');
      return 0;
    }
  }

  // Método para obtener secciones únicas
  Future<List<String>> getUniqueSections() async {
    try {
      final result = await _database.rawQuery('''
        SELECT DISTINCT seccion 
        FROM modulos 
        WHERE activo = 1
        ORDER BY seccion
      ''');
      
      return result.map((map) => map['seccion'] as String).toList();
    } catch (e) {
      print('Error en getUniqueSections: $e');
      return [];
    }
  }

  // Método para obtener el siguiente orden disponible en una sección
  Future<int> getNextOrderForSection(String seccion) async {
    try {
      final result = await _database.rawQuery('''
        SELECT MAX(orden) as max_orden 
        FROM modulos 
        WHERE seccion = ?
      ''', [seccion]);
      
      if (result.isNotEmpty && result.first['max_orden'] != null) {
        return (result.first['max_orden'] as int) + 1;
      }
      return 0;
    } catch (e) {
      print('Error en getNextOrderForSection: $e');
      return 0;
    }
  }

  // Método para verificar si existe un módulo con el mismo nombre
  Future<bool> moduleNameExists(String nombre, {int? excludeId}) async {
    try {
      String query = 'SELECT COUNT(*) as count FROM modulos WHERE nombre = ?';
      List<dynamic> args = [nombre];
      
      if (excludeId != null) {
        query += ' AND id != ?';
        args.add(excludeId);
      }
      
      final result = await _database.rawQuery(query, args);
      
      if (result.isNotEmpty) {
        final count = result.first['count'] as int;
        return count > 0;
      }
      return false;
    } catch (e) {
      print('Error en moduleNameExists: $e');
      return false;
    }
  }

  // Método para obtener estadísticas de módulos
  Future<Map<String, dynamic>> getModuleStats() async {
    try {
      final totalResult = await _database.rawQuery('''
        SELECT COUNT(*) as total FROM modulos
      ''');
      
      final activeResult = await _database.rawQuery('''
        SELECT COUNT(*) as active FROM modulos WHERE activo = 1
      ''');
      
      final sectionsResult = await _database.rawQuery('''
        SELECT seccion, COUNT(*) as count 
        FROM modulos 
        WHERE activo = 1
        GROUP BY seccion
      ''');
      
      return {
        'total': totalResult.isNotEmpty ? (totalResult.first['total'] as int) : 0,
        'active': activeResult.isNotEmpty ? (activeResult.first['active'] as int) : 0,
        'inactive': (totalResult.isNotEmpty ? (totalResult.first['total'] as int) : 0) - 
                    (activeResult.isNotEmpty ? (activeResult.first['active'] as int) : 0),
        'sections': sectionsResult.map((row) {
          return {
            'section': row['seccion'] as String,
            'count': row['count'] as int,
          };
        }).toList(),
      };
    } catch (e) {
      print('Error en getModuleStats: $e');
      return {};
    }
  }

  // Método para reordenar módulos en una sección
  Future<bool> reorderModules(List<Module> modules) async {
    try {
      await _database.transaction((txn) async {
        for (var module in modules) {
          await txn.update(
            'modulos',
            {'orden': module.orden},
            where: 'id = ?',
            whereArgs: [module.id],
          );
        }
      });
      return true;
    } catch (e) {
      print('Error en reorderModules: $e');
      return false;
    }
  }

  // Método para buscar módulos
  Future<List<Module>> searchModules(String query) async {
    try {
      final result = await _database.rawQuery('''
        SELECT * FROM modulos 
        WHERE nombre LIKE ? OR seccion LIKE ? OR ruta LIKE ?
        ORDER BY seccion, orden
      ''', ['%$query%', '%$query%', '%$query%']);
      
      return result.map((map) => Module.fromMap(map)).toList();
    } catch (e) {
      print('Error en searchModules: $e');
      return [];
    }
  }
}