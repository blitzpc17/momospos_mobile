import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/models.dart';
import '../../providers/providers.dart';

class UsersScreen extends StatefulWidget {
  @override
  _UsersScreenState createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<UserProvider>(context, listen: false).loadUsers();
      Provider.of<UserProvider>(context, listen: false).loadRoles();
    });
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Gestión de Usuarios'),
        backgroundColor: Theme.of(context).primaryColor,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () => userProvider.loadUsers(),
          ),
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => _showUserForm(context),
          ),
        ],
      ),
      body: userProvider.isLoading
          ? Center(child: CircularProgressIndicator())
          : userProvider.users.isEmpty
              ? Center(
                  child: Text(
                    'No hay usuarios registrados',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: userProvider.users.length,
                  itemBuilder: (context, index) {
                    final user = userProvider.users[index];
                    return _buildUserCard(context, user);
                  },
                ),
    );
  }

  Widget _buildUserCard(BuildContext context, User user) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).primaryColor,
          child: Text(
            user.nombre.substring(0, 1).toUpperCase(),
            style: TextStyle(color: Colors.white),
          ),
        ),
        title: Text(
          user.nombre,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Usuario: ${user.username}'),
            Text('Rol: ${user.rolNombre ?? 'No asignado'}'),
            Text('Estado: ${user.activo ? 'Activo' : 'Inactivo'}'),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.edit, color: Colors.blue),
              onPressed: () => _showUserForm(context, user: user),
            ),
            IconButton(
              icon: Icon(Icons.delete, color: Colors.red),
              onPressed: () => _showDeleteDialog(context, user),
            ),
          ],
        ),
      ),
    );
  }

  void _showUserForm(BuildContext context, {User? user}) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final isEditing = user != null;

    showDialog(
      context: context,
      builder: (context) {
        return UserFormDialog(
          user: user,
          roles: userProvider.roles,
          onSave: (newUser) async {
            if (isEditing) {
              await userProvider.updateUser(newUser);
            } else {
              await userProvider.createUser(newUser);
            }
            Navigator.of(context).pop();
          },
        );
      },
    );
  }

  void _showDeleteDialog(BuildContext context, User user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Eliminar Usuario'),
        content: Text('¿Estás seguro de eliminar a ${user.nombre}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              // Implementar eliminación
              Navigator.of(context).pop();
            },
            child: Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class UserFormDialog extends StatefulWidget {
  final User? user;
  final List<Role> roles;
  final Function(User) onSave;

  const UserFormDialog({
    Key? key,
    this.user,
    required this.roles,
    required this.onSave,
  }) : super(key: key);

  @override
  _UserFormDialogState createState() => _UserFormDialogState();
}

class _UserFormDialogState extends State<UserFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nombreController = TextEditingController();
  int _selectedRolId = 1;
  bool _activo = true;

  @override
  void initState() {
    super.initState();
    if (widget.user != null) {
      _usernameController.text = widget.user!.username;
      _nombreController.text = widget.user!.nombre;
      _selectedRolId = widget.user!.idRol;
      _activo = widget.user!.activo;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.user == null ? 'Nuevo Usuario' : 'Editar Usuario'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nombreController,
                decoration: InputDecoration(labelText: 'Nombre completo'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa el nombre';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _usernameController,
                decoration: InputDecoration(labelText: 'Usuario'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa el usuario';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: 'Contraseña'),
                obscureText: true,
                validator: (value) {
                  if (widget.user == null && (value == null || value.isEmpty)) {
                    return 'Por favor ingresa la contraseña';
                  }
                  return null;
                },
              ),
              DropdownButtonFormField<int>(
                value: _selectedRolId,
                decoration: InputDecoration(labelText: 'Rol'),
                items: widget.roles.map((role) {
                  return DropdownMenuItem(
                    value: role.id,
                    child: Text(role.nombre),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedRolId = value!;
                  });
                },
              ),
              SwitchListTile(
                title: Text('Usuario activo'),
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
          onPressed: _saveUser,
          child: Text('Guardar'),
        ),
      ],
    );
  }

  void _saveUser() {
    if (_formKey.currentState!.validate()) {
      final user = User(
        id: widget.user?.id ?? 0,
        username: _usernameController.text,
        passwordHash: _passwordController.text.isNotEmpty 
            ? _passwordController.text 
            : widget.user?.passwordHash ?? '',
        nombre: _nombreController.text,
        idRol: _selectedRolId,
        activo: _activo,
        fechaCreacion: widget.user?.fechaCreacion ?? DateTime.now(),
      );
      widget.onSave(user);
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _nombreController.dispose();
    super.dispose();
  }
}