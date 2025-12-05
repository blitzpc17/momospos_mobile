import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/models.dart';
import '../../providers/providers.dart';

class ClientesScreen extends StatefulWidget {
  @override
  _ClientesScreenState createState() => _ClientesScreenState();
}

class _ClientesScreenState extends State<ClientesScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ClienteProvider>().loadClientes();
    });
  }

  void _mostrarDialogoCliente([Cliente? cliente]) {
    final nombreController = TextEditingController(text: cliente?.nombre ?? '');
    final telefonoController = TextEditingController(text: cliente?.telefono ?? '');
    final emailController = TextEditingController(text: cliente?.email ?? '');
    final direccionController = TextEditingController(text: cliente?.direccion ?? '');
    final notasController = TextEditingController(text: cliente?.notas ?? '');
    bool frecuenteController = cliente?.frecuente ?? false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text(cliente == null ? '➕ Nuevo Cliente' : '✏️ Editar Cliente'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nombreController,
                    decoration: InputDecoration(
                      labelText: 'Nombre completo *',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 12),
                  TextField(
                    controller: telefonoController,
                    decoration: InputDecoration(
                      labelText: 'Teléfono',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                  SizedBox(height: 12),
                  TextField(
                    controller: emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  SizedBox(height: 12),
                  TextField(
                    controller: direccionController,
                    decoration: InputDecoration(
                      labelText: 'Dirección',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 2,
                  ),
                  SizedBox(height: 12),
                  TextField(
                    controller: notasController,
                    decoration: InputDecoration(
                      labelText: 'Notas',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  SizedBox(height: 12),
                  SwitchListTile(
                    title: Text('Cliente frecuente'),
                    value: frecuenteController,
                    onChanged: (value) {
                      setState(() => frecuenteController = value);
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (nombreController.text.isNotEmpty) {
                    final clienteNuevo = Cliente(
                      id: cliente?.id,
                      nombre: nombreController.text,
                      telefono: telefonoController.text.isNotEmpty ? telefonoController.text : null,
                      email: emailController.text.isNotEmpty ? emailController.text : null,
                      direccion: direccionController.text.isNotEmpty ? direccionController.text : null,
                      frecuente: frecuenteController,
                      notas: notasController.text.isNotEmpty ? notasController.text : null,
                      fechaRegistro: cliente?.fechaRegistro ?? DateTime.now(),
                    );
                    
                    final clienteProvider = context.read<ClienteProvider>();
                    if (cliente == null) {
                      await clienteProvider.addCliente(clienteNuevo);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('✅ Cliente agregado')),
                      );
                    } else {
                      await clienteProvider.updateCliente(clienteNuevo);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('✅ Cliente actualizado')),
                      );
                    }
                    
                    Navigator.of(context).pop();
                  }
                },
                child: Text(cliente == null ? 'Guardar' : 'Actualizar'),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final clienteProvider = context.watch<ClienteProvider>();
    final clientesFiltrados = clienteProvider.searchClientes(_searchController.text);

    return Scaffold(
      appBar: AppBar(
        title: Text('Clientes'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => _mostrarDialogoCliente(),
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
                labelText: 'Buscar clientes...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: clientesFiltrados.length,
              itemBuilder: (context, index) {
                final cliente = clientesFiltrados[index];
                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: cliente.frecuente ? Colors.green : Colors.blue,
                      child: Icon(
                        cliente.frecuente ? Icons.star : Icons.person,
                        color: Colors.white,
                      ),
                    ),
                    title: Text(cliente.nombre),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (cliente.telefono != null) Text('📞 ${cliente.telefono!}'),
                        if (cliente.email != null) Text('📧 ${cliente.email!}'),
                        Text('Registro: ${cliente.fechaRegistro}'),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _mostrarDialogoCliente(cliente),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: Text('Eliminar Cliente'),
                                content: Text('¿Eliminar cliente "${cliente.nombre}"?'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.of(context).pop(),
                                    child: Text('Cancelar'),
                                  ),
                                  TextButton(
                                    onPressed: () async {
                                      await clienteProvider.deleteCliente(cliente.id!);
                                      Navigator.of(context).pop();
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('✅ Cliente eliminado')),
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