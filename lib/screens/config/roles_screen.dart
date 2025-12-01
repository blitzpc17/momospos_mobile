import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../providers/providers.dart';

import 'package:provider/provider.dart';

import '../screens.dart';

class RolesScreen extends StatefulWidget {
  @override
  _RolesScreenState createState() => _RolesScreenState();
}

class _RolesScreenState extends State<RolesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<RoleProvider>(context, listen: false).loadRoles();
    });
  }

  @override
  Widget build(BuildContext context) {
    final roleProvider = Provider.of<RoleProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Gestión de Roles'),
        backgroundColor: Theme.of(context).primaryColor,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () => roleProvider.loadRoles(),
          ),
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => _showRoleForm(context),
          ),
        ],
      ),
      body: roleProvider.isLoading
          ? Center(child: CircularProgressIndicator())
          : roleProvider.roles.isEmpty
              ? Center(
                  child: Text(
                    'No hay roles registrados',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: roleProvider.roles.length,
                  itemBuilder: (context, index) {
                    final role = roleProvider.roles[index];
                    return _buildRoleCard(context, role);
                  },
                ),
    );
  }

  Widget _buildRoleCard(BuildContext context, Role role) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getRoleColor(role.nivelAcceso),
          child: Text(
            role.nombre.substring(0, 1).toUpperCase(),
            style: TextStyle(color: Colors.white),
          ),
        ),
        title: Text(
          role.nombre,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(role.descripcion),
            Text('Nivel: ${role.nivelAcceso} - ${_getNivelText(role.nivelAcceso)}'),
            Text('Estado: ${role.activo ? 'Activo' : 'Inactivo'}'),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.edit, color: Colors.blue),
              onPressed: () => _showRoleForm(context, role: role),
            ),
            IconButton(
              icon: Icon(Icons.manage_accounts, color: Colors.green),
              onPressed: () => _navigateToPermissions(context, role),
            ),
            IconButton(
              icon: Icon(Icons.delete, color: Colors.red),
              onPressed: () => _showDeleteDialog(context, role),
            ),
          ],
        ),
      ),
    );
  }

  Color _getRoleColor(int nivelAcceso) {
    switch (nivelAcceso) {
      case 3: return Colors.red;
      case 2: return Colors.orange;
      case 1: return Colors.blue;
      default: return Colors.grey;
    }
  }

  String _getNivelText(int nivelAcceso) {
    switch (nivelAcceso) {
      case 3: return 'Administrador';
      case 2: return 'Supervisor';
      case 1: return 'Cajero';
      default: return 'Básico';
    }
  }

  void _showRoleForm(BuildContext context, {Role? role}) {
    final roleProvider = Provider.of<RoleProvider>(context, listen: false);
    final isEditing = role != null;

    showDialog(
      context: context,
      builder: (context) {
        return RoleFormDialog(
          role: role,
          onSave: (newRole) async {
            if (isEditing) {
              await roleProvider.updateRole(newRole);
            } else {
              await roleProvider.createRole(newRole);
            }
            Navigator.of(context).pop();
          },
        );
      },
    );
  }

  void _navigateToPermissions(BuildContext context, Role role) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PermissionsScreen(role: role),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, Role role) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Eliminar Rol'),
        content: Text('¿Estás seguro de eliminar el rol "${role.nombre}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              await Provider.of<RoleProvider>(context, listen: false).deleteRole(role.id);
              Navigator.of(context).pop();
            },
            child: Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class RoleFormDialog extends StatefulWidget {
  final Role? role;
  final Function(Role) onSave;

  const RoleFormDialog({Key? key, this.role, required this.onSave}) : super(key: key);

  @override
  _RoleFormDialogState createState() => _RoleFormDialogState();
}

class _RoleFormDialogState extends State<RoleFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _descripcionController = TextEditingController();
  int _selectedNivel = 1;
  bool _activo = true;

  @override
  void initState() {
    super.initState();
    if (widget.role != null) {
      _nombreController.text = widget.role!.nombre;
      _descripcionController.text = widget.role!.descripcion;
      _selectedNivel = widget.role!.nivelAcceso;
      _activo = widget.role!.activo;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.role == null ? 'Nuevo Rol' : 'Editar Rol'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nombreController,
                decoration: InputDecoration(labelText: 'Nombre del rol'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa el nombre del rol';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _descripcionController,
                decoration: InputDecoration(labelText: 'Descripción'),
                maxLines: 3,
              ),
              DropdownButtonFormField<int>(
                value: _selectedNivel,
                decoration: InputDecoration(labelText: 'Nivel de acceso'),
                items: [
                  DropdownMenuItem(value: 1, child: Text('1 - Cajero (Básico)')),
                  DropdownMenuItem(value: 2, child: Text('2 - Supervisor (Intermedio)')),
                  DropdownMenuItem(value: 3, child: Text('3 - Administrador (Completo)')),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedNivel = value!;
                  });
                },
              ),
              SwitchListTile(
                title: Text('Rol activo'),
                value: _activo,
                onChanged: (value) {
                  setState(() {
                    _activo = value;
                  });
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _saveRole,
          child: Text('Guardar'),
        ),
      ],
    );
  }

  void _saveRole() {
    if (_formKey.currentState!.validate()) {
      final role = Role(
        id: widget.role?.id ?? 0,
        nombre: _nombreController.text,
        descripcion: _descripcionController.text,
        nivelAcceso: _selectedNivel,
        activo: _activo,
        fechaCreacion: widget.role?.fechaCreacion ?? DateTime.now(),
      );
      widget.onSave(role);
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }
}