import 'package:intl/intl.dart';

class Proveedor {
  int? id;
  String nombre;
  String? contacto;
  String? telefono;
  String? email;
  String? direccion;
  String? rfc;
  bool activo;
  DateTime fechaRegistro;

  Proveedor({
    this.id,
    required this.nombre,
    this.contacto,
    this.telefono,
    this.email,
    this.direccion,
    this.rfc,
    this.activo = true,
    required this.fechaRegistro,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'contacto': contacto,
      'telefono': telefono,
      'email': email,
      'direccion': direccion,
      'rfc': rfc,
      'activo': activo ? 1 : 0,
      'fecha_registro': fechaRegistro.toIso8601String(),
    };
  }

  factory Proveedor.fromMap(Map<String, dynamic> map) {
    return Proveedor(
      id: map['id'],
      nombre: map['nombre'],
      contacto: map['contacto'],
      telefono: map['telefono'],
      email: map['email'],
      direccion: map['direccion'],
      rfc: map['rfc'],
      activo: map['activo'] == 1,
      fechaRegistro: DateTime.parse(map['fecha_registro']),
    );
  }

  String get fechaRegistroFormatted {
    return DateFormat('dd/MM/yyyy').format(fechaRegistro);
  }

  String get infoContacto {
    List<String> info = [];
    if (contacto != null && contacto!.isNotEmpty) info.add('👤 $contacto');
    if (telefono != null && telefono!.isNotEmpty) info.add('📞 $telefono');
    if (email != null && email!.isNotEmpty) info.add('📧 $email');
    return info.join(' • ');
  }
}

class PagoProveedor {
  int? id;
  int idProveedor;
  int idCaja;
  int idUsuario;
  String concepto;
  String? descripcion;
  double monto;
  String metodoPago;
  String? referencia;
  DateTime fechaPago;
  String estado;

  // Propiedades relacionadas
  String? proveedorNombre;
  String? usuarioNombre;
  String? cajaFolio;

  PagoProveedor({
    this.id,
    required this.idProveedor,
    required this.idCaja,
    required this.idUsuario,
    required this.concepto,
    this.descripcion,
    required this.monto,
    required this.metodoPago,
    this.referencia,
    required this.fechaPago,
    this.estado = 'completado',
    this.proveedorNombre,
    this.usuarioNombre,
    this.cajaFolio,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'id_proveedor': idProveedor,
      'id_caja': idCaja,
      'id_usuario': idUsuario,
      'concepto': concepto,
      'descripcion': descripcion,
      'monto': monto,
      'metodo_pago': metodoPago,
      'referencia': referencia,
      'fecha_pago': fechaPago.toIso8601String(),
      'estado': estado,
    };
  }

  factory PagoProveedor.fromMap(Map<String, dynamic> map) {
    return PagoProveedor(
      id: map['id'],
      idProveedor: map['id_proveedor'],
      idCaja: map['id_caja'],
      idUsuario: map['id_usuario'],
      concepto: map['concepto'],
      descripcion: map['descripcion'],
      monto: map['monto']?.toDouble() ?? 0.0,
      metodoPago: map['metodo_pago'] ?? 'efectivo',
      referencia: map['referencia'],
      fechaPago: DateTime.parse(map['fecha_pago']),
      estado: map['estado'] ?? 'completado',
      proveedorNombre: map['proveedor_nombre'],
      usuarioNombre: map['usuario_nombre'],
      cajaFolio: map['caja_folio'],
    );
  }

  String get montoFormatted => '\$${monto.toStringAsFixed(2)}';
  String get fechaPagoFormatted => DateFormat('dd/MM/yyyy HH:mm').format(fechaPago);
}