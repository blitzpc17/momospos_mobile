import 'package:flutter/material.dart';

import '../models/models.dart';
import '../services/database_service.dart';

class SaleProvider with ChangeNotifier {
  List<Venta> _ventas = [];
  List<VentaDetalle> _carrito = [];
  List<Cliente> _clientes = [];
  Caja? _cajaActiva;
  DatabaseService _dbService = DatabaseService();
  double _descuentoGlobal = 0.0;
  Cliente? _clienteSeleccionado;
  String _metodoPago = 'efectivo';
  String? _observaciones;

  List<Venta> get ventas => _ventas;
  List<VentaDetalle> get carrito => _carrito;
  List<Cliente> get clientes => _clientes;
  Caja? get cajaActiva => _cajaActiva;
  double get descuentoGlobal => _descuentoGlobal;
  Cliente? get clienteSeleccionado => _clienteSeleccionado;
  String get metodoPago => _metodoPago;
  String? get observaciones => _observaciones;

  double get subtotal {
    return _carrito.fold(0, (sum, item) => sum + (item.precioUnitario * item.cantidad));
  }

  double get totalDescuentos {
    return _carrito.fold(0.0, (sum, item) => sum + item.descuento) + _descuentoGlobal;
  }

  double get ivaCalculado {
    final productosConIva = _carrito.where((item) {
      final producto = getProductoFromCarrito(item.idProducto);
      return producto?.aplicaIva ?? true;
    }).toList();
    
    final subtotalConIva = productosConIva.fold(
      0.0, 
      (sum, item) => sum + (item.precioUnitario * item.cantidad)
    );
    
    // Obtener porcentaje de IVA desde variables globales
    return subtotalConIva * 0.16; // Por defecto 16%, luego se puede obtener de la DB
  }

  double get total {
    return subtotal - totalDescuentos + ivaCalculado;
  }

  Future<void> loadCajaActiva() async {
    try {
      final db = await _dbService.database;
      final cajas = await db.rawQuery('''
        SELECT c.*, u.nombre as usuario_nombre 
        FROM cajas c
        LEFT JOIN usuarios u ON c.id_usuario = u.id
        WHERE c.estado = 'abierta'
        ORDER BY c.fecha_apertura DESC
        LIMIT 1
      ''');
      
      if (cajas.isNotEmpty) {
        _cajaActiva = Caja.fromMap(cajas.first);
      }
      notifyListeners();
    } catch (e) {
      print('Error cargando caja activa: $e');
    }
  }

  Future<bool> abrirCaja(double montoInicial, String? observaciones, int idUsuario) async {
    try {
      final db = await _dbService.database;
      final caja = Caja(
        idUsuario: idUsuario,
        fechaApertura: DateTime.now(),
        montoInicial: montoInicial,
        estado: 'abierta',
        observaciones: observaciones,
      );
      
      caja.id = await db.insert('cajas', caja.toMap());
      _cajaActiva = caja;
      notifyListeners();
      return true;
    } catch (e) {
      print('Error abriendo caja: $e');
      return false;
    }
  }

  Future<bool> cerrarCaja(double montoFinal, String? observaciones) async {
    if (_cajaActiva == null) return false;
    
    try {
      final db = await _dbService.database;
      await db.update(
        'cajas',
        {
          'fecha_cierre': DateTime.now().toIso8601String(),
          'monto_final': montoFinal,
          'estado': 'cerrada',
          'observaciones': observaciones,
        },
        where: 'id = ?',
        whereArgs: [_cajaActiva!.id],
      );
      
      _cajaActiva = null;
      notifyListeners();
      return true;
    } catch (e) {
      print('Error cerrando caja: $e');
      return false;
    }
  }

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
      notifyListeners();
      return cliente.id!;
    } catch (e) {
      print('Error agregando cliente: $e');
      return 0;
    }
  }

  void agregarProductoAlCarrito(Product producto, [double cantidad = 1]) {
    final existingIndex = _carrito.indexWhere(
      (item) => item.idProducto == producto.id,
    );

    if (existingIndex != -1) {
      _carrito[existingIndex].cantidad += cantidad;
      _carrito[existingIndex].total = 
          _carrito[existingIndex].precioUnitario * _carrito[existingIndex].cantidad;
    } else {
      _carrito.add(VentaDetalle(
        idVenta: 0,
        idProducto: producto.id!,
        cantidad: cantidad,
        precioUnitario: producto.precioVenta,
        total: producto.precioVenta * cantidad,
        fechaAgregado: DateTime.now(),
        productoNombre: producto.nombre,
        productoCodigo: producto.codigo,
      ));
    }
    notifyListeners();
  }

  void removerProductoDelCarrito(int productId) {
    _carrito.removeWhere((item) => item.idProducto == productId);
    notifyListeners();
  }

  void actualizarCantidadProducto(int productId, double cantidad) {
    final index = _carrito.indexWhere((item) => item.idProducto == productId);
    if (index != -1) {
      if (cantidad <= 0) {
        _carrito.removeAt(index);
      } else {
        _carrito[index].cantidad = cantidad;
        _carrito[index].total = _carrito[index].precioUnitario * cantidad;
      }
      notifyListeners();
    }
  }

  void setDescuentoGlobal(double descuento) {
    _descuentoGlobal = descuento;
    notifyListeners();
  }

  void setClienteSeleccionado(Cliente? cliente) {
    _clienteSeleccionado = cliente;
    notifyListeners();
  }

  void setMetodoPago(String metodo) {
    _metodoPago = metodo;
    notifyListeners();
  }

  void setObservaciones(String? observaciones) {
    _observaciones = observaciones;
    notifyListeners();
  }

  void limpiarCarrito() {
    _carrito.clear();
    _descuentoGlobal = 0.0;
    _clienteSeleccionado = null;
    _metodoPago = 'efectivo';
    _observaciones = null;
    notifyListeners();
  }

  Product? getProductoFromCarrito(int productId) {
    // Esto necesitaría acceso al ProductProvider
    // Se manejará en la pantalla de ventas
    return null;
  }

  Future<Venta> procesarVenta(int idUsuario) async {
    if (_cajaActiva == null) {
      throw Exception('No hay caja abierta');
    }

    if (_carrito.isEmpty) {
      throw Exception('El carrito está vacío');
    }

    final db = await _dbService.database;
    
    // Calcular totales finales
    final venta = Venta(
      idCaja: _cajaActiva!.id!,
      idUsuario: idUsuario,
      idCliente: _clienteSeleccionado?.id,
      fechaVenta: DateTime.now(),
      subtotal: subtotal,
      descuento: totalDescuentos,
      iva: ivaCalculado,
      total: total,
      metodoPago: _metodoPago,
      estado: 'completada',
      observaciones: _observaciones,
    );

    // Iniciar transacción
    await db.transaction((txn) async {
      // Insertar venta (el trigger generará el folio automáticamente)
      venta.id = await txn.insert('ventas', venta.toMap());
      
      // Insertar detalles de venta
      for (var detalle in _carrito) {
        detalle.idVenta = venta.id!;
        await txn.insert('venta_detalles', detalle.toMap());
      }

      // Registrar movimiento de caja
      await txn.insert('movimientos_caja', {
        'id_caja': _cajaActiva!.id,
        'id_usuario': idUsuario,
        'tipo_movimiento': 'ingreso',
        'concepto': 'Venta ${venta.folio ?? ""}',
        'descripcion': 'Venta realizada',
        'monto': total,
        'metodo_pago': _metodoPago,
        'referencia': venta.folio,
        'id_relacion': venta.id,
        'fecha_movimiento': DateTime.now().toIso8601String(),
      });

      // Actualizar monto final de caja (aproximado, se podría calcular sumando movimientos)
      await txn.rawUpdate(
        'UPDATE cajas SET monto_final = COALESCE(monto_final, monto_inicial) + ? WHERE id = ?',
        [total, _cajaActiva!.id],
      );
    });

    // Obtener el folio generado por el trigger
    final ventaCompleta = await db.query(
      'ventas',
      where: 'id = ?',
      whereArgs: [venta.id],
    );
    
    if (ventaCompleta.isNotEmpty) {
      venta.folio = ventaCompleta.first['folio'] as String?;
    }

    // Limpiar carrito después de la venta
    limpiarCarrito();
    
    // Agregar a la lista de ventas
    _ventas.insert(0, venta);
    notifyListeners();
    
    return venta;
  }

  Future<void> loadVentas({DateTime? desde, DateTime? hasta}) async {
    try {
      final db = await _dbService.database;
      
      String where = '';
      List<Object?> whereArgs = [];
      
      if (desde != null && hasta != null) {
        where = 'WHERE fecha_venta BETWEEN ? AND ?';
        whereArgs = [
          desde.toIso8601String(),
          hasta.add(Duration(days: 1)).toIso8601String(),
        ];
      }
      
      final ventasList = await db.rawQuery('''
        SELECT v.*, 
               u.nombre as usuario_nombre,
               c.nombre as cliente_nombre,
               ca.id as caja_id
        FROM ventas v
        LEFT JOIN usuarios u ON v.id_usuario = u.id
        LEFT JOIN clientes c ON v.id_cliente = c.id
        LEFT JOIN cajas ca ON v.id_caja = ca.id
        $where
        ORDER BY v.fecha_venta DESC
      ''', whereArgs);
      
      _ventas = ventasList.map((map) => Venta.fromMap(map)).toList();
      notifyListeners();
    } catch (e) {
      print('Error cargando ventas: $e');
    }
  }
}