class Permission {
  final int id;
  final int idRol;
  final int idModulo;
  final bool puedeVer;
  final bool puedeCrear;
  final bool puedeEditar;
  final bool puedeEliminar;
  final String? rolNombre;
  final String? moduloNombre;

  Permission({
    required this.id,
    required this.idRol,
    required this.idModulo,
    required this.puedeVer,
    required this.puedeCrear,
    required this.puedeEditar,
    required this.puedeEliminar,
    this.rolNombre,
    this.moduloNombre,
  });

  factory Permission.fromMap(Map<String, dynamic> map) {
    return Permission(
      id: map['id'],
      idRol: map['id_rol'],
      idModulo: map['id_modulo'],
      puedeVer: map['puede_ver'] == 1,
      puedeCrear: map['puede_crear'] == 1,
      puedeEditar: map['puede_editar'] == 1,
      puedeEliminar: map['puede_eliminar'] == 1,
      rolNombre: map['rol_nombre'],
      moduloNombre: map['modulo_nombre'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'id_rol': idRol,
      'id_modulo': idModulo,
      'puede_ver': puedeVer ? 1 : 0,
      'puede_crear': puedeCrear ? 1 : 0,
      'puede_editar': puedeEditar ? 1 : 0,
      'puede_eliminar': puedeEliminar ? 1 : 0,
    };
  }
}