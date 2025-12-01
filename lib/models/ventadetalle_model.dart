class VentaDetalle {
  int? id;
  int idVenta;
  int idProducto;
  double cantidad;
  double precioUnitario;
  double descuento;
  double total;
  bool baja;
  DateTime fechaAgregado;

  // Propiedades relacionadas
  String? productoNombre;
  String? productoCodigo;

  VentaDetalle({
    this.id,
    required this.idVenta,
    required this.idProducto,
    required this.cantidad,
    required this.precioUnitario,
    this.descuento = 0,
    required this.total,
    this.baja = false,
    required this.fechaAgregado,
    this.productoNombre,
    this.productoCodigo,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'id_venta': idVenta,
      'id_producto': idProducto,
      'cantidad': cantidad,
      'precio_unitario': precioUnitario,
      'descuento': descuento,
      'total': total,
      'baja': baja ? 1 : 0,
      'fecha_agregado': fechaAgregado.toIso8601String(),
    };
  }

  factory VentaDetalle.fromMap(Map<String, dynamic> map) {
    return VentaDetalle(
      id: map['id'],
      idVenta: map['id_venta'],
      idProducto: map['id_producto'],
      cantidad: map['cantidad']?.toDouble() ?? 0.0,
      precioUnitario: map['precio_unitario']?.toDouble() ?? 0.0,
      descuento: map['descuento']?.toDouble() ?? 0.0,
      total: map['total']?.toDouble() ?? 0.0,
      baja: map['baja'] == 1,
      fechaAgregado: DateTime.parse(map['fecha_agregado']),
      productoNombre: map['producto_nombre'],
      productoCodigo: map['producto_codigo'],
    );
  }

  String get totalFormatted => '\$${total.toStringAsFixed(2)}';
}