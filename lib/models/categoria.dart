import 'package:flutter/material.dart';

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

  String get nombreFormatted => nombre;
}