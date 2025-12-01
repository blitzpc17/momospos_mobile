class Cliente {
  int? id;
  String nombre;
  String? telefono;
  String? email;
  String? direccion;
  bool frecuente;
  String? notas;
  DateTime fechaRegistro;

  Cliente({
    this.id,
    required this.nombre,
    this.telefono,
    this.email,
    this.direccion,
    this.frecuente = false,
    this.notas,
    required this.fechaRegistro,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'telefono': telefono,
      'email': email,
      'direccion': direccion,
      'frecuente': frecuente ? 1 : 0,
      'notas': notas,
      'fecha_registro': fechaRegistro.toIso8601String(),
    };
  }

  factory Cliente.fromMap(Map<String, dynamic> map) {
    return Cliente(
      id: map['id'],
      nombre: map['nombre'],
      telefono: map['telefono'],
      email: map['email'],
      direccion: map['direccion'],
      frecuente: map['frecuente'] == 1,
      notas: map['notas'],
      fechaRegistro: DateTime.parse(map['fecha_registro']),
    );
  }
}