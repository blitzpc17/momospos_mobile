class Role {
  final int id;
  final String nombre;
  final String descripcion;
  final int nivelAcceso;
  final bool activo;
  final DateTime fechaCreacion;

  Role({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.nivelAcceso,
    required this.activo,
    required this.fechaCreacion,
  });

  factory Role.fromMap(Map<String, dynamic> map) {
    return Role(
      id: map['id'],
      nombre: map['nombre'],
      descripcion: map['descripcion'],
      nivelAcceso: map['nivel_acceso'],
      activo: map['activo'] == 1,
      fechaCreacion: DateTime.parse(map['fecha_creacion']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'descripcion': descripcion,
      'nivel_acceso': nivelAcceso,
      'activo': activo ? 1 : 0,
      'fecha_creacion': fechaCreacion.toIso8601String(),
    };
  }
}