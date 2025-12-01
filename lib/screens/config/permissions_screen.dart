import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/models.dart';
import '../../providers/module_provider.dart';
import '../../services/database_service.dart';

class PermissionsScreen extends StatefulWidget {
  final Role role;

  const PermissionsScreen({Key? key, required this.role}) : super(key: key);

  @override
  _PermissionsScreenState createState() => _PermissionsScreenState();
}

class _PermissionsScreenState extends State<PermissionsScreen> {
  List<Permission> _permissions = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadPermissions();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ModuleProvider>(context, listen: false).loadModules();
    });
  }

  Future<void> _loadPermissions() async {
    setState(() {
      _isLoading = true;
    });

    try {
      _permissions = await DatabaseService().getPermissionsByRole(widget.role.id);
    } catch (e) {
      print('Error loading permissions: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _updatePermission(Permission permission) async {
    try {
      await DatabaseService().updatePermission(permission);
      await _loadPermissions(); // Recargar la lista
    } catch (e) {
      print('Error updating permission: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final moduleProvider = Provider.of<ModuleProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Permisos - ${widget.role.nombre}'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: _isLoading || moduleProvider.isLoading
          ? Center(child: CircularProgressIndicator())
          : _buildPermissionsList(moduleProvider),
    );
  }

  Widget _buildPermissionsList(ModuleProvider moduleProvider) {
    final sections = ['operaciones', 'catalogos', 'reportes', 'configuracion'];

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: sections.length,
      itemBuilder: (context, sectionIndex) {
        final section = sections[sectionIndex];
        final sectionModules = moduleProvider.getModulesBySection(section);
        
        if (sectionModules.isEmpty) return SizedBox();

        return Card(
          margin: EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getSectionTitle(section),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                SizedBox(height: 12),
                ...sectionModules.map((module) {
                  final permission = _permissions.firstWhere(
                    (p) => p.idModulo == module.id,
                    orElse: () => Permission(
                      id: 0,
                      idRol: widget.role.id,
                      idModulo: module.id,
                      puedeVer: false,
                      puedeCrear: false,
                      puedeEditar: false,
                      puedeEliminar: false,
                    ),
                  );

                  return _buildPermissionItem(module, permission);
                }).toList(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPermissionItem(Module module, Permission permission) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(_getModuleIcon(module.icono), size: 20),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  module.nombre,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              _buildPermissionSwitch(
                'Ver',
                permission.puedeVer,
                (value) => _updatePermission(permission.copyWith(puedeVer: value)),
              ),
              _buildPermissionSwitch(
                'Crear',
                permission.puedeCrear,
                (value) => _updatePermission(permission.copyWith(puedeCrear: value)),
              ),
              _buildPermissionSwitch(
                'Editar',
                permission.puedeEditar,
                (value) => _updatePermission(permission.copyWith(puedeEditar: value)),
              ),
              _buildPermissionSwitch(
                'Eliminar',
                permission.puedeEliminar,
                (value) => _updatePermission(permission.copyWith(puedeEliminar: value)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionSwitch(String label, bool value, Function(bool) onChanged) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: TextStyle(fontSize: 12)),
        Transform.scale(
          scale: 0.8,
          child: Switch(
            value: value,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  String _getSectionTitle(String section) {
    switch (section) {
      case 'operaciones': return 'Operaciones';
      case 'catalogos': return 'Catálogos';
      case 'reportes': return 'Reportes';
      case 'configuracion': return 'Configuración';
      default: return section;
    }
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
      default: return Icons.apps;
    }
  }
}

// Extensión para copiar permisos
extension PermissionCopyWith on Permission {
  Permission copyWith({
    bool? puedeVer,
    bool? puedeCrear,
    bool? puedeEditar,
    bool? puedeEliminar,
  }) {
    return Permission(
      id: id,
      idRol: idRol,
      idModulo: idModulo,
      puedeVer: puedeVer ?? this.puedeVer,
      puedeCrear: puedeCrear ?? this.puedeCrear,
      puedeEditar: puedeEditar ?? this.puedeEditar,
      puedeEliminar: puedeEliminar ?? this.puedeEliminar,
      rolNombre: rolNombre,
      moduloNombre: moduloNombre,
    );
  }
}