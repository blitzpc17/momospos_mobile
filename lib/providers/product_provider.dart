import 'package:flutter/material.dart';

import '../models/models.dart';
import '../services/database_service.dart';

class ProductProvider with ChangeNotifier {
  List<Product> _productos = [];
  List<Categoria> _categorias = [];
  DatabaseService _dbService = DatabaseService();
  bool _isLoading = false;

  List<Product> get productos => _productos;
  List<Categoria> get categorias => _categorias;
  bool get isLoading => _isLoading;

  Future<void> loadProductos() async {
    _isLoading = true;
    notifyListeners();

    try {
      final db = await _dbService.database;
      
      // Cargar productos con información de categoría
      final productosList = await db.rawQuery('''
        SELECT p.*, c.nombre as categoria_nombre, c.color as categoria_color
        FROM productos p
        LEFT JOIN categorias c ON p.id_categoria = c.id
        WHERE p.activo = 1
        ORDER BY p.nombre
      ''');
      
      _productos = productosList.map((map) => Product.fromMap(map)).toList();
      
      // Cargar categorías
      final categoriasList = await db.rawQuery('''
        SELECT * FROM categorias 
        WHERE activo = 1 
        ORDER BY orden, nombre
      ''');
      
      _categorias = categoriasList.map((map) => Categoria.fromMap(map)).toList();
      
    } catch (e) {
      print('Error cargando productos: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<int> addProducto(Product producto) async {
    try {
      final db = await _dbService.database;
      producto.id = await db.insert('productos', producto.toMap());
      _productos.add(producto);
      notifyListeners();
      return producto.id!;
    } catch (e) {
      print('Error agregando producto: $e');
      return 0;
    }
  }

  Future<bool> updateProducto(Product producto) async {
    try {
      final db = await _dbService.database;
      await db.update(
        'productos',
        producto.toMap(),
        where: 'id = ?',
        whereArgs: [producto.id],
      );
      
      final index = _productos.indexWhere((p) => p.id == producto.id);
      if (index != -1) {
        _productos[index] = producto;
      }
      
      notifyListeners();
      return true;
    } catch (e) {
      print('Error actualizando producto: $e');
      return false;
    }
  }

  Future<bool> deleteProducto(int id) async {
    try {
      final db = await _dbService.database;
      await db.update(
        'productos',
        {'activo': 0},
        where: 'id = ?',
        whereArgs: [id],
      );
      
      _productos.removeWhere((p) => p.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      print('Error eliminando producto: $e');
      return false;
    }
  }

  Future<int> addCategoria(Categoria categoria) async {
    try {
      final db = await _dbService.database;
      categoria.id = await db.insert('categorias', categoria.toMap());
      _categorias.add(categoria);
      notifyListeners();
      return categoria.id!;
    } catch (e) {
      print('Error agregando categoría: $e');
      return 0;
    }
  }

  Product? getProductoByCodigo(String codigo) {
    try {
      return _productos.firstWhere(
        (producto) => producto.codigo == codigo && producto.activo && producto.stock > 0,
      );
    } catch (e) {
      return null;
    }
  }

  List<Product> searchProductos(String query) {
    if (query.isEmpty) return _productos;
    
    final lowercaseQuery = query.toLowerCase();
    return _productos.where((producto) {
      return producto.nombre.toLowerCase().contains(lowercaseQuery) ||
             producto.codigo.toLowerCase().contains(lowercaseQuery) ||
             (producto.descripcion?.toLowerCase().contains(lowercaseQuery) ?? false);
    }).toList();
  }

  Categoria? getCategoriaById(int id) {
    try {
      return _categorias.firstWhere((categoria) => categoria.id == id);
    } catch (e) {
      return null;
    }
  }
}