import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/models.dart';
import '../../providers/variable_global_provider.dart';

class VariablesGlobalesScreen extends StatefulWidget {
  @override
  _VariablesGlobalesScreenState createState() => _VariablesGlobalesScreenState();
}

class _VariablesGlobalesScreenState extends State<VariablesGlobalesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<VariableGlobalProvider>().loadVariables();
    });
  }

  void _mostrarDialogoEditarVariable(VariableGlobal variable) {
    final valorController = TextEditingController(text: variable.valor ?? '');
    final descripcionController = TextEditingController(text: variable.descripcion ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Editar "${variable.nombre}"'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(variable.descripcion ?? ''),
              SizedBox(height: 16),
              TextField(
                controller: valorController,
                decoration: InputDecoration(
                  labelText: 'Valor',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 12),
              TextField(
                controller: descripcionController,
                decoration: InputDecoration(
                  labelText: 'Descripción',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
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
              final variableActualizada = VariableGlobal(
                id: variable.id,
                nombre: variable.nombre,
                valor: valorController.text,
                descripcion: descripcionController.text,
                fechaActualizacion: DateTime.now(),
              );
              
              await context.read<VariableGlobalProvider>().updateVariable(variableActualizada);
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('✅ Variable actualizada')),
              );
            },
            child: Text('Guardar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final variableProvider = context.watch<VariableGlobalProvider>();
    final variables = variableProvider.variables;

    return Scaffold(
      appBar: AppBar(
        title: Text('Configuración General'),
      ),
      body: ListView.builder(
        itemCount: variables.length,
        itemBuilder: (context, index) {
          final variable = variables[index];
          return Card(
            margin: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: ListTile(
              title: Text(variable.nombre),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(variable.valor ?? '(sin valor)'),
                  if (variable.descripcion != null)
                    Text(
                      variable.descripcion!,
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  Text(
                    'Actualizado: ${variable.fechaActualizacionFormatted}',
                    style: TextStyle(fontSize: 10, color: Colors.grey),
                  ),
                ],
              ),
              trailing: IconButton(
                icon: Icon(Icons.edit, color: Colors.blue),
                onPressed: () => _mostrarDialogoEditarVariable(variable),
              ),
            ),
          );
        },
      ),
    );
  }
}