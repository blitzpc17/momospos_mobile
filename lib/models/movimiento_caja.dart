import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MovimientoCaja {
  int? id;
  int idCaja;
  int idUsuario;
  String tipoMovimiento; // 'venta', 'pago_proveedor', 'deposito', 'retiro', 'gasto'
  String concepto;
  String? descripcion;
  double monto;
  String metodoPago;
  String? referencia;
  int? idRelacion;
  DateTime fechaMovimiento;

  // Propiedades relacionadas
  String? usuarioNombre;
  String? cajaFolio;

  MovimientoCaja({
    this.id,
    required this.idCaja,
    required this.idUsuario,
    required this.tipoMovimiento,
    required this.concepto,
    this.descripcion,
    required this.monto,
    this.metodoPago = 'efectivo',
    this.referencia,
    this.idRelacion,
    required this.fechaMovimiento,
    this.usuarioNombre,
    this.cajaFolio,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'id_caja': idCaja,
      'id_usuario': idUsuario,
      'tipo_movimiento': tipoMovimiento,
      'concepto': concepto,
      'descripcion': descripcion,
      'monto': monto,
      'metodo_pago': metodoPago,
      'referencia': referencia,
      'id_relacion': idRelacion,
      'fecha_movimiento': fechaMovimiento.toIso8601String(),
    };
  }

  factory MovimientoCaja.fromMap(Map<String, dynamic> map) {
    return MovimientoCaja(
      id: map['id'],
      idCaja: map['id_caja'],
      idUsuario: map['id_usuario'],
      tipoMovimiento: map['tipo_movimiento'],
      concepto: map['concepto'],
      descripcion: map['descripcion'],
      monto: map['monto']?.toDouble() ?? 0.0,
      metodoPago: map['metodo_pago'] ?? 'efectivo',
      referencia: map['referencia'],
      idRelacion: map['id_relacion'],
      fechaMovimiento: DateTime.parse(map['fecha_movimiento']),
      usuarioNombre: map['usuario_nombre'],
      cajaFolio: map['caja_folio'],
    );
  }

  String get montoFormatted => '\$${monto.toStringAsFixed(2)}';
  String get fechaMovimientoFormatted => DateFormat('dd/MM/yyyy HH:mm').format(fechaMovimiento);
  
  Color get colorTipo {
    switch (tipoMovimiento) {
      case 'venta':
        return Colors.green;
      case 'deposito':
        return Colors.blue;
      case 'pago_proveedor':
      case 'gasto':
        return Colors.red;
      case 'retiro':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
  
  IconData get iconoTipo {
    switch (tipoMovimiento) {
      case 'venta':
        return Icons.shopping_cart;
      case 'deposito':
        return Icons.add_circle;
      case 'pago_proveedor':
        return Icons.account_balance;
      case 'gasto':
        return Icons.money_off;
      case 'retiro':
        return Icons.remove_circle;
      default:
        return Icons.attach_money;
    }
  }
  
  String get tipoFormatted {
    switch (tipoMovimiento) {
      case 'venta':
        return 'Venta';
      case 'deposito':
        return 'Depósito';
      case 'pago_proveedor':
        return 'Pago Proveedor';
      case 'gasto':
        return 'Gasto';
      case 'retiro':
        return 'Retiro';
      default:
        return tipoMovimiento;
    }
  }
}