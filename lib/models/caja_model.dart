import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Caja {
  int? id;
  int idUsuario;
  DateTime fechaApertura;
  DateTime? fechaCierre;
  double montoInicial;
  double? montoFinal;
  String estado;
  String? observaciones;

  // Propiedades relacionadas
  String? usuarioNombre;
  double? montoEfectivo;
  double? montoTarjeta;
  double? montoTransferencia;
  int? numeroVentas;

  Caja({
    this.id,
    required this.idUsuario,
    required this.fechaApertura,
    this.fechaCierre,
    required this.montoInicial,
    this.montoFinal,
    this.estado = 'abierta',
    this.observaciones,
    this.usuarioNombre,
    this.montoEfectivo,
    this.montoTarjeta,
    this.montoTransferencia,
    this.numeroVentas,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'id_usuario': idUsuario,
      'fecha_apertura': fechaApertura.toIso8601String(),
      'fecha_cierre': fechaCierre?.toIso8601String(),
      'monto_inicial': montoInicial,
      'monto_final': montoFinal,
      'estado': estado,
      'observaciones': observaciones,
    };
  }

  factory Caja.fromMap(Map<String, dynamic> map) {
    return Caja(
      id: map['id'],
      idUsuario: map['id_usuario'],
      fechaApertura: DateTime.parse(map['fecha_apertura']),
      fechaCierre: map['fecha_cierre'] != null ? DateTime.parse(map['fecha_cierre']) : null,
      montoInicial: map['monto_inicial']?.toDouble() ?? 0.0,
      montoFinal: map['monto_final']?.toDouble(),
      estado: map['estado'] ?? 'abierta',
      observaciones: map['observaciones'],
      usuarioNombre: map['usuario_nombre'],
      montoEfectivo: map['monto_efectivo']?.toDouble(),
      montoTarjeta: map['monto_tarjeta']?.toDouble(),
      montoTransferencia: map['monto_transferencia']?.toDouble(),
      numeroVentas: map['numero_ventas'],
    );
  }

  String get folio => 'CAJA-${id?.toString().padLeft(4, '0')}';
  
  double get diferenciaCaja {
    if (montoFinal == null) return 0;
    return montoFinal! - montoInicial;
  }

  String get fechaAperturaFormatted {
    try {
      return DateFormat('dd/MM/yyyy HH:mm').format(fechaApertura);
    } catch (e) {
      return '--/--/---- --:--';
    }
  }

  String? get fechaCierreFormatted {
    if (fechaCierre == null) return null;
    try {
      return DateFormat('dd/MM/yyyy HH:mm').format(fechaCierre!);
    } catch (e) {
      return '--/--/---- --:--';
    }
  }

  String get montoInicialFormatted => '\$${montoInicial.toStringAsFixed(2)}';
  String get montoFinalFormatted => montoFinal != null ? '\$${montoFinal!.toStringAsFixed(2)}' : '--';
  String get diferenciaFormatted => '\$${diferenciaCaja.toStringAsFixed(2)}';
  String get totalVentasFormatted => montoFinal != null ? '\$${(montoFinal! - montoInicial).toStringAsFixed(2)}' : '--';

  // Métodos para cálculos de ventas por método de pago
  double get totalEfectivo => montoEfectivo ?? 0;
  double get totalTarjeta => montoTarjeta ?? 0;
  double get totalTransferencia => montoTransferencia ?? 0;
  int get totalVentas => numeroVentas ?? 0;

  Color get estadoColor {
    switch (estado.toLowerCase()) {
      case 'abierta':
        return Colors.green;
      case 'cerrada':
        return Colors.blue;
      case 'pendiente':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  IconData get estadoIcon {
    switch (estado.toLowerCase()) {
      case 'abierta':
        return Icons.lock_open;
      case 'cerrada':
        return Icons.lock;
      case 'pendiente':
        return Icons.timelapse;
      default:
        return Icons.help;
    }
  }

  String get estadoText {
    switch (estado.toLowerCase()) {
      case 'abierta':
        return 'Abierta';
      case 'cerrada':
        return 'Cerrada';
      case 'pendiente':
        return 'Pendiente';
      default:
        return 'Desconocido';
    }
  }

  bool get isAbierta => estado.toLowerCase() == 'abierta';
  bool get isCerrada => estado.toLowerCase() == 'cerrada';
}