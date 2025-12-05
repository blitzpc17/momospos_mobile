import 'package:intl/intl.dart';

class Compra {
  int? id;
  int? idProveedor;
  int idUsuario;
  DateTime fechaCompra;
  double total;
  String? observaciones;

  // Propiedades relacionadas
  String? proveedorNombre;
  String? usuarioNombre;

  Compra({
    this.id,
    this.idProveedor,
    required this.idUsuario,
    required this.fechaCompra,
    required this.total,
    this.observaciones,
    this.proveedorNombre,
    this.usuarioNombre,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'id_proveedor': idProveedor,
      'id_usuario': idUsuario,
      'fecha_compra': fechaCompra.toIso8601String(),
      'total': total,
      'observaciones': observaciones,
    };
  }

  factory Compra.fromMap(Map<String, dynamic> map) {
    return Compra(
      id: map['id'],
      idProveedor: map['id_proveedor'],
      idUsuario: map['id_usuario'],
      fechaCompra: DateTime.parse(map['fecha_compra']),
      total: map['total']?.toDouble() ?? 0.0,
      observaciones: map['observaciones'],
      proveedorNombre: map['proveedor_nombre'],
      usuarioNombre: map['usuario_nombre'],
    );
  }

  String get totalFormatted => '\$${total.toStringAsFixed(2)}';
  String get fechaCompraFormatted => DateFormat('dd/MM/yyyy HH:mm').format(fechaCompra);
}

class CompraDetalle {
  int? id;
  int idCompra;
  int idProducto;
  double cantidad;
  double precioUnitario;
  double total;

  // Propiedades relacionadas
  String? productoNombre;
  String? productoCodigo;

  CompraDetalle({
    this.id,
    required this.idCompra,
    required this.idProducto,
    required this.cantidad,
    required this.precioUnitario,
    required this.total,
    this.productoNombre,
    this.productoCodigo,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'id_compra': idCompra,
      'id_producto': idProducto,
      'cantidad': cantidad,
      'precio_unitario': precioUnitario,
      'total': total,
    };
  }

  factory CompraDetalle.fromMap(Map<String, dynamic> map) {
    return CompraDetalle(
      id: map['id'],
      idCompra: map['id_compra'],
      idProducto: map['id_producto'],
      cantidad: map['cantidad']?.toDouble() ?? 0.0,
      precioUnitario: map['precio_unitario']?.toDouble() ?? 0.0,
      total: map['total']?.toDouble() ?? 0.0,
      productoNombre: map['producto_nombre'],
      productoCodigo: map['producto_codigo'],
    );
  }

  String get totalFormatted => '\$${total.toStringAsFixed(2)}';
  String get precioUnitarioFormatted => '\$${precioUnitario.toStringAsFixed(2)}';
}