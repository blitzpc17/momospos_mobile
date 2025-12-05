import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/models.dart';
import '../../providers/module_provider.dart';

class ModulosScreen extends StatefulWidget {
  @override
  _ModulosScreenState createState() => _ModulosScreenState();
}

class _ModulosScreenState extends State<ModulosScreen> {
  final TextEditingController _searchController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  
  TextEditingController _nombreController = TextEditingController();
  TextEditingController _iconoController = TextEditingController();
  TextEditingController _rutaController = TextEditingController();
  TextEditingController _seccionController = TextEditingController();
  TextEditingController _ordenController = TextEditingController();
  bool _activoController = true;
  Module? _moduloEditando;

  List<String> seccionesDisponibles = [
    'operaciones',
    'catalogos', 
    'reportes',
    'configuracion',
    'administracion',
  ];

  List<String> iconosDisponibles = [
    'dashboard',
    'shopping_cart',
    'account_balance_wallet',
    'inventory_2',
    'people',
    'local_shipping',
    'analytics',
    'shopping_basket',
    'manage_accounts',
    'settings',
    'category',
    'point_of_sale',
    'account_balance',
    'payments',
    'settings_applications',
    'apps',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ModuleProvider>().loadModules();
    });
  }

  void _mostrarDialogoModulo([Module? modulo]) {
    _moduloEditando = modulo;
    _nombreController.text = modulo?.nombre ?? '';
    _iconoController.text = modulo?.icono ?? 'apps';
    _rutaController.text = modulo?.ruta ?? '';
    _seccionController.text = modulo?.seccion ?? 'operaciones';
    _ordenController.text = modulo?.orden.toString() ?? '0';
    _activoController = modulo?.activo ?? true;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(modulo == null ? '➕ Nuevo Módulo' : '✏️ Editar Módulo'),
        content: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nombreController,
                  decoration: InputDecoration(
                    labelText: 'Nombre *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Ingrese el nombre del módulo';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 12),
                
                DropdownButtonFormField<String>(
                  value: _iconoController.text,
                  decoration: InputDecoration(
                    labelText: 'Icono',
                    border: OutlineInputBorder(),
                  ),
                  items: iconosDisponibles.map((icono) {
                    return DropdownMenuItem(
                      value: icono,
                      child: Row(
                        children: [
                          Icon(_getIconFromString(icono)),
                          SizedBox(width: 10),
                          Text(icono),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    _iconoController.text = value!;
                  },
                ),
                SizedBox(height: 12),
                
                TextFormField(
                  controller: _rutaController,
                  decoration: InputDecoration(
                    labelText: 'Ruta (ej: /ventas)',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 12),
                
                DropdownButtonFormField<String>(
                  value: _seccionController.text,
                  decoration: InputDecoration(
                    labelText: 'Sección',
                    border: OutlineInputBorder(),
                  ),
                  items: seccionesDisponibles.map((seccion) {
                    return DropdownMenuItem(
                      value: seccion,
                      child: Text(seccion),
                    );
                  }).toList(),
                  onChanged: (value) {
                    _seccionController.text = value!;
                    // Actualizar orden automáticamente
                    final nextOrder = context.read<ModuleProvider>().getNextOrderForSection(value!);
                    _ordenController.text = nextOrder.toString();
                  },
                ),
                SizedBox(height: 12),
                
                TextFormField(
                  controller: _ordenController,
                  decoration: InputDecoration(
                    labelText: 'Orden',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Ingrese el orden';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 12),
                
                SwitchListTile(
                  title: Text('Activo'),
                  value: _activoController,
                  onChanged: (value) {
                    setState(() => _activoController = value);
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
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                final moduleProvider = context.read<ModuleProvider>();
                
                final modulo = Module(
                  id: (_moduloEditando!=null?_moduloEditando!.id:0),
                  nombre: _nombreController.text,
                  icono: _iconoController.text,
                  ruta: _rutaController.text,
                  seccion: _seccionController.text,
                  orden: int.tryParse(_ordenController.text) ?? 0,
                  activo: _activoController,
                );
                
                if (_moduloEditando == null) {
                  await moduleProvider.addModule(modulo);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('✅ Módulo agregado')),
                  );
                } else {
                  await moduleProvider.updateModule(modulo);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('✅ Módulo actualizado')),
                  );
                }
                
                Navigator.of(context).pop();
                _limpiarFormulario();
              }
            },
            child: Text(_moduloEditando == null ? 'Guardar' : 'Actualizar'),
          ),
        ],
      ),
    );
  }

  void _limpiarFormulario() {
    _nombreController.clear();
    _iconoController.text = 'apps';
    _rutaController.clear();
    _seccionController.text = 'operaciones';
    _ordenController.text = '0';
    _activoController = true;
    _moduloEditando = null;
  }

  IconData _getIconFromString(String iconName) {
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

  @override
  Widget build(BuildContext context) {
    final moduleProvider = context.watch<ModuleProvider>();
    final modulosFiltrados = moduleProvider.modules
        .where((m) => m.nombre.toLowerCase().contains(_searchController.text.toLowerCase()))
        .toList();

    // Agrupar por sección
    final modulosPorSeccion = <String, List<Module>>{};
    for (var modulo in modulosFiltrados) {
      modulosPorSeccion.putIfAbsent(modulo.seccion, () => []);
      modulosPorSeccion[modulo.seccion]!.add(modulo);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Módulos del Sistema'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => _mostrarDialogoModulo(),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Buscar módulos...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),
          Expanded(
            child: ListView(
              children: [
                for (var seccion in modulosPorSeccion.keys)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.fromLTRB(16, 20, 16, 8),
                        child: Text(
                          seccion.toUpperCase(),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                      ...modulosPorSeccion[seccion]!.map((modulo) {
                        return Card(
                          margin: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: modulo.activo ? Colors.green : Colors.grey,
                              child: Icon(
                                _getIconFromString(modulo.icono!.isEmpty?"":modulo.icono!),
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                            title: Text(modulo.nombre),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Ruta: ${modulo.ruta}'),
                                Text('Orden: ${modulo.orden}'),
                                Text(
                                  modulo.activo ? '🟢 Activo' : '🔴 Inactivo',
                                  style: TextStyle(
                                    color: modulo.activo ? Colors.green : Colors.red,
                                  ),
                                ),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.edit, color: Colors.blue),
                                  onPressed: () => _mostrarDialogoModulo(modulo),
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete, color: Colors.red),
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: Text('Eliminar Módulo'),
                                        content: Text('¿Eliminar módulo "${modulo.nombre}"?\n\nEsto afectará los permisos asignados.'),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.of(context).pop(),
                                            child: Text('Cancelar'),
                                          ),
                                          TextButton(
                                            onPressed: () async {
                                              await moduleProvider.deleteModule(modulo.id!);
                                              Navigator.of(context).pop();
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(content: Text('✅ Módulo eliminado')),
                                              );
                                            },
                                            child: Text('Eliminar', style: TextStyle(color: Colors.red)),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}