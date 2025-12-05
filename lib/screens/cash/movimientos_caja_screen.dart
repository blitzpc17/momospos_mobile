import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../providers/providers.dart';

class MovimientosCajaScreen extends StatefulWidget {
  @override
  _MovimientosCajaScreenState createState() => _MovimientosCajaScreenState();
}

class _MovimientosCajaScreenState extends State<MovimientosCajaScreen> {
  DateTime? _fechaDesde;
  DateTime? _fechaHasta;
  String _filtroTipo = 'todos';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fechaDesde = DateTime.now().subtract(Duration(days: 7));
      _fechaHasta = DateTime.now();
      context.read<CajaProvider>().loadMovimientosCaja(
        desde: _fechaDesde,
        hasta: _fechaHasta,
      );
    });
  }

  void _aplicarFiltros() {
    context.read<CajaProvider>().loadMovimientosCaja(
      desde: _fechaDesde,
      hasta: _fechaHasta,
    );
  }

  void _mostrarDialogoFiltros() {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text('Filtrar Movimientos'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    title: Text('Desde:'),
                    subtitle: Text(_fechaDesde != null 
                        ? DateFormat('dd/MM/yyyy').format(_fechaDesde!)
                        : 'Seleccionar fecha'),
                    trailing: Icon(Icons.calendar_today),
                    onTap: () async {
                      final fecha = await showDatePicker(
                        context: context,
                        initialDate: _fechaDesde ?? DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                      );
                      if (fecha != null) {
                        setState(() => _fechaDesde = fecha);
                      }
                    },
                  ),
                  ListTile(
                    title: Text('Hasta:'),
                    subtitle: Text(_fechaHasta != null 
                        ? DateFormat('dd/MM/yyyy').format(_fechaHasta!)
                        : 'Seleccionar fecha'),
                    trailing: Icon(Icons.calendar_today),
                    onTap: () async {
                      final fecha = await showDatePicker(
                        context: context,
                        initialDate: _fechaHasta ?? DateTime.now(),
                        firstDate: _fechaDesde ?? DateTime(2020),
                        lastDate: DateTime.now(),
                      );
                      if (fecha != null) {
                        setState(() => _fechaHasta = fecha);
                      }
                    },
                  ),
                  SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _filtroTipo,
                    decoration: InputDecoration(
                      labelText: 'Tipo de movimiento',
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      DropdownMenuItem(value: 'todos', child: Text('Todos')),
                      DropdownMenuItem(value: 'venta', child: Text('Ventas')),
                      DropdownMenuItem(value: 'pago_proveedor', child: Text('Pagos a proveedores')),
                      DropdownMenuItem(value: 'deposito', child: Text('Depósitos')),
                      DropdownMenuItem(value: 'retiro', child: Text('Retiros')),
                      DropdownMenuItem(value: 'gasto', child: Text('Gastos')),
                    ],
                    onChanged: (value) {
                      setState(() => _filtroTipo = value!);
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
                onPressed: () {
                  Navigator.of(context).pop();
                  _aplicarFiltros();
                },
                child: Text('Aplicar Filtros'),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cajaProvider = context.watch<CajaProvider>();
    List<MovimientoCaja> movimientosFiltrados = cajaProvider.movimientos;

    if (_filtroTipo != 'todos') {
      movimientosFiltrados = movimientosFiltrados
          .where((m) => m.tipoMovimiento == _filtroTipo)
          .toList();
    }

    // Calcular totales
    double totalIngresos = 0;
    double totalEgresos = 0;
    
    for (var movimiento in movimientosFiltrados) {
      if (movimiento.tipoMovimiento == 'venta' || movimiento.tipoMovimiento == 'deposito') {
        totalIngresos += movimiento.monto;
      } else {
        totalEgresos += movimiento.monto;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Movimientos de Caja'),
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: _mostrarDialogoFiltros,
          ),
        ],
      ),
      body: Column(
        children: [
          // Resumen
          Card(
            margin: EdgeInsets.all(12),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Período:', style: TextStyle(fontWeight: FontWeight.bold)),
                      Text(
                        '${_fechaDesde != null ? DateFormat('dd/MM/yyyy').format(_fechaDesde!) : '...'} - ${_fechaHasta != null ? DateFormat('dd/MM/yyyy').format(_fechaHasta!) : '...'}',
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            Text('INGRESOS', style: TextStyle(color: Colors.green, fontSize: 12)),
                            Text(
                              '\$${totalIngresos.toStringAsFixed(2)}',
                              style: TextStyle(color: Colors.green, fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            Text('EGRESOS', style: TextStyle(color: Colors.red, fontSize: 12)),
                            Text(
                              '\$${totalEgresos.toStringAsFixed(2)}',
                              style: TextStyle(color: Colors.red, fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            Text('SALDO', style: TextStyle(color: Colors.blue, fontSize: 12)),
                            Text(
                              '\$${(totalIngresos - totalEgresos).toStringAsFixed(2)}',
                              style: TextStyle(color: Colors.blue, fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          // Lista de movimientos
          Expanded(
            child: movimientosFiltrados.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.account_balance_wallet, size: 60, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'No hay movimientos',
                          style: TextStyle(color: Colors.grey, fontSize: 16),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: movimientosFiltrados.length,
                    itemBuilder: (context, index) {
                      final movimiento = movimientosFiltrados[index];
                      return Card(
                        margin: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: movimiento.colorTipo.withOpacity(0.1),
                            child: Icon(movimiento.iconoTipo, color: movimiento.colorTipo),
                          ),
                          title: Text(movimiento.concepto),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(movimiento.tipoFormatted),
                              Text(movimiento.fechaMovimientoFormatted),
                              if (movimiento.referencia != null)
                                Text('Ref: ${movimiento.referencia}'),
                            ],
                          ),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                movimiento.montoFormatted,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: movimiento.tipoMovimiento == 'venta' || 
                                         movimiento.tipoMovimiento == 'deposito'
                                      ? Colors.green
                                      : Colors.red,
                                ),
                              ),
                              Text(
                                movimiento.usuarioNombre ?? '',
                                style: TextStyle(fontSize: 12, color: Colors.grey),
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