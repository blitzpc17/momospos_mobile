import 'package:flutter/material.dart';

class Product {
  int? id;
  String codigo;
  String nombre;
  String descripcion;
  int idCategoria;
  double precioCompra;
  double precioVenta;
  double stock;
  double stockMinimo;
  String unidadMedida;
  bool aplicaIva;
  String? imagenUrl;
  String? imagenes;
  bool activo;
  DateTime fechaCreacion;

  // Propiedades calculadas/relacionadas (no están en DB)
  String? categoriaNombre;
  Color? categoriaColor;

  Product({
    this.id,
    required this.codigo,
    required this.nombre,
    required this.descripcion,
    required this.idCategoria,
    required this.precioCompra,
    required this.precioVenta,
    required this.stock,
    this.stockMinimo = 0,
    this.unidadMedida = 'pieza',
    this.aplicaIva = true,
    this.imagenUrl,
    this.imagenes,
    this.activo = true,
    required this.fechaCreacion,
    this.categoriaNombre,
    this.categoriaColor,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'codigo': codigo,
      'nombre': nombre,
      'descripcion': descripcion,
      'id_categoria': idCategoria,
      'precio_compra': precioCompra,
      'precio_venta': precioVenta,
      'stock': stock,
      'stock_minimo': stockMinimo,
      'unidad_medida': unidadMedida,
      'aplica_iva': aplicaIva ? 1 : 0,
      'imagen_url': imagenUrl,
      'imagenes': imagenes,
      'activo': activo ? 1 : 0,
      'fecha_creacion': fechaCreacion.toIso8601String(),
    };
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'],
      codigo: map['codigo'] ?? '',
      nombre: map['nombre'],
      descripcion: map['descripcion'] ?? '',
      idCategoria: map['id_categoria'],
      precioCompra: map['precio_compra']?.toDouble() ?? 0.0,
      precioVenta: map['precio_venta']?.toDouble() ?? 0.0,
      stock: map['stock']?.toDouble() ?? 0.0,
      stockMinimo: map['stock_minimo']?.toDouble() ?? 0.0,
      unidadMedida: map['unidad_medida'] ?? 'pieza',
      aplicaIva: map['aplica_iva'] == 1,
      imagenUrl: map['imagen_url'],
      imagenes: map['imagenes'],
      activo: map['activo'] == 1,
      fechaCreacion: DateTime.parse(map['fecha_creacion']),
      categoriaNombre: map['categoria_nombre'],
    );
  }

  // Para mostrar en UI
  String get precioVentaFormatted => '\$${precioVenta.toStringAsFixed(2)}';
  String get stockFormatted => '${stock.toStringAsFixed(2)} $unidadMedida';
  bool get bajoStock => stock <= stockMinimo;
}

class Categoria {
  int? id;
  String nombre;
  String? color;
  String? imagenUrl;
  int orden;
  bool activo;

  Categoria({
    this.id,
    required this.nombre,
    this.color,
    this.imagenUrl,
    this.orden = 0,
    this.activo = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'color': color,
      'imagen_url': imagenUrl,
      'orden': orden,
      'activo': activo ? 1 : 0,
    };
  }

  factory Categoria.fromMap(Map<String, dynamic> map) {
    return Categoria(
      id: map['id'],
      nombre: map['nombre'],
      color: map['color'],
      imagenUrl: map['imagen_url'],
      orden: map['orden'] ?? 0,
      activo: map['activo'] == 1,
    );
  }

  Color get colorAsColor {
    if (color == null || color!.isEmpty) return Colors.blue;
    try {
      return Color(int.parse(color!.replaceFirst('#', '0xFF')));
    } catch (e) {
      return Colors.blue;
    }
  }
}