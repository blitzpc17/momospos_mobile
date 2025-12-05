import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/database_service.dart';

class ClienteProvider with ChangeNotifier {
  List<Cliente> _clientes = [];
  DatabaseService _dbService = DatabaseService();

  List<Cliente> get clientes => _clientes;

  Future<void> loadClientes() async {
    try {
      final db = await _dbService.database;
      final clientesList = await db.query(
        'clientes',
        orderBy: 'nombre',
      );
      
      _clientes = clientesList.map((map) => Cliente.fromMap(map)).toList();
      notifyListeners();
    } catch (e) {
      print('Error cargando clientes: $e');
    }
  }

  Future<int> addCliente(Cliente cliente) async {
    try {
      final db = await _dbService.database;
      cliente.id = await db.insert('clientes', cliente.toMap());
      _clientes.add(cliente);
      _clientes.sort((a, b) => a.nombre.compareTo(b.nombre));
      notifyListeners();
      return cliente.id!;
    } catch (e) {
      print('Error agregando cliente: $e');
      return 0;
    }
  }

  Future<bool> updateCliente(Cliente cliente) async {
    try {
      final db = await _dbService.database;
      await db.update(
        'clientes',
        cliente.toMap(),
        where: 'id = ?',
        whereArgs: [cliente.id],
      );
      
      final index = _clientes.indexWhere((c) => c.id == cliente.id);
      if (index != -1) {
        _clientes[index] = cliente;
      }
      
      notifyListeners();
      return true;
    } catch (e) {
      print('Error actualizando cliente: $e');
      return false;
    }
  }

  Future<bool> deleteCliente(int id) async {
    try {
      final db = await _dbService.database;
      await db.delete(
        'clientes',
        where: 'id = ?',
        whereArgs: [id],
      );
      
      _clientes.removeWhere((c) => c.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      print('Error eliminando cliente: $e');
      return false;
    }
  }

  List<Cliente> searchClientes(String query) {
    if (query.isEmpty) return _clientes;
    
    final lowercaseQuery = query.toLowerCase();
    return _clientes.where((cliente) {
      return cliente.nombre.toLowerCase().contains(lowercaseQuery) ||
             (cliente.telefono?.toLowerCase().contains(lowercaseQuery) ?? false) ||
             (cliente.email?.toLowerCase().contains(lowercaseQuery) ?? false);
    }).toList();
  }

  Cliente? getClienteById(int id) {
    try {
      return _clientes.firstWhere((cliente) => cliente.id == id);
    } catch (e) {
      return null;
    }
  }
}