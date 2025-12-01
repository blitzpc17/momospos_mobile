import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/models.dart';
import '../../providers/product_provider.dart';

class ProductosScreen extends StatefulWidget {
  @override
  _ProductosScreenState createState() => _ProductosScreenState();
}

class _ProductosScreenState extends State<ProductosScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _filtroCategoria = 'todas';
  String _orden = 'nombre';
  bool _soloBajoStock = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().loadProductos();
    });
  }

  List<Product> _getProductosFiltrados(ProductProvider productProvider) {
    var productos = productProvider.productos;

    // Filtrar por búsqueda
    if (_searchController.text.isNotEmpty) {
      final query = _searchController.text.toLowerCase();
      productos = productos.where((p) =>
        p.nombre.toLowerCase().contains(query) ||
        p.codigo.toLowerCase().contains(query) ||
        p.descripcion.toLowerCase().contains(query)
      ).toList();
    }

    // Filtrar por categoría
    if (_filtroCategoria != 'todas') {
      final categoriaId = int.tryParse(_filtroCategoria);
      if (categoriaId != null) {
        productos = productos.where((p) => p.idCategoria == categoriaId).toList();
      }
    }

    // Filtrar por bajo stock
    if (_soloBajoStock) {
      productos = productos.where((p) => p.bajoStock).toList();
    }

    // Ordenar
    productos.sort((a, b) {
      switch (_orden) {
        case 'nombre':
          return a.nombre.compareTo(b.nombre);
        case 'precio_asc':
          return a.precioVenta.compareTo(b.precioVenta);
        case 'precio_desc':
          return b.precioVenta.compareTo(a.precioVenta);
        case 'stock_asc':
          return a.stock.compareTo(b.stock);
        case 'stock_desc':
          return b.stock.compareTo(a.stock);
        default:
          return a.nombre.compareTo(b.nombre);
      }
    });

    return productos;
  }

  void _mostrarDialogoAgregarProducto() {
    final nombreController = TextEditingController();
    final codigoController = TextEditingController();
    final descripcionController = TextEditingController();
    final precioCompraController = TextEditingController();
    final precioVentaController = TextEditingController();
    final stockController = TextEditingController();
    final stockMinimoController = TextEditingController(text: '5');
    String unidadMedidaSeleccionada = 'pieza';
    int? categoriaSeleccionada;
    bool aplicaIva = true;

    final productProvider = context.read<ProductProvider>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Container(
              padding: EdgeInsets.all(20),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '➕ Nuevo Producto',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          icon: Icon(Icons.close),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ],
                    ),
                    
                    SizedBox(height: 20),
                    
                    // Nombre
                    TextField(
                      controller: nombreController,
                      decoration: InputDecoration(
                        labelText: 'Nombre del producto *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.shopping_bag),
                      ),
                    ),
                    
                    SizedBox(height: 12),
                    
                    // Código y categoría
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: codigoController,
                            decoration: InputDecoration(
                              labelText: 'Código',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.qr_code),
                            ),
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: DropdownButtonFormField<int>(
                            value: categoriaSeleccionada,
                            decoration: InputDecoration(
                              labelText: 'Categoría *',
                              border: OutlineInputBorder(),
                            ),
                            items: [
                              DropdownMenuItem(
                                value: null,
                                child: Text('Seleccionar...'),
                              ),
                              ...productProvider.categorias.map((categoria) {
                                return DropdownMenuItem(
                                  value: categoria.id,
                                  child: Text(categoria.nombre),
                                );
                              }).toList(),
                            ],
                            onChanged: (value) {
                              setState(() => categoriaSeleccionada = value);
                            },
                          ),
                        ),
                      ],
                    ),
                    
                    SizedBox(height: 12),
                    
                    // Descripción
                    TextField(
                      controller: descripcionController,
                      decoration: InputDecoration(
                        labelText: 'Descripción',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.description),
                      ),
                      maxLines: 2,
                    ),
                    
                    SizedBox(height: 12),
                    
                    // Precios
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: precioCompraController,
                            decoration: InputDecoration(
                              labelText: 'Precio compra',
                              border: OutlineInputBorder(),
                              prefixText: '\$ ',
                            ),
                            keyboardType: TextInputType.numberWithOptions(decimal: true),
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: precioVentaController,
                            decoration: InputDecoration(
                              labelText: 'Precio venta *',
                              border: OutlineInputBorder(),
                              prefixText: '\$ ',
                            ),
                            keyboardType: TextInputType.numberWithOptions(decimal: true),
                          ),
                        ),
                      ],
                    ),
                    
                    SizedBox(height: 12),
                    
                    // Stock
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: stockController,
                            decoration: InputDecoration(
                              labelText: 'Stock inicial',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.numberWithOptions(decimal: true),
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: stockMinimoController,
                            decoration: InputDecoration(
                              labelText: 'Stock mínimo',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.numberWithOptions(decimal: true),
                          ),
                        ),
                      ],
                    ),
                    
                    SizedBox(height: 12),
                    
                    // Unidad de medida e IVA
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: unidadMedidaSeleccionada,
                            decoration: InputDecoration(
                              labelText: 'Unidad',
                              border: OutlineInputBorder(),
                            ),
                            items: ['pieza', 'kg', 'litro', 'metro', 'paquete']
                                .map((unidad) => DropdownMenuItem(
                                      value: unidad,
                                      child: Text(unidad),
                                    ))
                                .toList(),
                            onChanged: (value) {
                              setState(() => unidadMedidaSeleccionada = value!);
                            },
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: SwitchListTile(
                            title: Text('Aplica IVA'),
                            value: aplicaIva,
                            onChanged: (value) {
                              setState(() => aplicaIva = value);
                            },
                          ),
                        ),
                      ],
                    ),
                    
                    SizedBox(height: 24),
                    
                    // Botones de acción
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: Text('Cancelar'),
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async {
                              if (nombreController.text.isEmpty ||
                                  categoriaSeleccionada == null ||
                                  precioVentaController.text.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Complete los campos obligatorios (*)'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                                return;
                              }
                              
                              final producto = Product(
                                codigo: codigoController.text,
                                nombre: nombreController.text,
                                descripcion: descripcionController.text,
                                idCategoria: categoriaSeleccionada!,
                                precioCompra: double.tryParse(precioCompraController.text) ?? 0,
                                precioVenta: double.tryParse(precioVentaController.text) ?? 0,
                                stock: double.tryParse(stockController.text) ?? 0,
                                stockMinimo: double.tryParse(stockMinimoController.text) ?? 5,
                                unidadMedida: unidadMedidaSeleccionada,
                                aplicaIva: aplicaIva,
                                fechaCreacion: DateTime.now(),
                              );
                              
                              final id = await productProvider.addProducto(producto);
                              if (id > 0) {
                                Navigator.of(context).pop();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Producto agregado exitosamente'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              }
                            },
                            child: Text('Guardar Producto'),
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 15),
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _mostrarDialogoEditarProducto(Product producto) {
    final nombreController = TextEditingController(text: producto.nombre);
    final codigoController = TextEditingController(text: producto.codigo);
    final descripcionController = TextEditingController(text: producto.descripcion);
    final precioCompraController = TextEditingController(text: producto.precioCompra.toStringAsFixed(2));
    final precioVentaController = TextEditingController(text: producto.precioVenta.toStringAsFixed(2));
    final stockController = TextEditingController(text: producto.stock.toStringAsFixed(2));
    final stockMinimoController = TextEditingController(text: producto.stockMinimo.toStringAsFixed(2));
    String unidadMedidaSeleccionada = producto.unidadMedida;
    int categoriaSeleccionada = producto.idCategoria;
    bool aplicaIva = producto.aplicaIva;

    final productProvider = context.read<ProductProvider>();
    final categoria = productProvider.getCategoriaById(producto.idCategoria);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Container(
              padding: EdgeInsets.all(20),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '✏️ Editar Producto',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          icon: Icon(Icons.close),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ],
                    ),
                    
                    SizedBox(height: 20),
                    
                    // Información actual
                    Card(
                      color: Colors.blue.shade50,
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Información actual:', style: TextStyle(fontWeight: FontWeight.bold)),
                            SizedBox(height: 4),
                            Text('Código: ${producto.codigo.isEmpty ? "No asignado" : producto.codigo}'),
                            Text('Categoría: ${categoria?.nombre ?? "N/A"}'),
                            Text('Última actualización: ${DateFormat('dd/MM/yyyy').format(producto.fechaCreacion)}'),
                          ],
                        ),
                      ),
                    ),
                    
                    SizedBox(height: 16),
                    
                    // Campos de edición
                    TextField(
                      controller: nombreController,
                      decoration: InputDecoration(
                        labelText: 'Nombre del producto *',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    
                    SizedBox(height: 12),
                    
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: codigoController,
                            decoration: InputDecoration(
                              labelText: 'Código',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: DropdownButtonFormField<int>(
                            value: categoriaSeleccionada,
                            decoration: InputDecoration(
                              labelText: 'Categoría *',
                              border: OutlineInputBorder(),
                            ),
                            items: productProvider.categorias.map((categoria) {
                              return DropdownMenuItem(
                                value: categoria.id,
                                child: Text(categoria.nombre),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() => categoriaSeleccionada = value!);
                            },
                          ),
                        ),
                      ],
                    ),
                    
                    SizedBox(height: 12),
                    
                    TextField(
                      controller: descripcionController,
                      decoration: InputDecoration(
                        labelText: 'Descripción',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 2,
                    ),
                    
                    SizedBox(height: 12),
                    
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: precioCompraController,
                            decoration: InputDecoration(
                              labelText: 'Precio compra',
                              border: OutlineInputBorder(),
                              prefixText: '\$ ',
                            ),
                            keyboardType: TextInputType.numberWithOptions(decimal: true),
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: precioVentaController,
                            decoration: InputDecoration(
                              labelText: 'Precio venta *',
                              border: OutlineInputBorder(),
                              prefixText: '\$ ',
                            ),
                            keyboardType: TextInputType.numberWithOptions(decimal: true),
                          ),
                        ),
                      ],
                    ),
                    
                    SizedBox(height: 12),
                    
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: stockController,
                            decoration: InputDecoration(
                              labelText: 'Stock actual',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.numberWithOptions(decimal: true),
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: stockMinimoController,
                            decoration: InputDecoration(
                              labelText: 'Stock mínimo',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.numberWithOptions(decimal: true),
                          ),
                        ),
                      ],
                    ),
                    
                    SizedBox(height: 12),
                    
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: unidadMedidaSeleccionada,
                            decoration: InputDecoration(
                              labelText: 'Unidad',
                              border: OutlineInputBorder(),
                            ),
                            items: ['pieza', 'kg', 'litro', 'metro', 'paquete']
                                .map((unidad) => DropdownMenuItem(
                                      value: unidad,
                                      child: Text(unidad),
                                    ))
                                .toList(),
                            onChanged: (value) {
                              setState(() => unidadMedidaSeleccionada = value!);
                            },
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: SwitchListTile(
                            title: Text('Aplica IVA'),
                            value: aplicaIva,
                            onChanged: (value) {
                              setState(() => aplicaIva = value);
                            },
                          ),
                        ),
                      ],
                    ),
                    
                    SizedBox(height: 24),
                    
                    // Estadísticas
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Column(
                              children: [
                                Text(
                                  '${producto.stock.toStringAsFixed(0)}',
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  'Stock',
                                  style: TextStyle(fontSize: 12, color: Colors.grey),
                                ),
                              ],
                            ),
                            Column(
                              children: [
                                Text(
                                  producto.bajoStock ? 'BAJO' : 'OK',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: producto.bajoStock ? Colors.red : Colors.green,
                                  ),
                                ),
                                Text(
                                  'Estado',
                                  style: TextStyle(fontSize: 12, color: Colors.grey),
                                ),
                              ],
                            ),
                            Column(
                              children: [
                                Text(
                                  producto.precioVentaFormatted,
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  'Precio',
                                  style: TextStyle(fontSize: 12, color: Colors.grey),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    SizedBox(height: 16),
                    
                    // Botones de acción
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: Text('Cancelar'),
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async {
                              if (nombreController.text.isEmpty || precioVentaController.text.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Complete los campos obligatorios'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                                return;
                              }
                              
                              final productoActualizado = Product(
                                id: producto.id,
                                codigo: codigoController.text,
                                nombre: nombreController.text,
                                descripcion: descripcionController.text,
                                idCategoria: categoriaSeleccionada,
                                precioCompra: double.tryParse(precioCompraController.text) ?? 0,
                                precioVenta: double.tryParse(precioVentaController.text) ?? 0,
                                stock: double.tryParse(stockController.text) ?? 0,
                                stockMinimo: double.tryParse(stockMinimoController.text) ?? 5,
                                unidadMedida: unidadMedidaSeleccionada,
                                aplicaIva: aplicaIva,
                                fechaCreacion: producto.fechaCreacion,
                              );
                              
                              final success = await productProvider.updateProducto(productoActualizado);
                              if (success) {
                                Navigator.of(context).pop();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Producto actualizado exitosamente'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Error al actualizar producto'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            },
                            child: Text('Actualizar Producto'),
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 15),
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    SizedBox(height: 8),
                    
                    // Botón para eliminar
                    OutlinedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        _mostrarDialogoEliminarProducto(producto);
                      },
                      child: Text(
                        'Eliminar Producto',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                    
                    SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _mostrarDialogoEliminarProducto(Product producto) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Eliminar Producto'),
        content: Text('¿Está seguro de que desea eliminar el producto "${producto.nombre}"?\n\nEsta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              final success = await context.read<ProductProvider>().deleteProducto(producto.id!);
              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Producto eliminado exitosamente'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            child: Text(
              'Eliminar',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _mostrarOpcionesProducto(Product producto) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: Icon(Icons.edit, color: Colors.blue),
            title: Text('Editar producto'),
            onTap: () {
              Navigator.of(context).pop();
              _mostrarDialogoEditarProducto(producto);
            },
          ),
          ListTile(
            leading: Icon(Icons.content_copy, color: Colors.orange),
            title: Text('Duplicar producto'),
            onTap: () {
              Navigator.of(context).pop();
              // Implementar duplicación
            },
          ),
          ListTile(
            leading: Icon(Icons.inventory, color: Colors.purple),
            title: Text('Ajustar inventario'),
            onTap: () {
              Navigator.of(context).pop();
              _mostrarDialogoAjusteInventario(producto);
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.delete, color: Colors.red),
            title: Text('Eliminar producto'),
            onTap: () {
              Navigator.of(context).pop();
              _mostrarDialogoEliminarProducto(producto);
            },
          ),
        ],
      ),
    );
  }

  void _mostrarDialogoAjusteInventario(Product producto) {
    final cantidadController = TextEditingController();
    final motivoController = TextEditingController();
    String tipoAjuste = 'entrada';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text('📦 Ajustar Inventario'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Producto: ${producto.nombre}'),
                  Text('Stock actual: ${producto.stockFormatted}'),
                  SizedBox(height: 16),
                  
                  DropdownButtonFormField<String>(
                    value: tipoAjuste,
                    decoration: InputDecoration(
                      labelText: 'Tipo de ajuste',
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      DropdownMenuItem(
                        value: 'entrada',
                        child: Text('➕ Entrada de inventario'),
                      ),
                      DropdownMenuItem(
                        value: 'salida',
                        child: Text('➖ Salida de inventario'),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() => tipoAjuste = value!);
                    },
                  ),
                  
                  SizedBox(height: 12),
                  
                  TextField(
                    controller: cantidadController,
                    decoration: InputDecoration(
                      labelText: 'Cantidad',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                  ),
                  
                  SizedBox(height: 12),
                  
                  TextField(
                    controller: motivoController,
                    decoration: InputDecoration(
                      labelText: 'Motivo del ajuste',
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
                onPressed: () {
                  final cantidad = double.tryParse(cantidadController.text);
                  if (cantidad == null || cantidad <= 0) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Ingrese una cantidad válida')),
                    );
                    return;
                  }
                  
                  double nuevoStock = producto.stock;
                  if (tipoAjuste == 'entrada') {
                    nuevoStock += cantidad;
                  } else {
                    if (cantidad > producto.stock) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('No hay suficiente stock disponible')),
                      );
                      return;
                    }
                    nuevoStock -= cantidad;
                  }
                  
                  final productoActualizado = Product(
                    id: producto.id,
                    codigo: producto.codigo,
                    nombre: producto.nombre,
                    descripcion: producto.descripcion,
                    idCategoria: producto.idCategoria,
                    precioCompra: producto.precioCompra,
                    precioVenta: producto.precioVenta,
                    stock: nuevoStock,
                    stockMinimo: producto.stockMinimo,
                    unidadMedida: producto.unidadMedida,
                    aplicaIva: producto.aplicaIva,
                    fechaCreacion: producto.fechaCreacion,
                  );
                  
                  context.read<ProductProvider>().updateProducto(productoActualizado);
                  Navigator.of(context).pop();
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Inventario ajustado exitosamente'),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
                child: Text('Aplicar Ajuste'),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = context.watch<ProductProvider>();
    final productosFiltrados = _getProductosFiltrados(productProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Gestión de Productos'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: _mostrarDialogoAgregarProducto,
            tooltip: 'Agregar producto',
          ),
        ],
      ),
      body: Column(
        children: [
          // Barra de búsqueda y filtros
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    labelText: 'Buscar productos...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                    filled: true,
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                
                SizedBox(height: 12),
                
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _filtroCategoria,
                        decoration: InputDecoration(
                          labelText: 'Categoría',
                          border: OutlineInputBorder(),
                          filled: true,
                        ),
                        items: [
                          DropdownMenuItem(
                            value: 'todas',
                            child: Text('Todas las categorías'),
                          ),
                          ...productProvider.categorias.map((categoria) {
                            return DropdownMenuItem(
                              value: categoria.id.toString(),
                              child: Text(categoria.nombre),
                            );
                          }).toList(),
                        ],
                        onChanged: (value) {
                          setState(() => _filtroCategoria = value!);
                        },
                      ),
                    ),
                    
                    SizedBox(width: 12),
                    
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _orden,
                        decoration: InputDecoration(
                          labelText: 'Ordenar por',
                          border: OutlineInputBorder(),
                          filled: true,
                        ),
                        items: [
                          DropdownMenuItem(value: 'nombre', child: Text('Nombre A-Z')),
                          DropdownMenuItem(value: 'precio_asc', child: Text('Precio: Menor a Mayor')),
                          DropdownMenuItem(value: 'precio_desc', child: Text('Precio: Mayor a Menor')),
                          DropdownMenuItem(value: 'stock_asc', child: Text('Stock: Menor a Mayor')),
                          DropdownMenuItem(value: 'stock_desc', child: Text('Stock: Mayor a Menor')),
                        ],
                        onChanged: (value) {
                          setState(() => _orden = value!);
                        },
                      ),
                    ),
                  ],
                ),
                
                SizedBox(height: 8),
                
                // Filtros adicionales
                Row(
                  children: [
                    FilterChip(
                      label: Text('Solo bajo stock'),
                      selected: _soloBajoStock,
                      onSelected: (selected) {
                        setState(() => _soloBajoStock = selected);
                      },
                    ),
                    SizedBox(width: 8),
                    Chip(
                      label: Text('${productosFiltrados.length} productos'),
                      backgroundColor: Colors.blue.shade50,
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Lista de productos
          Expanded(
            child: productProvider.isLoading
                ? Center(child: CircularProgressIndicator())
                : productosFiltrados.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.inventory_2, size: 80, color: Colors.grey.shade300),
                            SizedBox(height: 16),
                            Text(
                              'No se encontraron productos',
                              style: TextStyle(fontSize: 18, color: Colors.grey),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Intente con otros términos de búsqueda',
                              style: TextStyle(color: Colors.grey.shade400),
                            ),
                            SizedBox(height: 20),
                            ElevatedButton.icon(
                              onPressed: _mostrarDialogoAgregarProducto,
                              icon: Icon(Icons.add),
                              label: Text('Agregar Primer Producto'),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: EdgeInsets.only(bottom: 80),
                        itemCount: productosFiltrados.length,
                        itemBuilder: (context, index) {
                          final producto = productosFiltrados[index];
                          return ProductoCard(
                            producto: producto,
                            onTap: () => _mostrarOpcionesProducto(producto),
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _mostrarDialogoAgregarProducto,
        child: Icon(Icons.add),
        tooltip: 'Agregar producto',
      ),
    );
  }
}

class ProductoCard extends StatelessWidget {
  final Product producto;
  final VoidCallback onTap;

  const ProductoCard({
    required this.producto,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              // Indicador de stock
              Container(
                width: 4,
                height: 60,
                decoration: BoxDecoration(
                  color: producto.bajoStock ? Colors.red : Colors.green,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              SizedBox(width: 12),
              
              // Información del producto
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      producto.nombre,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    SizedBox(height: 4),
                    
                    Row(
                      children: [
                        if (producto.codigo.isNotEmpty) ...[
                          Chip(
                            label: Text(
                              producto.codigo,
                              style: TextStyle(fontSize: 10),
                            ),
                            padding: EdgeInsets.symmetric(horizontal: 4),
                            visualDensity: VisualDensity.compact,
                          ),
                          SizedBox(width: 6),
                        ],
                        
                        if (producto.categoriaNombre != null)
                          Chip(
                            label: Text(
                              producto.categoriaNombre!,
                              style: TextStyle(fontSize: 10),
                            ),
                            backgroundColor: Colors.blue.shade50,
                            padding: EdgeInsets.symmetric(horizontal: 6),
                            visualDensity: VisualDensity.compact,
                          ),
                      ],
                    ),
                    
                    SizedBox(height: 4),
                    
                    Text(
                      producto.descripcion,
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              
              // Precio y stock
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    producto.precioVentaFormatted,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.green.shade700,
                    ),
                  ),
                  
                  SizedBox(height: 4),
                  
                  Text(
                    producto.stockFormatted,
                    style: TextStyle(
                      fontSize: 12,
                      color: producto.bajoStock ? Colors.red : Colors.grey,
                    ),
                  ),
                  
                  if (producto.bajoStock)
                    Text(
                      'Stock bajo!',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                ],
              ),
              
              SizedBox(width: 8),
              
              // Botón de menú
              IconButton(
                icon: Icon(Icons.more_vert),
                onPressed: onTap,
              ),
            ],
          ),
        ),
      ),
    );
  }
}