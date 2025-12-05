import 'package:flutter/material.dart';
import 'package:momospos_mobile/screens/config/modulos_creen.dart';
import 'package:momospos_mobile/screens/products/categorias_screen.dart';
import '../screens/screens.dart';

class Routes {
  static const String login = '/login';
  static const String dashboard = '/dashboard';
  static const String ventas = '/ventas';
  static const String productos = '/productos';
  static const String categorias = '/categorias';
  static const String clientes = '/clientes';
  static const String proveedores = '/proveedores';
  static const String caja = '/caja';
  static const String movimientosCaja = '/movimientos_caja';
  static const String compras = '/compras';
  static const String reportes = '/reportes';
  static const String configuracion = '/configuracion';
  static const String usuarios = '/usuarios';
  static const String roles = '/roles';
  static const String modulos = '/modulos';
  
  static Map<String, WidgetBuilder> getRoutes() {
    return {
      login: (context) => LoginScreen(),
      dashboard: (context) => DashboardScreen(),
      ventas: (context) => VentaScreen(),
      productos: (context) => ProductosScreen(),
      categorias: (context) => CategoriasScreen(),
      clientes: (context) => ClientesScreen(),
      proveedores: (context) => ProveedoresScreen(),
      caja: (context) => CajaScreen(),
      compras: (context) => ComprasScreen(),
      reportes: (context) => ReportesScreen(),
      configuracion: (context) => ConfiguracionScreen(),
      usuarios: (context) => UsersScreen(),
      roles: (context) => RolesScreen(),
      modulos: (context) => ModulosScreen()
    };
  }
}