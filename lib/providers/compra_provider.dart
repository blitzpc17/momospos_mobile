import 'package:flutter/material.dart';
import '../models/compra.dart';
import '../services/database_service.dart';

class CompraProvider with ChangeNotifier {
  List<Compra> _compras = [];
  DatabaseService _dbService = DatabaseService();

  List<Compra> get compras => _compras;

  Future<void> loadCompras() async {
    try {
      final db = await _dbService.database;
      final comprasList = await db.rawQuery('''
        SELECT c.*, 
               p.nombre as proveedor_nombre,
               u.nombre as usuario_nombre
        FROM compras c
        LEFT JOIN proveedores p ON c.id_proveedor = p.id
        LEFT JOIN usuarios u ON c.id_usuario = u.id
        ORDER BY c.fecha_compra DESC
      ''');
      
      _compras = comprasList.map((map) => Compra.fromMap(map)).toList();
      notifyListeners();
    } catch (e) {
      print('Error cargando compras: $e');
    }
  }

  Future<int> addCompra(Compra compra, List<CompraDetalle> detalles) async {
    try {
      final db = await _dbService.database;
      
      await db.transaction((txn) async {
        // Insertar compra
        compra.id = await txn.insert('compras', compra.toMap());
        
        // Insertar detalles
        for (var detalle in detalles) {
          detalle.idCompra = compra.id!;
          await txn.insert('compra_detalles', detalle.toMap());
          
          // Actualizar stock del producto
          await txn.rawUpdate(
            'UPDATE productos SET stock = stock + ? WHERE id = ?',
            [detalle.cantidad, detalle.idProducto],
          );
        }
      });
      
      _compras.insert(0, compra);
      notifyListeners();
      return compra.id!;
    } catch (e) {
      print('Error agregando compra: $e');
      return 0;
    }
  }

  Future<List<CompraDetalle>> getDetallesCompra(int idCompra) async {
    try {
      final db = await _dbService.database;
      final detallesList = await db.rawQuery('''
        SELECT cd.*,
               p.nombre as producto_nombre,
               p.codigo as producto_codigo
        FROM compra_detalles cd
        LEFT JOIN productos p ON cd.id_producto = p.id
        WHERE cd.id_compra = ?
      ''', [idCompra]);
      
      return detallesList.map((map) => CompraDetalle.fromMap(map)).toList();
    } catch (e) {
      print('Error obteniendo detalles de compra: $e');
      return [];
    }
  }
}