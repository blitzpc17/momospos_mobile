import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/database_service.dart';

class CajaProvider with ChangeNotifier {
  List<MovimientoCaja> _movimientos = [];
  List<Caja> _cajas = [];
  DatabaseService _dbService = DatabaseService();

  List<MovimientoCaja> get movimientos => _movimientos;
  List<Caja> get cajas => _cajas;

  Future<void> loadMovimientosCaja({DateTime? desde, DateTime? hasta}) async {
    try {
      final db = await _dbService.database;
      
      String where = '';
      List<Object?> whereArgs = [];
      
      if (desde != null && hasta != null) {
        where = 'WHERE fecha_movimiento BETWEEN ? AND ?';
        whereArgs = [
          desde.toIso8601String(),
          hasta.add(Duration(days: 1)).toIso8601String(),
        ];
      }
      
      final movimientosList = await db.rawQuery('''
        SELECT m.*, 
               u.nombre as usuario_nombre,
               c.id as caja_id
        FROM movimientos_caja m
        LEFT JOIN usuarios u ON m.id_usuario = u.id
        LEFT JOIN cajas c ON m.id_caja = c.id
        $where
        ORDER BY m.fecha_movimiento DESC
      ''', whereArgs);
      
      _movimientos = movimientosList.map((map) => MovimientoCaja.fromMap(map)).toList();
      notifyListeners();
    } catch (e) {
      print('Error cargando movimientos de caja: $e');
    }
  }

  Future<void> loadCajas() async {
    try {
      final db = await _dbService.database;
      final cajasList = await db.rawQuery('''
        SELECT c.*, u.nombre as usuario_nombre 
        FROM cajas c
        LEFT JOIN usuarios u ON c.id_usuario = u.id
        ORDER BY c.fecha_apertura DESC
      ''');
      
      _cajas = cajasList.map((map) => Caja.fromMap(map)).toList();
      notifyListeners();
    } catch (e) {
      print('Error cargando cajas: $e');
    }
  }

  Future<Map<String, dynamic>> getResumenCaja(int idCaja) async {
    try {
      final db = await _dbService.database;
      
      // Obtener totales por tipo de movimiento
      final result = await db.rawQuery('''
        SELECT 
          tipo_movimiento,
          SUM(monto) as total
        FROM movimientos_caja
        WHERE id_caja = ?
        GROUP BY tipo_movimiento
      ''', [idCaja]);
      
      double totalVentas = 0;
      double totalPagos = 0;
      double totalDepositos = 0;
      double totalRetiros = 0;
      double totalGastos = 0;
      
      for (var row in result) {
        final tipo = row['tipo_movimiento'] as String;
        final total = (row['total'] as num?)?.toDouble() ?? 0.0;
        
        switch (tipo) {
          case 'venta':
            totalVentas = total;
            break;
          case 'pago_proveedor':
            totalPagos = total;
            break;
          case 'deposito':
            totalDepositos = total;
            break;
          case 'retiro':
            totalRetiros = total;
            break;
          case 'gasto':
            totalGastos = total;
            break;
        }
      }
      
      return {
        'ventas': totalVentas,
        'pagos_proveedores': totalPagos,
        'depositos': totalDepositos,
        'retiros': totalRetiros,
        'gastos': totalGastos,
        'total_movimientos': totalVentas + totalDepositos - totalPagos - totalRetiros - totalGastos,
      };
    } catch (e) {
      print('Error obteniendo resumen de caja: $e');
      return {};
    }
  }

  Future<int> registrarMovimiento(MovimientoCaja movimiento) async {
    try {
      final db = await _dbService.database;
      movimiento.id = await db.insert('movimientos_caja', movimiento.toMap());
      _movimientos.insert(0, movimiento);
      notifyListeners();
      return movimiento.id!;
    } catch (e) {
      print('Error registrando movimiento: $e');
      return 0;
    }
  }
}