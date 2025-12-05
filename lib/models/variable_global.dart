import 'package:intl/intl.dart';

class VariableGlobal {
  int? id;
  String nombre;
  String? valor;
  String? descripcion;
  DateTime fechaActualizacion;

  VariableGlobal({
    this.id,
    required this.nombre,
    this.valor,
    this.descripcion,
    required this.fechaActualizacion,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'valor': valor,
      'descripcion': descripcion,
      'fecha_actualizacion': fechaActualizacion.toIso8601String(),
    };
  }

  factory VariableGlobal.fromMap(Map<String, dynamic> map) {
    return VariableGlobal(
      id: map['id'],
      nombre: map['nombre'],
      valor: map['valor'],
      descripcion: map['descripcion'],
      fechaActualizacion: DateTime.parse(map['fecha_actualizacion']),
    );
  }

  String get fechaActualizacionFormatted {
    return DateFormat('dd/MM/yyyy HH:mm').format(fechaActualizacion);
  }

  // Métodos para tipos específicos
  double get valorAsDouble => double.tryParse(valor ?? '0') ?? 0.0;
  int get valorAsInt => int.tryParse(valor ?? '0') ?? 0;
  bool get valorAsBool => valor?.toLowerCase() == 'true' || valor == '1';
}