import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/models.dart';
import '../../providers/providers.dart';

class CategoriasScreen extends StatefulWidget {
  @override
  _CategoriasScreenState createState() => _CategoriasScreenState();
}

class _CategoriasScreenState extends State<CategoriasScreen> {
  final TextEditingController _searchController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  
  TextEditingController _nombreController = TextEditingController();
  TextEditingController _colorController = TextEditingController();
  int _ordenController = 0;
  bool _activoController = true;
  Categoria? _categoriaEditando;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CategoriaProvider>().loadCategorias();
    });
  }

  void _mostrarDialogoCategoria([Categoria? categoria]) {
    _categoriaEditando = categoria;
    _nombreController.text = categoria?.nombre ?? '';
    _colorController.text = categoria?.color ?? '#2196F3';
    _ordenController = categoria?.orden ?? 0;
    _activoController = categoria?.activo ?? true;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(categoria == null ? '➕ Nueva Categoría' : '✏️ Editar Categoría'),
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
                      return 'Ingrese el nombre de la categoría';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 12),
                TextFormField(
                  controller: _colorController,
                  decoration: InputDecoration(
                    labelText: 'Color (hex, ej: #2196F3)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.color_lens),
                  ),
                ),
                SizedBox(height: 12),
                TextFormField(
                  initialValue: _ordenController.toString(),
                  decoration: InputDecoration(
                    labelText: 'Orden',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    _ordenController = int.tryParse(value) ?? 0;
                  },
                ),
                SizedBox(height: 12),
                SwitchListTile(
                  title: Text('Activa'),
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
                final categoriaProvider = context.read<CategoriaProvider>();
                
                final categoria = Categoria(
                  id: _categoriaEditando?.id,
                  nombre: _nombreController.text,
                  color: _colorController.text,
                  orden: _ordenController,
                  activo: _activoController,
                );
                
                if (_categoriaEditando == null) {
                  await categoriaProvider.addCategoria(categoria);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('✅ Categoría agregada')),
                  );
                } else {
                  await categoriaProvider.updateCategoria(categoria);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('✅ Categoría actualizada')),
                  );
                }
                
                Navigator.of(context).pop();
                _limpiarFormulario();
              }
            },
            child: Text(_categoriaEditando == null ? 'Guardar' : 'Actualizar'),
          ),
        ],
      ),
    );
  }

  void _limpiarFormulario() {
    _nombreController.clear();
    _colorController.text = '#2196F3';
    _ordenController = 0;
    _activoController = true;
    _categoriaEditando = null;
  }

  @override
  Widget build(BuildContext context) {
    final categoriaProvider = context.watch<CategoriaProvider>();
    final categoriasFiltradas = categoriaProvider.categorias
        .where((c) => c.nombre.toLowerCase().contains(_searchController.text.toLowerCase()))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Categorías'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => _mostrarDialogoCategoria(),
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
                labelText: 'Buscar categorías...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: categoriasFiltradas.length,
              itemBuilder: (context, index) {
                final categoria = categoriasFiltradas[index];
                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: categoria.colorAsColor,
                      child: Text(
                        categoria.nombre.substring(0, 1).toUpperCase(),
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    title: Text(categoria.nombre),
                    subtitle: Text('Orden: ${categoria.orden}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _mostrarDialogoCategoria(categoria),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: Text('Eliminar Categoría'),
                                content: Text('¿Eliminar "${categoria.nombre}"? Los productos quedarán sin categoría.'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.of(context).pop(),
                                    child: Text('Cancelar'),
                                  ),
                                  TextButton(
                                    onPressed: () async {
                                      await categoriaProvider.deleteCategoria(categoria.id!);
                                      Navigator.of(context).pop();
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('✅ Categoría eliminada')),
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
              },
            ),
          ),
        ],
      ),
    );
  }
}