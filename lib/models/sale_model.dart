import 'package:intl/intl.dart';

class Venta {
  int? id;
  String? folio;
  int idCaja;
  int idUsuario;
  int? idCliente;
  DateTime fechaVenta;
  double subtotal;
  double descuento;
  double iva;
  double total;
  String metodoPago;
  String estado;
  String? observaciones;

  // Propiedades relacionadas
  String? usuarioNombre;
  String? clienteNombre;
  String? cajaFolio;

  Venta({
    this.id,
    this.folio,
    required this.idCaja,
    required this.idUsuario,
    this.idCliente,
    required this.fechaVenta,
    required this.subtotal,
    required this.descuento,
    required this.iva,
    required this.total,
    this.metodoPago = 'efectivo',
    this.estado = 'completada',
    this.observaciones,
    this.usuarioNombre,
    this.clienteNombre,
    this.cajaFolio,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'folio': folio,
      'id_caja': idCaja,
      'id_usuario': idUsuario,
      'id_cliente': idCliente,
      'fecha_venta': fechaVenta.toIso8601String(),
      'subtotal': subtotal,
      'descuento': descuento,
      'iva': iva,
      'total': total,
      'metodo_pago': metodoPago,
      'estado': estado,
      'observaciones': observaciones,
    };
  }

  factory Venta.fromMap(Map<String, dynamic> map) {
    return Venta(
      id: map['id'],
      folio: map['folio'],
      idCaja: map['id_caja'],
      idUsuario: map['id_usuario'],
      idCliente: map['id_cliente'],
      fechaVenta: DateTime.parse(map['fecha_venta']),
      subtotal: map['subtotal']?.toDouble() ?? 0.0,
      descuento: map['descuento']?.toDouble() ?? 0.0,
      iva: map['iva']?.toDouble() ?? 0.0,
      total: map['total']?.toDouble() ?? 0.0,
      metodoPago: map['metodo_pago'] ?? 'efectivo',
      estado: map['estado'] ?? 'completada',
      observaciones: map['observaciones'],
      usuarioNombre: map['usuario_nombre'],
      clienteNombre: map['cliente_nombre'],
      cajaFolio: map['caja_folio'],
    );
  }

  String get fechaFormatted => DateFormat('dd/MM/yyyy HH:mm').format(fechaVenta);
  String get totalFormatted => '\$${total.toStringAsFixed(2)}';
}





