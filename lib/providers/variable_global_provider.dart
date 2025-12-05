import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/database_service.dart';

class VariableGlobalProvider with ChangeNotifier {
  List<VariableGlobal> _variables = [];
  DatabaseService _dbService = DatabaseService();

  List<VariableGlobal> get variables => _variables;

  Future<void> loadVariables() async {
    try {
      final db = await _dbService.database;
      final variablesList = await db.query(
        'variables_globales',
        orderBy: 'nombre',
      );
      
      _variables = variablesList.map((map) => VariableGlobal.fromMap(map)).toList();
      notifyListeners();
    } catch (e) {
      print('Error cargando variables globales: $e');
    }
  }

  Future<bool> updateVariable(VariableGlobal variable) async {
    try {
      final db = await _dbService.database;
      await db.update(
        'variables_globales',
        variable.toMap(),
        where: 'id = ?',
        whereArgs: [variable.id],
      );
      
      final index = _variables.indexWhere((v) => v.id == variable.id);
      if (index != -1) {
        _variables[index] = variable;
      }
      
      notifyListeners();
      return true;
    } catch (e) {
      print('Error actualizando variable: $e');
      return false;
    }
  }

  String? getVariableValue(String nombre) {
    try {
      return _variables.firstWhere((v) => v.nombre == nombre).valor;
    } catch (e) {
      return null;
    }
  }

  double getIVA() {
    final valor = getVariableValue('iva_porcentaje');
    return double.tryParse(valor ?? '0.16') ?? 0.16;
  }

  String getNombreTienda() {
    return getVariableValue('nombre_tienda') ?? "MOMO'S POS";
  }

  String getDireccionTienda() {
    return getVariableValue('direccion_tienda') ?? 'Calle Principal #123';
  }

  String getTelefonoTienda() {
    return getVariableValue('telefono_tienda') ?? '555-1234';
  }
}