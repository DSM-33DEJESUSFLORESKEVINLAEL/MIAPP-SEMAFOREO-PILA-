import 'package:miapp/models/desdet.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:logger/logger.dart';
import 'package:flutter/foundation.dart'; // Agregar esta línea

import 'dart:async';
import '../models/desmstr.dart';
import 'creaciontablas.dart';
import '../models/medida.dart';
import '../models/marca.dart';
import '../models/fallas.dart';
import '../models/marca_renovado.dart';
import '../models/modelo_renovado.dart';
import '../models/rango_carga.dart';
import '../models/tipo_unidad.dart';
import '../models/unidades.dart';
import '../models/empresas.dart';
import '../models/bases.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;
  static final Logger _logger = Logger();
  static final Completer<Database> _dbCompleter = Completer<Database>();

  

  DatabaseHelper._init();

  /// 🔹 Obtiene la instancia de la base de datos
 Future<Database> get database async {
  if (_database != null) return _database!;

  try {
    return await _dbCompleter.future;
  } catch (e) {
    _logger.e("❌ Error obteniendo la base de datos: $e");
    throw Exception("Error al inicializar la base de datos.");
  }
}

  /// 🔹 Inicializa la base de datos
  Future<void> initDB() async {
  try {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'app_database_v6.db');

    final db = await openDatabase(
      path,
      version: 6,
      onCreate: createDB,
      onUpgrade: _upgradeDB,
      readOnly: false, // ✅ Esto está bien

    );

    _database = db;

    // ✅ Verificar que la tabla principal esté creada
    final result = await db.rawQuery("SELECT name FROM sqlite_master WHERE type='table' AND name='accesos_usuarios'");
    if (result.isEmpty) {
      throw Exception("Error: La tabla accesos_usuarios no fue creada correctamente.");
    }

    if (!_dbCompleter.isCompleted) {
      _dbCompleter.complete(db);
    }
  } catch (e) {
    _logger.e("❌ Error al inicializar la base de datos: $e");

    if (!_dbCompleter.isCompleted) {
      _dbCompleter.completeError(e);
    }
  }
}

////---------------------------------------- INSERTAR LOS NUEVOS DATOS ----------------------------------------------
Future<void> insertUsuarioEmpresaBase(Map<String, dynamic> data) async {
  final db = await database;

  bool exists = await checkTableExists('accesos_usuarios');
  if (!exists) {
    _logger.e("⚠️ Error: La tabla accesos_usuarios no existe.");
    return;
  }

  try {
    // Insertar en la tabla accesos_usuarios
    await db.insert(
      'accesos_usuarios',
      {
        'usuario': data['USUARIO'],
        'nombre': data['NOMBREUSUARIO'],
        'psw': data['PSW'],
        'falta': data['FALTA'],
        'fbaja': data['FBAJA'],
        'puesto': data['PUESTO'] ?? '',
        'obs': data['OBS'] ?? '',
        'empresa': data['EMPRESA'],
        'base': data['BASE']
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    // Insertar en la tabla empresas
    await db.insert(
      'empresas',
      {
        'empresa': data['EMPRESA'],
        'nombre': data['NOMBREEMPRESA'],
        'desmontaje_inmediato': data['DESMONTAJE_INMEDIATO'],
        'desmontaje_prox_desde': data['DESMONTAJE_PROX_DESDE'],
        'desmontaje_prox_hasta': data['DESMONTAJE_PROX_HASTA'],
        'buenas_condiciones': data['BUENAS_CONDICIONES']
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    // Insertar en la tabla bases
    await db.insert(
      'bases',
      {
        'empresa': data['EMPRESA'],
        'base': data['BASE'],
        'serie': data['SERIE'],
        'emp_cte': data['EMP_CTE'],
        'cliente': data['CLIENTE'],
        'lugar': data['LUGAR'],
        'grupo': data['GRUPO']
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    _logger.i("✅ Datos insertados correctamente en SQLite en opcion_tablas.");
  } catch (e) {
    _logger.e("❌ Error al insertar datos en SQLite: $e");
  }
}


  /// 🔹 Elimina la base de datos (Forzar reset)
  Future<void> resetDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'app_database_v6.db');
    await deleteDatabase(path);
    _logger.w("🔄 Base de datos eliminada. Se creará nuevamente en la próxima ejecución.");
    await initDB();
  }

  
Future<void> createDB(Database db, int version) async {
  _logger.i("🛠 Creando la base de datos...");
  try {
    await db.execute(tableAccesosUsuarios);
    await db.execute(tableUsers);
    await db.execute(tableEmpresas);
    await Future.delayed(Duration(milliseconds: 50)); // 🧘‍♂️

    await db.execute(tableBases);
    await db.execute(tableAccesosPermisos);
    await db.execute(tableMedida);
    await db.execute(tableMarca);
    await Future.delayed(Duration(milliseconds: 50)); // 🧘‍♂️

    await db.execute(tableFallas);
    await db.execute(tableTipoUnidad);
    await db.execute(tableRangoCarga);
    await db.execute(tableMarcarenovado);
    await Future.delayed(Duration(milliseconds: 50)); // 🧘‍♂️

    await db.execute(tableModelorenovado);
    await db.execute(tableUnidades);
    await db.execute(tableDesMstr);

    await Future.delayed(Duration(milliseconds: 50)); // 🧘‍♂️

    await db.execute(tableDesDet);
    await db.execute(tableSemMstr);
    await db.execute(tableSemDet);
    _logger.i("✅ Base de datos creada correctamente.");
  } catch (e) {
    _logger.e("❌ Error al crear las tablas: $e");
  }
}


  /// 🔹 Actualiza la base de datos si la estructura cambia
  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    _logger.i("🔄 Actualizando base de datos de versión $oldVersion a $newVersion...");
    try {
      if (oldVersion < 6) {
        // Aquí podrías agregar lógica para actualizar la estructura de la BD
        _logger.i("📌 Verificando nuevas estructuras...");
      }
      _logger.i("✅ Base de datos actualizada correctamente.");
    } catch (e) {
      _logger.e("❌ Error al actualizar la base de datos: $e");
    }
  }

  /// 🔹 Verifica si una tabla existe en la base de datos
  Future<bool> checkTableExists(String tableName) async {
    final db = await database;
    final result = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name=?",
        [tableName]);
    return result.isNotEmpty;
  }



Future<void> verificarEstructuraSQLite() async {
  final db = await database;
  final List<Map<String, dynamic>> tables = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table' AND name='desdet'");

  if (tables.isEmpty) {
    debugPrint("🚨 La tabla 'desdet' NO existe en SQLite.");
  } else {
    debugPrint("✅ La tabla 'desdet' existe en SQLite.");
  }
}

  /// 🔹 Métodos de inserción optimizados (Verifica si la tabla existe antes de insertar)
  Future<void> insertMedidas(List<Medida> medidas) async =>
      _insertData('medida', medidas);
  Future<void> insertMarcas(List<Marca> marcas) async =>
      _insertData('marca', marcas);
  Future<void> insertFallas(List<Fallas> fallas) async =>
      _insertData('fallas', fallas);
  Future<void> insertMarcaRenovado(List<MarcaRenovado> marcas) async =>
      _insertData('marca_renovado', marcas);
  Future<void> insertModeloRenovado(List<ModeloRenovado> modelos) async =>
      _insertData('modelo_renovado', modelos);
  Future<void> insertRangoCarga(List<RangoCarga> rangos) async =>
      _insertData('rango_carga', rangos);
  Future<void> insertTipoUnidad(List<TipoUnidad> tipos) async =>
      _insertData('tipo_unidad', tipos);
  Future<void> insertUnidades(List<Unidad> unidades) async =>
      _insertData('unidades', unidades);
  Future<void> insertEmpresa(List<Empresa> empresas) async =>
      _insertData('empresas', empresas);
  Future<void> insertBase(List<Base> bases) async => _insertData('bases', bases);
  Future<void> insertDesMstr(List<DesMstr> desmstr) async => _insertData('desmstr', desmstr);
  // Future<void> insertDesDet(List<DesDet> desdet) async => _insertData('desdet', desdet); 
Future<void> insertDesDet(List<DesDet> lista) async {
  final db = await database;

  for (var item in lista) {
    final existing = await db.query(
      'desdet',
      where: 'folio = ? AND reg = ?',
      whereArgs: [item.folio, item.reg],
      limit: 1,
    );

    if (existing.isEmpty) {
      await db.insert(
        'desdet',
        item.toMap()..['sincronizado'] = 1,
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    } else {
      final existingSync = existing.first['sincronizado'] ?? 0;

      // Solo actualiza si el local no está sincronizado
      if (existingSync == 0) {
        await db.update(
          'desdet',
          item.toMap()..['sincronizado'] = 1,
          where: 'folio = ? AND reg = ?',
          whereArgs: [item.folio, item.reg],
        );
      } else {
        debugPrint("⏩ Registro ya sincronizado localmente: ${item.folio}-${item.reg}, se conserva sin sobrescribir.");
      }
    }
  }
}

  
      

  /// 🔹 Método genérico para insertar datos con verificación de existencia de tabla
  Future<void> _insertData(String tableName, List<dynamic> items) async {
    final db = await database;

    bool exists = await checkTableExists(tableName);
    if (!exists) {
      _logger.e("⚠️ Intento de insertar en '$tableName', pero la tabla no existe.");
      return;
    }

    for (var item in items) {
      try {
        await db.insert(
          tableName,
          item.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      } catch (e) {
        _logger.e("❌ Error al insertar en $tableName: $e");
      }
    }
  }


Future<List<DesDet>> getDesDetxFolio(String folio) async {
  final db = await database;
  final List<Map<String, dynamic>> maps = await db.query(
    'desdet',
    where: 'folio = ?',
    whereArgs: [folio],
  );
  return maps.map((map) => DesDet.fromMap(map)).toList();
}


// GUARDAR LOS DATOS DE DESDET SIN INTERNET
Future<void> guardarPilaLocalmente(Map<String, dynamic> data) async {
  final db = await database;
  await db.insert('desdet', data, conflictAlgorithm: ConflictAlgorithm.replace);
}

Future<int> insert(String table, Map<String, dynamic> data) async {
  final db = await database;
  // Verificar si el registro ya existe
  final existing = await db.query(table, where: "FOLIO = ?", whereArgs: [data["FOLIO"]]);

  if (existing.isNotEmpty) {
    _logger.w("⚠️ El registro con FOLIO ${data['FOLIO']} ya existe en $table. No se insertará.");
    return -1;
  }
  _logger.i("📌 Insertando en $table: $data");
  int id = await db.insert(table, data, conflictAlgorithm: ConflictAlgorithm.replace);
  if (id > 0) {
    _logger.i("✅ Registro insertado correctamente en $table con ID: $id");
  } else {
    _logger.e("❌ Falló el INSERT en $table.");
  }
  return id;
}


/// REGISTRO DE DATOS DE LA TABLA SIN INTERNET DE DESDET
Future<void> verificarRegistrosDesdet() async {
  final db = await DatabaseHelper.instance.database;
  final registros = await db.query('desdet'); // Selecciona TODO
  print("📌 Total de registros en 'desdet': ${registros.length}");

  for (var r in registros) {
    print("📝 Registro piladesecho_mtr: $r");
  }
}
Future<List<Map<String, dynamic>>> getAllDesDet() async {
  final db = await database;
  final List<Map<String, dynamic>> result = await db.query('desdet');
  
  _logger.i("📌 Registros obtenidos de SQLite (desdet): ${result.length}");
  return result;
}


Future<int> getNextReg(String folio, String empresa, String base) async {
  final db = await database;
  final result = await db.rawQuery(
    'SELECT MAX(REG) + 1 as nextReg FROM sem_det WHERE FOLIO = ? AND EMPRESA = ? AND BASE = ?',
    [folio, empresa, base],
  );
  return result.first["nextReg"] == null ? 1 : result.first["nextReg"] as int;
}


Future<int> update(String table, Map<String, dynamic> values, String whereClause, List<dynamic> whereArgs) async {
  final db = await database;
  try {
    return await db.update(table, values, where: whereClause, whereArgs: whereArgs);
  } catch (e) {
    debugPrint("⛔ ❌ Error al actualizar en $table: $e");
    return 0;
  }
}





//  puedes cerrarla manualmente al salir de la app
  Future<void> closeDB() async {
  final db = _database;
  if (db != null) {
    await db.close();
    _database = null;
    _logger.i("🛑 Base de datos cerrada correctamente.");
  }
}

}
