import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/database_service.dart';

class ProveedorProvider with ChangeNotifier {
  List<Proveedor> _proveedores = [];
  DatabaseService _dbService = DatabaseService();

  List<Proveedor> get proveedores => _proveedores;

  Future<void> loadProveedores() async {
    try {
      final db = await _dbService.database;
      final proveedoresList = await db.query(
        'proveedores',
        orderBy: 'nombre',
      );
      
      _proveedores = proveedoresList.map((map) => Proveedor.fromMap(map)).toList();
      notifyListeners();
    } catch (e) {
      print('Error cargando proveedores: $e');
    }
  }

  Future<int> addProveedor(Proveedor proveedor) async {
    try {
      final db = await _dbService.database;
      proveedor.id = await db.insert('proveedores', proveedor.toMap());
      _proveedores.add(proveedor);
      _proveedores.sort((a, b) => a.nombre.compareTo(b.nombre));
      notifyListeners();
      return proveedor.id!;
    } catch (e) {
      print('Error agregando proveedor: $e');
      return 0;
    }
  }

  Future<bool> updateProveedor(Proveedor proveedor) async {
    try {
      final db = await _dbService.database;
      await db.update(
        'proveedores',
        proveedor.toMap(),
        where: 'id = ?',
        whereArgs: [proveedor.id],
      );
      
      final index = _proveedores.indexWhere((p) => p.id == proveedor.id);
      if (index != -1) {
        _proveedores[index] = proveedor;
      }
      
      notifyListeners();
      return true;
    } catch (e) {
      print('Error actualizando proveedor: $e');
      return false;
    }
  }

  List<Proveedor> searchProveedores(String query) {
    if (query.isEmpty) return _proveedores;
    
    final lowercaseQuery = query.toLowerCase();
    return _proveedores.where((proveedor) {
      return proveedor.nombre.toLowerCase().contains(lowercaseQuery) ||
             (proveedor.contacto?.toLowerCase().contains(lowercaseQuery) ?? false) ||
             (proveedor.telefono?.toLowerCase().contains(lowercaseQuery) ?? false) ||
             (proveedor.rfc?.toLowerCase().contains(lowercaseQuery) ?? false);
    }).toList();
  }

  Proveedor? getProveedorById(int id) {
    try {
      return _proveedores.firstWhere((proveedor) => proveedor.id == id);
    } catch (e) {
      return null;
    }
  }
}