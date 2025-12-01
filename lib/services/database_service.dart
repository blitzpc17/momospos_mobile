import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:io';

import '../models/models.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  static Database? _database;
  bool _isInitialized = false;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'momos_pos.db');
    
    // Verificar si la base de datos ya existe usando File
    bool databaseExists = await File(path).exists();
    
    if (!databaseExists) {
      // Si no existe, crear desde cero
      print('🆕 Creando base de datos por primera vez...');
      await _createNewDatabase(path);
    } else {
      // Si existe, solo abrir
      _database = await openDatabase(path);
      print('✅ Base de datos cargada exitosamente');
    }
    
    return _database!;
  }

  Future<void> _createNewDatabase(String path) async {
    // Crear la base de datos
    _database = await openDatabase(
      path,
      version: 1,
      onCreate: _createTables,
      onOpen: (db) async {
        print('📊 Insertando datos iniciales...');
        await _insertInitialData(db);
        _isInitialized = true;
        print('🎉 Base de datos inicializada completamente');
      },
    );
  }

  Future<void> _createTables(Database db, int version) async {
    print('🗂️ Creando tablas...');
    
    // Tabla de Variables Globales
    await db.execute('''
      CREATE TABLE variables_globales (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre VARCHAR(100) NOT NULL UNIQUE,
        valor TEXT,
        descripcion TEXT,
        fecha_actualizacion DATETIME DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    // Tabla de Roles
    await db.execute('''
      CREATE TABLE roles (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre VARCHAR(50) NOT NULL UNIQUE,
        descripcion TEXT,
        nivel_acceso INTEGER DEFAULT 1,
        activo BOOLEAN DEFAULT 1,
        fecha_creacion DATETIME DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    // Tabla de Módulos del Sistema
    await db.execute('''
      CREATE TABLE modulos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre VARCHAR(50) NOT NULL UNIQUE,
        icono VARCHAR(50),
        ruta VARCHAR(100),
        seccion VARCHAR(50),
        orden INTEGER DEFAULT 0,
        activo BOOLEAN DEFAULT 1
      )
    ''');

    // Tabla de Permisos por Rol
    await db.execute('''
      CREATE TABLE permisos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        id_rol INTEGER NOT NULL,
        id_modulo INTEGER NOT NULL,
        puede_ver BOOLEAN DEFAULT 0,
        puede_crear BOOLEAN DEFAULT 0,
        puede_editar BOOLEAN DEFAULT 0,
        puede_eliminar BOOLEAN DEFAULT 0,
        FOREIGN KEY (id_rol) REFERENCES roles(id) ON DELETE CASCADE,
        FOREIGN KEY (id_modulo) REFERENCES modulos(id) ON DELETE CASCADE,
        UNIQUE(id_rol, id_modulo)
      )
    ''');

    // Tabla de Usuarios
    await db.execute('''
      CREATE TABLE usuarios (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username VARCHAR(50) UNIQUE NOT NULL,
        password_hash VARCHAR(255) NOT NULL,
        nombre VARCHAR(100) NOT NULL,
        id_rol INTEGER NOT NULL DEFAULT 1,
        activo BOOLEAN DEFAULT 1,
        fecha_creacion DATETIME DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (id_rol) REFERENCES roles(id)
      )
    ''');

    // Tabla de Categorías
    await db.execute('''
      CREATE TABLE categorias (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre VARCHAR(50) NOT NULL,
        color VARCHAR(10),
        imagen_url TEXT,
        orden INTEGER DEFAULT 0,
        activo BOOLEAN DEFAULT 1
      )
    ''');

    // Tabla de Productos
    await db.execute('''
      CREATE TABLE productos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        codigo VARCHAR(50) UNIQUE,
        nombre VARCHAR(100) NOT NULL,
        descripcion TEXT,
        id_categoria INTEGER NOT NULL,
        precio_compra DECIMAL(8,2) DEFAULT 0,
        precio_venta DECIMAL(8,2) NOT NULL,
        stock DECIMAL(8,2) DEFAULT 0,
        stock_minimo DECIMAL(8,2) DEFAULT 0,
        unidad_medida VARCHAR(20) DEFAULT 'pieza',
        aplica_iva BOOLEAN DEFAULT 1,
        imagen_url TEXT,
        imagenes TEXT,
        activo BOOLEAN DEFAULT 1,
        fecha_creacion DATETIME DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (id_categoria) REFERENCES categorias(id)
      )
    ''');

    // Tabla de Clientes
    await db.execute('''
      CREATE TABLE clientes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre VARCHAR(100) NOT NULL,
        telefono VARCHAR(20),
        email VARCHAR(100),
        direccion TEXT,
        frecuente BOOLEAN DEFAULT 0,
        notas TEXT,
        fecha_registro DATETIME DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    // Tabla de Cajas
    await db.execute('''
      CREATE TABLE cajas (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        id_usuario INTEGER NOT NULL,
        fecha_apertura DATETIME DEFAULT CURRENT_TIMESTAMP,
        fecha_cierre DATETIME,
        monto_inicial DECIMAL(10,2) NOT NULL DEFAULT 0,
        monto_final DECIMAL(10,2),
        estado VARCHAR(20) DEFAULT 'abierta',
        observaciones TEXT,
        FOREIGN KEY (id_usuario) REFERENCES usuarios(id)
      )
    ''');

    // Tabla de Ventas
    await db.execute('''
      CREATE TABLE ventas (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        folio VARCHAR(20) UNIQUE,
        id_caja INTEGER NOT NULL,
        id_usuario INTEGER NOT NULL,
        id_cliente INTEGER,
        fecha_venta DATETIME DEFAULT CURRENT_TIMESTAMP,
        subtotal DECIMAL(10,2) DEFAULT 0,
        descuento DECIMAL(10,2) DEFAULT 0,
        iva DECIMAL(10,2) DEFAULT 0,
        total DECIMAL(10,2) DEFAULT 0,
        metodo_pago VARCHAR(20) DEFAULT 'efectivo',
        estado VARCHAR(20) DEFAULT 'completada',
        observaciones TEXT,
        FOREIGN KEY (id_caja) REFERENCES cajas(id),
        FOREIGN KEY (id_usuario) REFERENCES usuarios(id),
        FOREIGN KEY (id_cliente) REFERENCES clientes(id)
      )
    ''');

    // Tabla de Detalles de Venta
    await db.execute('''
      CREATE TABLE venta_detalles (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        id_venta INTEGER NOT NULL,
        id_producto INTEGER NOT NULL,
        cantidad DECIMAL(8,3) NOT NULL,
        precio_unitario DECIMAL(8,2) NOT NULL,
        descuento DECIMAL(8,2) DEFAULT 0,
        total DECIMAL(8,2) NOT NULL,
        baja BOOLEAN DEFAULT 0,
        fecha_agregado DATETIME DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (id_venta) REFERENCES ventas(id) ON DELETE CASCADE,
        FOREIGN KEY (id_producto) REFERENCES productos(id)
      )
    ''');

    // Tabla de Movimientos de Caja
    await db.execute('''
      CREATE TABLE movimientos_caja (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        id_caja INTEGER NOT NULL,
        id_usuario INTEGER NOT NULL,
        tipo_movimiento VARCHAR(20) NOT NULL,
        concepto VARCHAR(100) NOT NULL,
        descripcion TEXT,
        monto DECIMAL(10,2) NOT NULL,
        metodo_pago VARCHAR(20) DEFAULT 'efectivo',
        referencia VARCHAR(50),
        id_relacion INTEGER,
        fecha_movimiento DATETIME DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (id_caja) REFERENCES cajas(id),
        FOREIGN KEY (id_usuario) REFERENCES usuarios(id)
      )
    ''');

    print('✅ Todas las tablas creadas exitosamente');
  }

  Future<void> _insertInitialData(Database db) async {
    print('📥 Insertando datos iniciales...');

    // Insertar configuraciones
    await db.insert('variables_globales', {
      'nombre': 'nombre_tienda',
      'valor': "MOMO'S POS",
      'descripcion': 'Nombre del establecimiento'
    });
    
    await db.insert('variables_globales', {
      'nombre': 'direccion_tienda',
      'valor': 'Calle Principal #123',
      'descripcion': 'Dirección completa'
    });
    
    await db.insert('variables_globales', {
      'nombre': 'telefono_tienda',
      'valor': '555-1234',
      'descripcion': 'Teléfono de contacto'
    });
    
    await db.insert('variables_globales', {
      'nombre': 'iva_porcentaje',
      'valor': '0.16',
      'descripcion': 'Porcentaje de IVA aplicable'
    });

    // Insertar roles
    await db.insert('roles', {
      'nombre': 'Administrador',
      'descripcion': 'Acceso completo al sistema',
      'nivel_acceso': 3
    });
    
    await db.insert('roles', {
      'nombre': 'Supervisor',
      'descripcion': 'Puede ver reportes y gestionar ventas',
      'nivel_acceso': 2
    });
    
    await db.insert('roles', {
      'nombre': 'Cajero',
      'descripcion': 'Solo puede realizar ventas',
      'nivel_acceso': 1
    });

    // Insertar módulos
    final modulos = [
      {'nombre': 'Inicio', 'icono': 'dashboard', 'ruta': '/dashboard', 'seccion': 'operaciones', 'orden': 1},
      {'nombre': 'Nueva Venta', 'icono': 'shopping_cart', 'ruta': '/ventas', 'seccion': 'operaciones', 'orden': 2},
      {'nombre': 'Movimientos Caja', 'icono': 'account_balance_wallet', 'ruta': '/caja', 'seccion': 'operaciones', 'orden': 3},
      {'nombre': 'Productos', 'icono': 'inventory_2', 'ruta': '/productos', 'seccion': 'catalogos', 'orden': 1},
      {'nombre': 'Clientes', 'icono': 'people', 'ruta': '/clientes', 'seccion': 'catalogos', 'orden': 2},
      {'nombre': 'Proveedores', 'icono': 'local_shipping', 'ruta': '/proveedores', 'seccion': 'catalogos', 'orden': 3},
      {'nombre': 'Reportes de Ventas', 'icono': 'analytics', 'ruta': '/reportes', 'seccion': 'reportes', 'orden': 1},
      {'nombre': 'Compras', 'icono': 'shopping_basket', 'ruta': '/compras', 'seccion': 'reportes', 'orden': 2},
      {'nombre': 'Usuarios', 'icono': 'manage_accounts', 'ruta': '/usuarios', 'seccion': 'configuracion', 'orden': 1},
      {'nombre': 'Configuración', 'icono': 'settings', 'ruta': '/configuracion', 'seccion': 'configuracion', 'orden': 2},
    ];

    for (var modulo in modulos) {
      await db.insert('modulos', modulo);
    }

    // Insertar permisos para Administrador (acceso completo a todos los módulos)
    final modulosResult = await db.query('modulos');
    for (var modulo in modulosResult) {
      await db.insert('permisos', {
        'id_rol': 1,
        'id_modulo': modulo['id'],
        'puede_ver': 1,
        'puede_crear': 1,
        'puede_editar': 1,
        'puede_eliminar': 1,
      });
    }

    // Insertar usuarios iniciales
    await db.insert('usuarios', {
      'username': 'admin',
      'password_hash': 'admin123',
      'nombre': 'Administrador Principal',
      'id_rol': 1
    });
    
    await db.insert('usuarios', {
      'username': 'supervisor',
      'password_hash': 'super123',
      'nombre': 'María González - Supervisor',
      'id_rol': 2
    });
    
    await db.insert('usuarios', {
      'username': 'cajero',
      'password_hash': 'cajero123',
      'nombre': 'Juan Pérez - Cajero',
      'id_rol': 3
    });

    // Insertar categorías
    final categorias = [
      {'nombre': 'Abarrotes', 'color': '#FF9800', 'orden': 1},
      {'nombre': 'Bebidas', 'color': '#2196F3', 'orden': 2},
      {'nombre': 'Lácteos', 'color': '#FFEB3B', 'orden': 3},
      {'nombre': 'Limpieza', 'color': '#4CAF50', 'orden': 4},
      {'nombre': 'Verdulería', 'color': '#8BC34A', 'orden': 5},
    ];

    for (var categoria in categorias) {
      await db.insert('categorias', categoria);
    }

    // Crear triggers
    await _createTriggers(db);

    print('✅ Datos iniciales insertados exitosamente');
  }

  Future<void> _createTriggers(Database db) async {
    // Trigger para generar folio de venta
    await db.execute('''
      CREATE TRIGGER IF NOT EXISTS generar_folio_venta
      AFTER INSERT ON ventas
      FOR EACH ROW
      WHEN NEW.folio IS NULL
      BEGIN
        UPDATE ventas SET folio = 'VTA-' || strftime('%Y%m%d') || '-' || substr('0000' || NEW.id, -4, 4) 
        WHERE id = NEW.id;
      END;
    ''');

    // Trigger para actualizar stock en ventas
    await db.execute('''
      CREATE TRIGGER IF NOT EXISTS actualizar_stock_venta
      AFTER INSERT ON venta_detalles
      FOR EACH ROW
      BEGIN
        UPDATE productos SET stock = stock - NEW.cantidad WHERE id = NEW.id_producto;
      END;
    ''');

    print('✅ Triggers creados exitosamente');
  }

  // Método para autenticar usuario
  Future<User?> authenticateUser(String username, String password) async {
    final db = await database;
    try {
      final result = await db.rawQuery('''
        SELECT u.*, r.nombre as rol_nombre 
        FROM usuarios u 
        LEFT JOIN roles r ON u.id_rol = r.id 
        WHERE u.username = ? AND u.password_hash = ? AND u.activo = 1
      ''', [username, password]);
      
      if (result.isNotEmpty) {
        return User.fromMap(result.first);
      }
      return null;
    } catch (e) {
      print('Error en authenticateUser: $e');
      return null;
    }
  }

  // Método para obtener todos los usuarios
  Future<List<User>> getUsers() async {
    final db = await database;
    try {
      final result = await db.rawQuery('''
        SELECT u.*, r.nombre as rol_nombre 
        FROM usuarios u 
        LEFT JOIN roles r ON u.id_rol = r.id 
        ORDER BY u.fecha_creacion DESC
      ''');
      
      return result.map((map) => User.fromMap(map)).toList();
    } catch (e) {
      print('Error en getUsers: $e');
      return [];
    }
  }

  // Método para obtener todos los roles
  Future<List<Role>> getRoles() async {
    final db = await database;
    try {
      final result = await db.rawQuery('SELECT * FROM roles ORDER BY nivel_acceso DESC');
      return result.map((map) => Role.fromMap(map)).toList();
    } catch (e) {
      print('Error en getRoles: $e');
      return [];
    }
  }

  // Método para crear usuario
  Future<int> createUser(User user) async {
    final db = await database;
    try {
      return await db.insert('usuarios', user.toMap());
    } catch (e) {
      print('Error en createUser: $e');
      return 0;
    }
  }

  // Método para actualizar usuario
  Future<int> updateUser(User user) async {
    final db = await database;
    try {
      return await db.update(
        'usuarios',
        user.toMap(),
        where: 'id = ?',
        whereArgs: [user.id],
      );
    } catch (e) {
      print('Error en updateUser: $e');
      return 0;
    }
  }

  // Método para verificar si la base de datos está inicializada
  Future<bool> isDatabaseInitialized() async {
    try {
      final db = await database;
      final result = await db.rawQuery('SELECT COUNT(*) as count FROM usuarios');
      return true;
    } catch (e) {
      return false;
    }
  }

  // Método para reiniciar la base de datos (útil para desarrollo)
  Future<void> resetDatabase() async {
    try {
      final db = await database;
      await db.close();
      String path = join(await getDatabasesPath(), 'momos_pos.db');
      await deleteDatabase(path);
      _database = null;
      _isInitialized = false;
      await database; // Esto recreará la base de datos
    } catch (e) {
      print('Error en resetDatabase: $e');
    }
  }

  // Métodos para Roles

Future<int> createRole(Role role) async {
  final db = await database;
  try {
    return await db.insert('roles', role.toMap());
  } catch (e) {
    print('Error en createRole: $e');
    return 0;
  }
}

Future<int> updateRole(Role role) async {
  final db = await database;
  try {
    return await db.update(
      'roles',
      role.toMap(),
      where: 'id = ?',
      whereArgs: [role.id],
    );
  } catch (e) {
    print('Error en updateRole: $e');
    return 0;
  }
}

Future<int> deleteRole(int id) async {
  final db = await database;
  try {
    return await db.delete(
      'roles',
      where: 'id = ?',
      whereArgs: [id],
    );
  } catch (e) {
    print('Error en deleteRole: $e');
    return 0;
  }
}

// Métodos para Módulos
Future<List<Module>> getModules() async {
  final db = await database;
  try {
    final result = await db.rawQuery('SELECT * FROM modulos ORDER BY seccion, orden');
    return result.map((map) => Module.fromMap(map)).toList();
  } catch (e) {
    print('Error en getModules: $e');
    return [];
  }
}

// Métodos para Permisos
Future<List<Permission>> getPermissionsByRole(int roleId) async {
  final db = await database;
  try {
    final result = await db.rawQuery('''
      SELECT p.*, r.nombre as rol_nombre, m.nombre as modulo_nombre 
      FROM permisos p 
      LEFT JOIN roles r ON p.id_rol = r.id 
      LEFT JOIN modulos m ON p.id_modulo = m.id 
      WHERE p.id_rol = ?
      ORDER BY m.seccion, m.orden
    ''', [roleId]);
    
    return result.map((map) => Permission.fromMap(map)).toList();
  } catch (e) {
    print('Error en getPermissionsByRole: $e');
    return [];
  }
}

Future<int> updatePermission(Permission permission) async {
  final db = await database;
  try {
    return await db.update(
      'permisos',
      permission.toMap(),
      where: 'id = ?',
      whereArgs: [permission.id],
    );
  } catch (e) {
    print('Error en updatePermission: $e');
    return 0;
  }
}





}