import 'package:flutter/material.dart';
import '../screens/screens.dart';

class Routes {
  static const String login = '/login';
  static const String dashboard = '/dashboard';
  static const String ventas = '/ventas';
  static const String productos = '/productos';
  static const String clientes = '/clientes';
  static const String proveedores = '/proveedores';
  static const String caja = '/caja';
  static const String compras = '/compras';
  static const String reportes = '/reportes';
  static const String configuracion = '/configuracion';
  static const String usuarios = '/usuarios';
  static const String roles = '/roles';
  
  static Map<String, WidgetBuilder> getRoutes() {
    return {
      login: (context) => LoginScreen(),
      dashboard: (context) => DashboardScreen(),
      ventas: (context) => VentasScreen(),
      productos: (context) => ProductosScreen(),
      clientes: (context) => ClientesScreen(),
      proveedores: (context) => ProveedoresScreen(),
      caja: (context) => CajaScreen(),
      compras: (context) => ComprasScreen(),
      reportes: (context) => ReportesScreen(),
      configuracion: (context) => ConfiguracionScreen(),
      usuarios: (context) => UsersScreen(),
      roles: (context) => RolesScreen(),
    };
  }
}