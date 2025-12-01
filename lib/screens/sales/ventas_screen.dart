import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart'; // Para HapticFeedback
import '../../models/models.dart';
import '../../providers/providers.dart';

class VentaScreen extends StatefulWidget {
  @override
  _VentaScreenState createState() => _VentaScreenState();
}

class _VentaScreenState extends State<VentaScreen> {
  final TextEditingController _codigoController = TextEditingController();
  final TextEditingController _busquedaController = TextEditingController();
  final TextEditingController _cantidadController = TextEditingController(text: '1');
  final TextEditingController _descuentoController = TextEditingController(text: '0');
  final TextEditingController _observacionesController = TextEditingController();
  
  FocusNode _codigoFocus = FocusNode();
  FocusNode _busquedaFocus = FocusNode();
  bool _mostrarPanelVenta = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().loadProductos();
      context.read<SaleProvider>().loadCajaActiva();
      context.read<SaleProvider>().loadClientes();
      _codigoFocus.requestFocus();
    });
  }

  @override
  void dispose() {
    _codigoFocus.dispose();
    _busquedaFocus.dispose();
    super.dispose();
  }

  void _agregarPorCodigo() {
    if (_codigoController.text.isNotEmpty) {
      final producto = context.read<ProductProvider>().getProductoByCodigo(_codigoController.text);
      if (producto != null) {
        if (producto.stock <= 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Producto sin stock disponible')),
          );
          return;
        }
        
        final cantidad = double.tryParse(_cantidadController.text) ?? 1;
        if (cantidad > producto.stock) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Stock insuficiente. Disponible: ${producto.stock.toStringAsFixed(2)}')),
          );
          return;
        }
        
        context.read<SaleProvider>().agregarProductoAlCarrito(producto, cantidad);
        _codigoController.clear();
        _cantidadController.text = '1';
        _codigoFocus.requestFocus();
        
        // Feedback táctil en móvil
        if (MediaQuery.of(context).size.width < 600) {
          HapticFeedback.lightImpact();
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('✅ ${producto.nombre} agregado')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Producto no encontrado')),
        );
      }
    }
  }

  void _procesarVenta() async {
    final saleProvider = context.read<SaleProvider>();
    final authProvider = context.read<AuthProvider>();
    
    if (saleProvider.carrito.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('🛒 Agregue productos a la venta')),
      );
      return;
    }

    if (saleProvider.cajaActiva == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('💰 Debe abrir una caja primero')),
      );
      return;
    }

    // Validar stock antes de proceder
    for (var item in saleProvider.carrito) {
      final producto = context.read<ProductProvider>().getProductoByCodigo(item.productoCodigo ?? '');
      if (producto == null || producto.stock < item.cantidad) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('⚠️ Stock insuficiente para ${item.productoNombre}')),
        );
        return;
      }
    }

    try {
      saleProvider.setObservaciones(_observacionesController.text);
      saleProvider.setDescuentoGlobal(double.tryParse(_descuentoController.text) ?? 0);

      final venta = await saleProvider.procesarVenta(authProvider.currentUser!.id!);
      _mostrarResumenVenta(venta);

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Error: $e')),
      );
    }
  }

  void _mostrarResumenVenta(Venta venta) {
    final saleProvider = context.read<SaleProvider>();
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 10),
            Text('Venta Completada'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoRow('📋 Folio:', venta.folio ?? 'N/A'),
              _buildInfoRow('💰 Total:', '\$${venta.total.toStringAsFixed(2)}'),
              _buildInfoRow('💳 Método:', venta.metodoPago),
              _buildInfoRow('👤 Cliente:', venta.clienteNombre ?? 'Cliente general'),
              _buildInfoRow('🕐 Fecha:', DateFormat('dd/MM/yy HH:mm').format(venta.fechaVenta)),
              SizedBox(height: 20),
              Divider(),
              SizedBox(height: 10),
              Text('Productos vendidos:', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              ...saleProvider.carrito.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child: Text('• ${item.productoNombre} x${item.cantidad.toStringAsFixed(2)} = \$${item.total.toStringAsFixed(2)}'),
              )).toList(),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _limpiarTodo();
            },
            child: Text('Nueva Venta'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('🎫 Ticket impreso (simulación)')),
              );
              _limpiarTodo();
            },
            icon: Icon(Icons.print),
            label: Text('Imprimir Ticket'),
          ),
        ],
      ),
    );
  }

  void _abrirCajaDialog() {
    final montoController = TextEditingController();
    final observacionesController = TextEditingController();
    final authProvider = context.read<AuthProvider>();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text('💰 Abrir Caja'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: montoController,
                  decoration: InputDecoration(
                    labelText: 'Monto Inicial',
                    prefixText: '\$',
                    border: OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(Icons.attach_money),
                      onPressed: () {
                        final current = double.tryParse(montoController.text) ?? 0;
                        montoController.text = (current + 100).toStringAsFixed(2);
                      },
                    ),
                  ),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                ),
                SizedBox(height: 12),
                TextField(
                  controller: observacionesController,
                  decoration: InputDecoration(
                    labelText: 'Observaciones (opcional)',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
                SizedBox(height: 16),
                Text('Usuario: ${authProvider.currentUser?.nombre ?? ''}', 
                    style: TextStyle(color: Colors.grey)),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () async {
                  final monto = double.tryParse(montoController.text) ?? 0;
                  if (monto > 0) {
                    final success = await context.read<SaleProvider>().abrirCaja(
                      monto,
                      observacionesController.text,
                      authProvider.currentUser!.id!,
                    );
                    
                    if (success && mounted) {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('✅ Caja abierta exitosamente')),
                      );
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('❌ Ingrese un monto válido')),
                    );
                  }
                },
                child: Text('Abrir Caja'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _cerrarCajaDialog() {
    final saleProvider = context.read<SaleProvider>();
    final observacionesController = TextEditingController();
    final montoController = TextEditingController(
      text: saleProvider.cajaActiva?.montoFinal?.toStringAsFixed(2) ?? ''
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('🔒 Cerrar Caja'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Caja actual:', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('Monto inicial: \$${saleProvider.cajaActiva!.montoInicial.toStringAsFixed(2)}'),
            SizedBox(height: 12),
            TextField(
              controller: montoController,
              decoration: InputDecoration(
                labelText: 'Monto Final en Caja',
                prefixText: '\$',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
            ),
            SizedBox(height: 12),
            TextField(
              controller: observacionesController,
              decoration: InputDecoration(
                labelText: 'Observaciones',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              final montoFinal = double.tryParse(montoController.text);
              if (montoFinal != null && montoFinal > 0) {
                final success = await saleProvider.cerrarCaja(
                  montoFinal,
                  observacionesController.text,
                );
                
                if (success && mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('✅ Caja cerrada exitosamente')),
                  );
                }
              }
            },
            child: Text('Cerrar Caja'),
          ),
        ],
      ),
    );
  }

  void _seleccionarCliente() {
    final saleProvider = context.read<SaleProvider>();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('👥 Seleccionar Cliente'),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: Column(
            children: [
              TextField(
                decoration: InputDecoration(
                  labelText: 'Buscar cliente...',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  // Implementar búsqueda de clientes
                },
              ),
              SizedBox(height: 10),
              Expanded(
                child: ListView.builder(
                  itemCount: saleProvider.clientes.length + 1,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return ListTile(
                        leading: Icon(Icons.person_add),
                        title: Text('Cliente nuevo'),
                        subtitle: Text('Registrar nuevo cliente'),
                        onTap: () {
                          Navigator.of(context).pop();
                          _crearClienteDialog();
                        },
                      );
                    }
                    
                    final cliente = saleProvider.clientes[index - 1];
                    return ListTile(
                      leading: Icon(Icons.person,
                          color: cliente.frecuente ? Colors.green : Colors.grey),
                      title: Text(cliente.nombre),
                      subtitle: Text(cliente.telefono ?? 'Sin teléfono'),
                      trailing: saleProvider.clienteSeleccionado?.id == cliente.id
                          ? Icon(Icons.check, color: Colors.green)
                          : null,
                      onTap: () {
                        saleProvider.setClienteSeleccionado(cliente);
                        Navigator.of(context).pop();
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              saleProvider.setClienteSeleccionado(null);
              Navigator.of(context).pop();
            },
            child: Text('Sin cliente'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancelar'),
          ),
        ],
      ),
    );
  }

  void _crearClienteDialog() {
    final nombreController = TextEditingController();
    final telefonoController = TextEditingController();
    final emailController = TextEditingController();
    final direccionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('➕ Nuevo Cliente'),
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
                final cliente = Cliente(
                  nombre: nombreController.text,
                  telefono: telefonoController.text,
                  email: emailController.text.isNotEmpty ? emailController.text : null,
                  direccion: direccionController.text.isNotEmpty ? direccionController.text : null,
                  fechaRegistro: DateTime.now(),
                );
                
                final id = await context.read<SaleProvider>().addCliente(cliente);
                if (id > 0) {
                  Navigator.of(context).pop();
                  context.read<SaleProvider>().setClienteSeleccionado(cliente);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('✅ Cliente agregado')),
                  );
                }
              }
            },
            child: Text('Guardar'),
          ),
        ],
      ),
    );
  }

  void _limpiarCarrito() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('⚠️ Limpiar Carrito'),
        content: Text('¿Está seguro de que desea eliminar todos los productos del carrito?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<SaleProvider>().limpiarCarrito();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('🛒 Carrito limpiado')),
              );
            },
            child: Text('Limpiar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _limpiarTodo() {
    _codigoController.clear();
    _busquedaController.clear();
    _descuentoController.text = '0';
    _observacionesController.clear();
    _cantidadController.text = '1';
    context.read<SaleProvider>().limpiarCarrito();
    _codigoFocus.requestFocus();
    setState(() => _mostrarPanelVenta = false);
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontWeight: FontWeight.w500)),
          Text(value, style: TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final saleProvider = context.watch<SaleProvider>();
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final isTablet = screenWidth >= 600 && screenWidth < 1200;

    return Scaffold(
      appBar: AppBar(
        title: Text('Punto de Venta'),
        actions: isMobile ? [] : _buildAppBarActions(saleProvider),
        bottom: isMobile ? _buildAppBarBottom(saleProvider) : null,
      ),
      floatingActionButton: isMobile && !_mostrarPanelVenta && saleProvider.carrito.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: () => setState(() => _mostrarPanelVenta = true),
              icon: Badge(
                label: Text(saleProvider.carrito.length.toString()),
                child: Icon(Icons.shopping_cart),
              ),
              label: Text('Ver Carrito'),
              backgroundColor: Theme.of(context).primaryColor,
            )
          : null,
      body: _buildResponsiveLayout(isMobile, isTablet),
    );
  }

  // ========== WIDGETS RESPONSIVOS ==========

  PreferredSizeWidget? _buildAppBarBottom(SaleProvider saleProvider) {
    return PreferredSize(
      preferredSize: Size.fromHeight(80),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            // Fila 1: Caja
            InkWell(
              onTap: saleProvider.cajaActiva == null ? _abrirCajaDialog : () => _mostrarInfoCaja(saleProvider.cajaActiva!),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: saleProvider.cajaActiva == null ? Colors.red.shade50 : Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: saleProvider.cajaActiva == null ? Colors.red.shade200 : Colors.green.shade200,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      saleProvider.cajaActiva == null ? Icons.lock_open : Icons.account_balance_wallet,
                      size: 20,
                      color: saleProvider.cajaActiva == null ? Colors.red : Colors.green,
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            saleProvider.cajaActiva == null ? 'Caja cerrada' : 'Caja abierta',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: saleProvider.cajaActiva == null ? Colors.red : Colors.green,
                            ),
                          ),
                          Text(
                            saleProvider.cajaActiva == null 
                                ? 'Toca para abrir' 
                                : 'Monto: \$${saleProvider.cajaActiva!.montoInicial.toStringAsFixed(2)}',
                            style: TextStyle(fontSize: 10),
                          ),
                        ],
                      ),
                    ),
                    if (saleProvider.cajaActiva != null)
                      Icon(Icons.info_outline, size: 16, color: Colors.grey),
                  ],
                ),
              ),
            ),
            
            SizedBox(height: 8),
            
            // Fila 2: Cliente y botón limpiar
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: _seleccionarCliente,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.person, size: 18, color: Colors.blue),
                          SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Cliente',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue,
                                  ),
                                ),
                                Text(
                                  saleProvider.clienteSeleccionado?.nombre ?? 'General',
                                  style: TextStyle(fontSize: 10),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                
                SizedBox(width: 8),
                
                if (saleProvider.carrito.isNotEmpty)
                  InkWell(
                    onTap: _limpiarCarrito,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.orange.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.clear_all, size: 18, color: Colors.orange),
                          SizedBox(width: 4),
                          Text(
                            'Limpiar',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildAppBarActions(SaleProvider saleProvider) {
    return [
      // Botón de caja
      IconButton(
        icon: saleProvider.cajaActiva == null 
            ? Icon(Icons.lock_open, color: Colors.red)
            : Icon(Icons.account_balance_wallet, color: Colors.green),
        onPressed: () {
          if (saleProvider.cajaActiva == null) {
            _abrirCajaDialog();
          } else {
            showModalBottomSheet(
              context: context,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              builder: (context) => Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading: Icon(Icons.info, color: Colors.blue),
                    title: Text('Información de caja'),
                    onTap: () {
                      Navigator.of(context).pop();
                      _mostrarInfoCaja(saleProvider.cajaActiva!);
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.lock, color: Colors.red),
                    title: Text('Cerrar caja'),
                    onTap: () {
                      Navigator.of(context).pop();
                      _cerrarCajaDialog();
                    },
                  ),
                  SizedBox(height: 8),
                ],
              ),
            );
          }
        },
        tooltip: saleProvider.cajaActiva == null ? 'Abrir caja' : 'Caja abierta',
      ),
      
      // Botón de cliente
      IconButton(
        icon: Icon(Icons.person,
            color: saleProvider.clienteSeleccionado != null ? Colors.green : Colors.grey),
        onPressed: _seleccionarCliente,
        tooltip: 'Seleccionar cliente',
      ),
      
      // Botón limpiar
      if (saleProvider.carrito.isNotEmpty)
        IconButton(
          icon: Icon(Icons.clear_all),
          onPressed: _limpiarCarrito,
          tooltip: 'Limpiar carrito',
        ),
    ];
  }

  Widget _buildResponsiveLayout(bool isMobile, bool isTablet) {
    if (isMobile) {
      return _buildMobileLayout();
    } else if (isTablet) {
      return _buildTabletLayout();
    } else {
      return _buildDesktopLayout();
    }
  }

  Widget _buildMobileLayout() {
    return IndexedStack(
      index: _mostrarPanelVenta ? 1 : 0,
      children: [
        // PANTALLA 1: PRODUCTOS
        _buildPanelProductos(isMobile: true),
        
        // PANTALLA 2: CARRITO Y VENTA
        _buildPanelVenta(
          isMobile: true,
          onBack: () => setState(() => _mostrarPanelVenta = false),
        ),
      ],
    );
  }

  Widget _buildTabletLayout() {
    return Column(
      children: [
        // Barra superior (30% altura)
        Expanded(
          flex: 3,
          child: _buildPanelProductos(isTablet: true),
        ),
        
        // Panel de venta (70% altura)
        Expanded(
          flex: 7,
          child: _buildPanelVenta(isTablet: true),
        ),
      ],
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      children: [
        // Panel de productos (70% ancho)
        Expanded(
          flex: 7,
          child: _buildPanelProductos(),
        ),
        
        // Panel de venta (30% ancho)
        Expanded(
          flex: 3,
          child: _buildPanelVenta(),
        ),
      ],
    );
  }

  Widget _buildPanelProductos({bool isMobile = false, bool isTablet = false}) {
    final productProvider = context.watch<ProductProvider>();
    final saleProvider = context.watch<SaleProvider>();
    
    final productosFiltrados = productProvider.searchProductos(_busquedaController.text)
        .where((p) => p.stock > 0)
        .toList();

    // Calcular columnas según tamaño de pantalla
    int crossAxisCount = 2;
    double childAspectRatio = 0.8;
    
    if (isMobile) {
      crossAxisCount = 2;
      childAspectRatio = 0.75;
    } else if (isTablet) {
      crossAxisCount = 3;
      childAspectRatio = 0.85;
    } else {
      crossAxisCount = 4;
      childAspectRatio = 0.9;
    }

    return Padding(
      padding: EdgeInsets.all(isMobile ? 8.0 : 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // BARRA DE BÚSQUEDA Y CÓDIGO
          if (isMobile) ...[
            // Diseño móvil optimizado
            Row(
              children: [
                Expanded(
                  child: TextField(
                    focusNode: _busquedaFocus,
                    controller: _busquedaController,
                    decoration: InputDecoration(
                      hintText: 'Buscar producto...',
                      prefixIcon: Icon(Icons.search, size: 20),
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                      isDense: true,
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                SizedBox(width: 8),
                Container(
                  width: 50,
                  child: TextField(
                    controller: _cantidadController,
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      hintText: 'Cant',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                      isDense: true,
                    ),
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                  ),
                ),
              ],
            ),
            
            SizedBox(height: 8),
            
            Row(
              children: [
                Expanded(
                  child: TextField(
                    focusNode: _codigoFocus,
                    controller: _codigoController,
                    decoration: InputDecoration(
                      hintText: 'Código de barras',
                      prefixIcon: Icon(Icons.qr_code, size: 20),
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                      isDense: true,
                    ),
                    onSubmitted: (_) => _agregarPorCodigo(),
                  ),
                ),
                SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _agregarPorCodigo,
                  child: Icon(Icons.add, size: 20),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.all(14),
                    shape: CircleBorder(),
                  ),
                ),
              ],
            ),
          ] else ...[
            // Diseño tablet/desktop
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: TextField(
                    focusNode: _busquedaFocus,
                    controller: _busquedaController,
                    decoration: InputDecoration(
                      labelText: 'Buscar producto...',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                      filled: true,
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  flex: 2,
                  child: TextField(
                    focusNode: _codigoFocus,
                    controller: _codigoController,
                    decoration: InputDecoration(
                      labelText: 'Código de barras',
                      border: OutlineInputBorder(),
                      filled: true,
                    ),
                    onSubmitted: (_) => _agregarPorCodigo(),
                  ),
                ),
                SizedBox(width: 10),
                SizedBox(
                  width: 100,
                  child: TextField(
                    controller: _cantidadController,
                    decoration: InputDecoration(
                      labelText: 'Cantidad',
                      border: OutlineInputBorder(),
                      filled: true,
                    ),
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                  ),
                ),
                SizedBox(width: 10),
                ElevatedButton.icon(
                  onPressed: _agregarPorCodigo,
                  icon: Icon(Icons.qr_code_scanner),
                  label: Text(isMobile ? '' : 'Agregar'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 20, vertical: 15),
                  ),
                ),
              ],
            ),
          ],
          
          SizedBox(height: 16),
          
          // FILTROS DE CATEGORÍAS
          if (productProvider.categorias.isNotEmpty)
            SizedBox(
              height: isMobile ? 36 : 44,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: productProvider.categorias.length + 1,
                separatorBuilder: (_, __) => SizedBox(width: 6),
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return InputChip(
                      label: Text('Todos'),
                      selected: _busquedaController.text.isEmpty,
                      onSelected: (selected) {
                        _busquedaController.clear();
                        setState(() {});
                      },
                      padding: EdgeInsets.symmetric(horizontal: 8),
                    );
                  }
                  
                  final categoria = productProvider.categorias[index - 1];
                  return InputChip(
                    label: Text(
                      categoria.nombre,
                      style: TextStyle(fontSize: isMobile ? 11 : 12),
                    ),
                    selected: false,
                    onSelected: (selected) {
                      // Implementar filtro por categoría
                    },
                    backgroundColor: categoria.colorAsColor.withOpacity(0.1),
                    padding: EdgeInsets.symmetric(horizontal: 8),
                  );
                },
              ),
            ),
          
          if (productProvider.categorias.isNotEmpty) SizedBox(height: 12),
          
          // CONTADOR DE PRODUCTOS
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${productosFiltrados.length} productos',
                  style: TextStyle(
                    fontSize: isMobile ? 12 : 14,
                    color: Colors.grey.shade600,
                  ),
                ),
                if (saleProvider.carrito.isNotEmpty)
                  Text(
                    '${saleProvider.carrito.length} en carrito',
                    style: TextStyle(
                      fontSize: isMobile ? 12 : 14,
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ],
            ),
          ),
          
          SizedBox(height: 8),
          
          // LISTA DE PRODUCTOS
          Expanded(
            child: productProvider.isLoading
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text(
                          'Cargando productos...',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : productosFiltrados.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.inventory_2, size: 60, color: Colors.grey.shade300),
                            SizedBox(height: 16),
                            Text(
                              'No hay productos disponibles',
                              style: TextStyle(
                                color: Colors.grey, 
                                fontSize: isMobile ? 14 : 16
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 8),
                            if (_busquedaController.text.isNotEmpty)
                              ElevatedButton(
                                onPressed: () {
                                  _busquedaController.clear();
                                  setState(() {});
                                },
                                child: Text('Limpiar búsqueda'),
                                style: ElevatedButton.styleFrom(
                                  minimumSize: Size(200, 40),
                                ),
                              ),
                          ],
                        ),
                      )
                    : GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          crossAxisSpacing: isMobile ? 6 : 8,
                          mainAxisSpacing: isMobile ? 6 : 8,
                          childAspectRatio: childAspectRatio,
                        ),
                        itemCount: productosFiltrados.length,
                        itemBuilder: (context, index) {
                          final producto = productosFiltrados[index];
                          final enCarrito = saleProvider.carrito
                              .any((item) => item.idProducto == producto.id);
                          
                          return ProductoCardVenta(
                            producto: producto,
                            enCarrito: enCarrito,
                            isMobile: isMobile,
                            onTap: () => saleProvider.agregarProductoAlCarrito(producto),
                            onLongPress: () {
                              showModalBottomSheet(
                                context: context,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                                ),
                                builder: (context) => Padding(
                                  padding: EdgeInsets.only(
                                    bottom: MediaQuery.of(context).viewInsets.bottom,
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      ListTile(
                                        title: Text(
                                          producto.nombre,
                                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                                        ),
                                        subtitle: Text('Código: ${producto.codigo.isEmpty ? "No asignado" : producto.codigo}'),
                                      ),
                                      Divider(),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 20),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            _buildProductoInfo('Precio:', producto.precioVentaFormatted),
                                            _buildProductoInfo('Stock:', producto.stockFormatted),
                                            if (producto.descripcion.isNotEmpty)
                                              _buildProductoInfo('Descripción:', producto.descripcion),
                                            if (producto.categoriaNombre != null)
                                              _buildProductoInfo('Categoría:', producto.categoriaNombre!),
                                          ],
                                        ),
                                      ),
                                      SizedBox(height: 20),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductoInfo(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(fontWeight: FontWeight.w500, color: Colors.grey),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontWeight: FontWeight.w400),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPanelVenta({bool isMobile = false, bool isTablet = false, VoidCallback? onBack}) {
    final saleProvider = context.watch<SaleProvider>();
    final authProvider = context.watch<AuthProvider>();

    return Container(
      decoration: BoxDecoration(
        border: isMobile
            ? null
            : Border(left: BorderSide(color: Colors.grey.shade300)),
        color: Colors.grey.shade50,
      ),
      child: Column(
        children: [
          // ENCABEZADO
          Container(
            padding: EdgeInsets.all(isMobile ? 12 : 16),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                if (isMobile && onBack != null)
                  IconButton(
                    icon: Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: onBack,
                  ),
                
                Icon(Icons.shopping_cart, color: Colors.white),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'VENTA ACTUAL',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isMobile ? 16 : 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                
                Badge(
                  label: Text(saleProvider.carrito.length.toString()),
                  backgroundColor: Colors.white,
                  textColor: Theme.of(context).primaryColor,
                ),
              ],
            ),
          ),
          
          // RESUMEN RÁPIDO DE CAJA
          if (!isMobile && saleProvider.cajaActiva != null)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Colors.green.shade50,
              child: Row(
                children: [
                  Icon(Icons.account_balance_wallet, size: 16, color: Colors.green),
                  SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Caja abierta',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                        Text(
                          'Inicial: \$${saleProvider.cajaActiva!.montoInicial.toStringAsFixed(2)}',
                          style: TextStyle(fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  InkWell(
                    onTap: () => _mostrarInfoCaja(saleProvider.cajaActiva!),
                    child: Icon(Icons.info_outline, size: 16, color: Colors.grey),
                  ),
                ],
              ),
            ),
          
          // LISTA DE PRODUCTOS EN CARRITO
          Expanded(
            child: saleProvider.carrito.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.shopping_cart_outlined, 
                            size: isMobile ? 40 : 60, 
                            color: Colors.grey.shade300),
                        SizedBox(height: 16),
                        Text(
                          'Carrito vacío',
                          style: TextStyle(
                            color: Colors.grey, 
                            fontSize: isMobile ? 14 : 16
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Agregue productos',
                          style: TextStyle(
                            color: Colors.grey.shade400,
                            fontSize: isMobile ? 12 : 14,
                          ),
                        ),
                        if (isMobile)
                          Padding(
                            padding: const EdgeInsets.only(top: 20),
                            child: ElevatedButton(
                              onPressed: () => setState(() => _mostrarPanelVenta = false),
                              child: Text('Buscar productos'),
                            ),
                          ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: saleProvider.carrito.length,
                    itemBuilder: (context, index) {
                      final item = saleProvider.carrito[index];
                      return ItemCarritoCard(
                        item: item,
                        isMobile: isMobile,
                        onCantidadChanged: (cantidad) {
                          saleProvider.actualizarCantidadProducto(item.idProducto, cantidad);
                        },
                        onRemove: () {
                          saleProvider.removerProductoDelCarrito(item.idProducto);
                        },
                      );
                    },
                  ),
          ),
          
          // TOTALES Y CONFIGURACIÓN
          Container(
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: Colors.grey.shade300)),
              color: Colors.white,
            ),
            child: Column(
              children: [
                // TOTALES
                Padding(
                  padding: EdgeInsets.all(isMobile ? 12 : 16),
                  child: Column(
                    children: [
                      _buildTotalRow('Subtotal:', saleProvider.subtotal, isMobile: isMobile),
                      _buildTotalRow('Descuento:', saleProvider.totalDescuentos, isMobile: isMobile),
                      _buildTotalRow('IVA (16%):', saleProvider.ivaCalculado, isMobile: isMobile),
                      Divider(height: 20),
                      _buildTotalRow(
                        'TOTAL:',
                        saleProvider.total,
                        isTotal: true,
                        isMobile: isMobile,
                      ),
                    ],
                  ),
                ),
                
                // CONFIGURACIÓN DE VENTA
                if (isMobile) ...[
                  // Móvil: diseño compacto
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _descuentoController,
                                decoration: InputDecoration(
                                  labelText: 'Descuento',
                                  prefixText: '\$',
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.all(12),
                                ),
                                keyboardType: TextInputType.numberWithOptions(decimal: true),
                                onChanged: (value) {
                                  final descuento = double.tryParse(value) ?? 0;
                                  saleProvider.setDescuentoGlobal(descuento);
                                },
                              ),
                            ),
                            SizedBox(width: 8),
                            IconButton(
                              icon: Icon(Icons.percent),
                              onPressed: () {
                                final porcentaje = saleProvider.subtotal * 0.10;
                                _descuentoController.text = porcentaje.toStringAsFixed(2);
                                saleProvider.setDescuentoGlobal(porcentaje);
                              },
                              tooltip: '10% del subtotal',
                            ),
                          ],
                        ),
                        
                        SizedBox(height: 12),
                        
                        DropdownButtonFormField<String>(
                          value: saleProvider.metodoPago,
                          decoration: InputDecoration(
                            labelText: 'Método de pago',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.all(12),
                          ),
                          items: [
                            DropdownMenuItem(value: 'efectivo', child: Text('💵 Efectivo')),
                            DropdownMenuItem(value: 'tarjeta', child: Text('💳 Tarjeta')),
                            DropdownMenuItem(value: 'transferencia', child: Text('🏦 Transferencia')),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              saleProvider.setMetodoPago(value);
                            }
                          },
                        ),
                        
                        SizedBox(height: 12),
                        
                        TextField(
                          controller: _observacionesController,
                          decoration: InputDecoration(
                            labelText: 'Observaciones',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.all(12),
                          ),
                          maxLines: 2,
                          onChanged: (value) {
                            saleProvider.setObservaciones(value);
                          },
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  // Tablet/Desktop: acordeón
                  ExpansionTile(
                    title: Text('⚙️ Configuración de venta'),
                    initiallyExpanded: false,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        child: Column(
                          children: [
                            TextField(
                              controller: _descuentoController,
                              decoration: InputDecoration(
                                labelText: 'Descuento global (\$)',
                                prefixText: '\$',
                                border: OutlineInputBorder(),
                                suffixIcon: IconButton(
                                  icon: Icon(Icons.percent),
                                  onPressed: () {
                                    final porcentaje = saleProvider.subtotal * 0.10;
                                    _descuentoController.text = porcentaje.toStringAsFixed(2);
                                    saleProvider.setDescuentoGlobal(porcentaje);
                                  },
                                  tooltip: '10% del subtotal',
                                ),
                              ),
                              keyboardType: TextInputType.numberWithOptions(decimal: true),
                              onChanged: (value) {
                                final descuento = double.tryParse(value) ?? 0;
                                saleProvider.setDescuentoGlobal(descuento);
                              },
                            ),
                            
                            SizedBox(height: 12),
                            
                            DropdownButtonFormField<String>(
                              value: saleProvider.metodoPago,
                              decoration: InputDecoration(
                                labelText: 'Método de pago',
                                border: OutlineInputBorder(),
                              ),
                              items: [
                                DropdownMenuItem(value: 'efectivo', child: Text('💵 Efectivo')),
                                DropdownMenuItem(value: 'tarjeta', child: Text('💳 Tarjeta')),
                                DropdownMenuItem(value: 'transferencia', child: Text('🏦 Transferencia')),
                                DropdownMenuItem(value: 'mixto', child: Text('💰 Mixto')),
                              ],
                              onChanged: (value) {
                                if (value != null) {
                                  saleProvider.setMetodoPago(value);
                                }
                              },
                            ),
                            
                            SizedBox(height: 12),
                            
                            TextField(
                              controller: _observacionesController,
                              decoration: InputDecoration(
                                labelText: 'Observaciones (opcional)',
                                border: OutlineInputBorder(),
                              ),
                              maxLines: 2,
                              onChanged: (value) {
                                saleProvider.setObservaciones(value);
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
                
                // BOTÓN FINALIZAR VENTA
                Padding(
                  padding: EdgeInsets.all(isMobile ? 12 : 16),
                  child: SizedBox(
                    width: double.infinity,
                    height: isMobile ? 50 : 56,
                    child: ElevatedButton.icon(
                      onPressed: saleProvider.carrito.isNotEmpty && saleProvider.cajaActiva != null
                          ? _procesarVenta
                          : null,
                      icon: Icon(Icons.payment, size: isMobile ? 20 : 24),
                      label: Text(
                        isMobile ? 'FINALIZAR' : 'FINALIZAR VENTA',
                        style: TextStyle(fontSize: isMobile ? 14 : 16),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(isMobile ? 8 : 12),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalRow(String label, double value, {bool isTotal = false, bool isMobile = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
              fontSize: isMobile ? (isTotal ? 16 : 14) : (isTotal ? 18 : 16),
            ),
          ),
          Text(
            '\$${value.toStringAsFixed(2)}',
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
              fontSize: isMobile ? (isTotal ? 16 : 14) : (isTotal ? 18 : 16),
              color: isTotal ? Colors.green : null,
            ),
          ),
        ],
      ),
    );
  }

  void _mostrarInfoCaja(Caja caja) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('📊 Información de Caja'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoRow('Folio:', caja.folio),
              _buildInfoRow('Estado:', caja.estado.toUpperCase()),
              _buildInfoRow('Usuario:', caja.usuarioNombre ?? 'N/A'),
              _buildInfoRow('Monto inicial:', caja.montoInicialFormatted),
              _buildInfoRow('Monto final:', caja.montoFinalFormatted),
              _buildInfoRow('Diferencia:', caja.diferenciaFormatted),
              _buildInfoRow('Apertura:', caja.fechaAperturaFormatted),
              if (caja.fechaCierreFormatted != null)
                _buildInfoRow('Cierre:', caja.fechaCierreFormatted!),
              if (caja.observaciones != null && caja.observaciones!.isNotEmpty) ...[
                SizedBox(height: 16),
                Text('Observaciones:', style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 4),
                Text(caja.observaciones!),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cerrar'),
          ),
          if (caja.isAbierta)
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _cerrarCajaDialog();
              },
              child: Text('Cerrar Caja', style: TextStyle(color: Colors.red)),
            ),
        ],
      ),
    );
  }
}

// ========== WIDGETS REUTILIZABLES ==========

class ProductoCardVenta extends StatelessWidget {
  final Product producto;
  final bool enCarrito;
  final bool isMobile;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  const ProductoCardVenta({
    required this.producto,
    required this.enCarrito,
    required this.onTap,
    this.onLongPress,
    this.isMobile = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 1,
      color: enCarrito ? Colors.blue.shade50 : null,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: EdgeInsets.all(isMobile ? 8.0 : 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Nombre del producto
              Text(
                producto.nombre,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: isMobile ? 12 : 14,
                  height: 1.2,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              
              SizedBox(height: 4),
              
              // Código (solo si hay espacio)
              if (!isMobile && producto.codigo.isNotEmpty)
                Text(
                  'Cód: ${producto.codigo}',
                  style: TextStyle(fontSize: 10, color: Colors.grey),
                ),
              
              Spacer(),
              
              // Precio
              Text(
                producto.precioVentaFormatted,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.green.shade700,
                  fontSize: isMobile ? 13 : 15,
                ),
              ),
              
              SizedBox(height: 4),
              
              // Stock y estado
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: producto.bajoStock ? Colors.red.shade50 : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: producto.bajoStock ? Colors.red.shade200 : Colors.grey.shade300,
                        width: 0.5,
                      ),
                    ),
                    child: Text(
                      producto.stockFormatted,
                      style: TextStyle(
                        fontSize: isMobile ? 10 : 11,
                        color: producto.bajoStock ? Colors.red : Colors.grey.shade700,
                        fontWeight: producto.bajoStock ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                  
                  // Indicador en carrito
                  if (enCarrito)
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade100,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Icon(
                        Icons.check,
                        size: isMobile ? 12 : 14,
                        color: Colors.blue.shade800,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ItemCarritoCard extends StatelessWidget {
  final VentaDetalle item;
  final bool isMobile;
  final Function(double) onCantidadChanged;
  final VoidCallback onRemove;

  const ItemCarritoCard({
    required this.item,
    required this.onCantidadChanged,
    required this.onRemove,
    this.isMobile = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(
        horizontal: isMobile ? 8 : 12, 
        vertical: isMobile ? 4 : 6
      ),
      elevation: 1,
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 8.0 : 12.0),
        child: Row(
          children: [
            // Información del producto
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.productoNombre ?? 'Producto',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: isMobile ? 12 : 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4),
                  Text(
                    '\$${item.precioUnitario.toStringAsFixed(2)} c/u',
                    style: TextStyle(
                      fontSize: isMobile ? 10 : 12, 
                      color: Colors.grey
                    ),
                  ),
                ],
              ),
            ),
            
            // Controles de cantidad
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.remove, size: isMobile ? 16 : 18),
                    splashRadius: isMobile ? 16 : 20,
                    padding: EdgeInsets.all(isMobile ? 2 : 4),
                    visualDensity: VisualDensity.compact,
                    onPressed: () {
                      final nuevaCantidad = item.cantidad - 1;
                      if (nuevaCantidad > 0) {
                        onCantidadChanged(nuevaCantidad);
                      } else {
                        onRemove();
                      }
                    },
                  ),
                  Container(
                    width: isMobile ? 30 : 40,
                    alignment: Alignment.center,
                    child: Text(
                      item.cantidad.toStringAsFixed(item.cantidad % 1 == 0 ? 0 : 2),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: isMobile ? 12 : 14,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.add, size: isMobile ? 16 : 18),
                    splashRadius: isMobile ? 16 : 20,
                    padding: EdgeInsets.all(isMobile ? 2 : 4),
                    visualDensity: VisualDensity.compact,
                    onPressed: () {
                      onCantidadChanged(item.cantidad + 1);
                    },
                  ),
                ],
              ),
            ),
            
            // Total y botón eliminar
            Padding(
              padding: EdgeInsets.only(left: isMobile ? 8 : 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    item.totalFormatted,
                    style: TextStyle(
                      fontWeight: FontWeight.bold, 
                      fontSize: isMobile ? 13 : 15,
                      color: Colors.green.shade700,
                    ),
                  ),
                  SizedBox(height: 4),
                  IconButton(
                    icon: Icon(
                      Icons.delete_outline, 
                      size: isMobile ? 18 : 20, 
                      color: Colors.red.shade400
                    ),
                    splashRadius: isMobile ? 18 : 22,
                    padding: EdgeInsets.all(isMobile ? 4 : 6),
                    visualDensity: VisualDensity.compact,
                    onPressed: onRemove,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}