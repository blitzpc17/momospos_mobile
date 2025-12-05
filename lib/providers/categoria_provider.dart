import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/database_service.dart';

class CategoriaProvider with ChangeNotifier {
  List<Categoria> _categorias = [];
  DatabaseService _dbService = DatabaseService();

  List<Categoria> get categorias => _categorias;

  Future<void> loadCategorias() async {
    try {
      final db = await _dbService.database;
      final categoriasList = await db.query(
        'categorias',
        where: 'activo = 1',
        orderBy: 'orden, nombre',
      );
      
      _categorias = categoriasList.map((map) => Categoria.fromMap(map)).toList();
      notifyListeners();
    } catch (e) {
      print('Error cargando categorías: $e');
    }
  }

  Future<int> addCategoria(Categoria categoria) async {
    try {
      final db = await _dbService.database;
      categoria.id = await db.insert('categorias', categoria.toMap());
      _categorias.add(categoria);
      _categorias.sort((a, b) => a.orden.compareTo(b.orden));
      notifyListeners();
      return categoria.id!;
    } catch (e) {
      print('Error agregando categoría: $e');
      return 0;
    }
  }

  Future<bool> updateCategoria(Categoria categoria) async {
    try {
      final db = await _dbService.database;
      await db.update(
        'categorias',
        categoria.toMap(),
        where: 'id = ?',
        whereArgs: [categoria.id],
      );
      
      final index = _categorias.indexWhere((c) => c.id == categoria.id);
      if (index != -1) {
        _categorias[index] = categoria;
      }
      
      notifyListeners();
      return true;
    } catch (e) {
      print('Error actualizando categoría: $e');
      return false;
    }
  }

  Future<bool> deleteCategoria(int id) async {
    try {
      final db = await _dbService.database;
      await db.update(
        'categorias',
        {'activo': 0},
        where: 'id = ?',
        whereArgs: [id],
      );
      
      _categorias.removeWhere((c) => c.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      print('Error eliminando categoría: $e');
      return false;
    }
  }

  Categoria? getCategoriaById(int id) {
    try {
      return _categorias.firstWhere((categoria) => categoria.id == id);
    } catch (e) {
      return null;
    }
  }
}