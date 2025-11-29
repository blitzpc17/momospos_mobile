class User {
  final int id;
  final String username;
  final String passwordHash;
  final String nombre;
  final int idRol;
  final bool activo;
  final DateTime fechaCreacion;
  final String? rolNombre;

  User({
    required this.id,
    required this.username,
    required this.passwordHash,
    required this.nombre,
    required this.idRol,
    required this.activo,
    required this.fechaCreacion,
    this.rolNombre,
  });

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      username: map['username'],
      passwordHash: map['password_hash'],
      nombre: map['nombre'],
      idRol: map['id_rol'],
      activo: map['activo'] == 1,
      fechaCreacion: DateTime.parse(map['fecha_creacion']),
      rolNombre: map['rol_nombre'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'password_hash': passwordHash,
      'nombre': nombre,
      'id_rol': idRol,
      'activo': activo ? 1 : 0,
      'fecha_creacion': fechaCreacion.toIso8601String(),
    };
  }
}