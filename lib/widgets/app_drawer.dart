import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/providers.dart';
import '../routes/routes.dart';

class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final moduleProvider = Provider.of<ModuleProvider>(context);
    final currentUser = authProvider.currentUser;

    return Drawer(
      child: Column(
        children: [
          // Header del Drawer
          _buildDrawerHeader(context, currentUser),
          
          // Lista de módulos
          Expanded(
            child: _buildModuleList(context, moduleProvider, currentUser),
          ),
          
          // Footer del Drawer
          _buildDrawerFooter(context, authProvider),
        ],
      ),
    );
  }

  Widget _buildDrawerHeader(BuildContext context, User? currentUser) {
    return UserAccountsDrawerHeader(
      accountName: Text(
        currentUser?.nombre ?? 'Usuario',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      accountEmail: Text(
        currentUser?.rolNombre ?? 'Rol no asignado',
        style: TextStyle(fontSize: 12),
      ),
      currentAccountPicture: CircleAvatar(
        backgroundColor: Colors.white,
        child: Icon(
          Icons.person,
          color: Theme.of(context).primaryColor,
          size: 40,
        ),
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
      ),
    );
  }

  Widget _buildModuleList(BuildContext context, ModuleProvider moduleProvider, User? currentUser) {
    // Si no hay módulos cargados, mostrar loading
    if (moduleProvider.modules.isEmpty) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        // Sección: Operaciones
        _buildSectionHeader('Operaciones'),
        ..._buildModuleItems(
          context,
          moduleProvider.getModulesBySection('operaciones'),
          currentUser,
        ),

        // Sección: Catálogos
        _buildSectionHeader('Catálogos'),
        ..._buildModuleItems(
          context,
          moduleProvider.getModulesBySection('catalogos'),
          currentUser,
        ),      
       

        // Sección: Reportes
        _buildSectionHeader('Reportes'),
        ..._buildModuleItems(
          context,
          moduleProvider.getModulesBySection('reportes'),
          currentUser,
        ),      
       

        // Sección: Configuración (Solo para administradores)
        if (currentUser?.idRol == 1) ...[
          _buildSectionHeader('Administración'),
          ..._buildModuleItems(
            context,
            moduleProvider.getModulesBySection('configuracion'),
            currentUser,
          ),     
         
         
        ] else if (currentUser?.idRol == 2) ...[
          // Supervisor puede ver algunos módulos de configuración
          _buildSectionHeader('Configuración'),
          ..._buildModuleItems(
            context,
            moduleProvider.getModulesBySection('configuracion').where((module) => 
              module.nombre != 'Usuarios' && module.nombre != 'Roles y Permisos'
            ).toList(),
            currentUser,
          ),
          
          // Supervisor puede ver configuración general
          _buildCustomModuleItem(
            context,
            Icons.settings,
            'Configuración General',
            Routes.configuracion,
            currentUser,
            requiredPermission: 'configuracion.ver',
          ),
        ],
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.grey[600],
        ),
      ),
    );
  }

  List<Widget> _buildModuleItems(BuildContext context, List<Module> modules, User? currentUser) {
    return modules.map((module) {
      return _buildModuleItem(
        context,
        _getModuleIcon(module.icono),
        module.nombre,
        module.ruta ?? '/',
        currentUser,
        module: module,
      );
    }).toList();
  }

  Widget _buildModuleItem(
    BuildContext context, 
    IconData icon, 
    String title, 
    String route, 
    User? currentUser,
    {Module? module}
  ) {
    // Verificar permisos si el módulo tiene información de permisos
    if (module != null && currentUser != null) {
      final tienePermiso = _verificarPermisoModule(module, currentUser);
      if (!tienePermiso) return SizedBox.shrink();
    }
    
    return ListTile(
      leading: Icon(
        icon,
        color: Theme.of(context).primaryColor,
      ),
      title: Text(title),
      onTap: () {
        Navigator.pop(context); // Cerrar el drawer
        Navigator.pushNamed(context, route);
      },
    );
  }

  Widget _buildCustomModuleItem(
    BuildContext context,
    IconData icon,
    String title,
    String route,
    User? currentUser,
    {String? requiredPermission}
  ) {
    // Verificar permisos basados en rol o permiso específico
    if (currentUser != null) {
      // Si es cajero (idRol == 3), solo puede ver ventas y productos básicos
      if (currentUser.idRol == 3) {
        final modulosPermitidosCajero = [
          Routes.ventas,
          Routes.productos,
          Routes.clientes,
        ];
        if (!modulosPermitidosCajero.contains(route)) {
          return SizedBox.shrink();
        }
      }
      
      // Si se requiere un permiso específico
      if (requiredPermission != null) {
        final tienePermiso = _verificarPermiso(requiredPermission, currentUser);
        if (!tienePermiso) return SizedBox.shrink();
      }
    }
    
    return ListTile(
      leading: Icon(
        icon,
        color: Theme.of(context).primaryColor,
      ),
      title: Text(title),
      onTap: () {
        Navigator.pop(context); // Cerrar el drawer
        Navigator.pushNamed(context, route);
      },
    );
  }

  bool _verificarPermiso(String permiso, User user) {
    // Lógica básica de permisos según rol
    switch (user.idRol) {
      case 1: // Administrador
        return true;
      case 2: // Supervisor
        return ![
          'usuarios.administrar',
          'roles.administrar',
          'proveedores.pagar',
        ].contains(permiso);
      case 3: // Cajero
        return [
          'ventas.acceder',
          'productos.ver',
          'clientes.ver',
        ].contains(permiso);
      default:
        return false;
    }
  }

  bool _verificarPermisoModule(Module module, User user) {
    // Verificar permisos específicos del módulo
    switch (module.nombre) {
      case 'Usuarios':
        return user.idRol == 1; // Solo admin
      case 'Roles y Permisos':
        return user.idRol == 1; // Solo admin
      case 'Pagos a Proveedores':
        return user.idRol <= 2; // Admin y supervisor
      case 'Movimientos de Caja':
        return user.idRol <= 2; // Admin y supervisor
      default:
        return true;
    }
  }

  Widget _buildDrawerFooter(BuildContext context, AuthProvider authProvider) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Column(
        children: [
          // Información de la versión o tienda
          ListTile(
            leading: Icon(Icons.store, color: Colors.grey[600]),
            title: Text(
              "MOMO'S POS",
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            subtitle: Text(
              'Sistema Punto de Venta',
              style: TextStyle(fontSize: 10, color: Colors.grey[500]),
            ),
          ),
          
          // Información del usuario actual
          Consumer<AuthProvider>(
            builder: (context, auth, child) {
              final user = auth.currentUser;
              return ListTile(
                leading: Icon(Icons.person_outline, color: Colors.grey[600]),
                title: Text(
                  user?.username ?? '',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                subtitle: Text(
                  'Rol: ${user?.rolNombre ?? ''}',
                  style: TextStyle(fontSize: 10, color: Colors.grey[500]),
                ),
              );
            },
          ),
          
          // Botón de cerrar sesión
          Container(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: Icon(Icons.logout, size: 16),
              label: Text('Cerrar Sesión'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                _showLogoutDialog(context, authProvider);
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Cerrar Sesión'),
        content: Text('¿Estás seguro de que quieres cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              authProvider.logout();
              Navigator.of(context).popUntil((route) => route.isFirst);
              Navigator.pushReplacementNamed(context, Routes.login);
            },
            child: Text(
              'Cerrar Sesión',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getModuleIcon(String? iconName) {
    switch (iconName) {
      case 'dashboard': return Icons.dashboard;
      case 'shopping_cart': return Icons.shopping_cart;
      case 'account_balance_wallet': return Icons.account_balance_wallet;
      case 'inventory_2': return Icons.inventory_2;
      case 'people': return Icons.people;
      case 'local_shipping': return Icons.local_shipping;
      case 'analytics': return Icons.analytics;
      case 'shopping_basket': return Icons.shopping_basket;
      case 'manage_accounts': return Icons.manage_accounts;
      case 'settings': return Icons.settings;
      case 'category': return Icons.category;
      case 'point_of_sale': return Icons.point_of_sale;
      case 'account_balance': return Icons.account_balance;
      case 'payments': return Icons.payments;
      case 'settings_applications': return Icons.settings_applications;
      default: return Icons.apps;
    }
  }
}