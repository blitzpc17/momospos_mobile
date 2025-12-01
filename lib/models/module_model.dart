class Module {
  final int id;
  final String nombre;
  final String? icono;
  final String? ruta;
  final String seccion;
  final int orden;
  final bool activo;

  Module({
    required this.id,
    required this.nombre,
    this.icono,
    this.ruta,
    required this.seccion,
    required this.orden,
    required this.activo,
  });

  factory Module.fromMap(Map<String, dynamic> map) {
    return Module(
      id: map['id'],
      nombre: map['nombre'],
      icono: map['icono'],
      ruta: map['ruta'],
      seccion: map['seccion'],
      orden: map['orden'],
      activo: map['activo'] == 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'icono': icono,
      'ruta': ruta,
      'seccion': seccion,
      'orden': orden,
      'activo': activo ? 1 : 0,
    };
  }
}