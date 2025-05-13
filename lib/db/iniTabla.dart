import 'package:miapp/db/opciontablas.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'creaciontablas.dart'; // Importar las definiciones de tablas
import 'package:logger/logger.dart';

final Logger logger = Logger(); // 📌 Logger para mejor depuración

class DBHelper {
  static Database? _database;
      static final Logger logger = Logger();


  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  // Future<void> resetDatabase() async {
  //   // String path = join(await getDatabasesPath(), 'app_database.db');
  //   String path = join(await getDatabasesPath(), 'app_database_v6.db');
  //   await deleteDatabase(path);
  //   logger.i("🗑️ Base de datos eliminada. Se creará de nuevo al iniciar la app.");
  //   _database = null; // Asegura que se vuelva a inicializar
  // }

  /// 🔹 Elimina la base de datos (Forzar reset)
Future<void> resetDatabase() async {
  try {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'app_database_v6.db');
    await deleteDatabase(path);
    logger.w("🔄 Base de datos eliminada.");
  } catch (e, s) {
    logger.e("❌ Error eliminando la base: $e\n$s");
    rethrow;
  }
}



  Future<Database> _initDB() async {
    // String path = join(await getDatabasesPath(), 'app_database.db');
        String path = join(await getDatabasesPath(), 'app_database_v6.db');

    return await openDatabase(
      path,
      version: 2, // 📌 Incrementa la versión si es necesario
      onCreate: (db, version) async {
        await _createTables(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await _createTables(db);
        }
      },
    );
  }

  Future<void> _createTables(Database db) async {
    List<String> createdTables = [];

    // Ejecutar las consultas de creación de tablas y registrar cuáles se crearon
    await db.execute(tableUsers);
    createdTables.add("tableUsers");

    await db.execute(tableEmpresas);
    createdTables.add("tableEmpresas");

    await db.execute(tableBases);
    createdTables.add("tableBases");

    await db.execute(tableMedida);
    createdTables.add("tableMedida");

    await db.execute(tableMarca);
    createdTables.add("tableMarca");

    await db.execute(tableFallas);
    createdTables.add("tableFallas");

    await db.execute(tableTipoUnidad);
    createdTables.add("tableTipoUnidad");

    await db.execute(tableRangoCarga);
    createdTables.add("tableRangoCarga");

    await db.execute(tableAccesosPermisos);
    createdTables.add("tableAccesosPermisos");

    await db.execute(tableMarcarenovado);
    createdTables.add("tableMarcarenovado");

    await db.execute(tableModelorenovado);
    createdTables.add("tableModelorenovado");

    await db.execute(tableUnidades);
    createdTables.add("tableUnidades");

    await db.execute(tableAccesosUsuarios);
    createdTables.add("tableAccesosUsuarios");

    await db.execute(tableSemMstr);
    createdTables.add("tableSemMstr");

    await db.execute(tableSemDet);
    createdTables.add("tableSemDet");

    await db.execute(tableDesMstr);
    createdTables.add("tableDesMstr");

    await db.execute(tableDesDet);
    createdTables.add("tableDesDet");

    // Mostrar el mensaje con las tablas creadas
    String tablesCreatedMessage = "✅ Tablas creadas: ${createdTables.join(', ')}";
    logger.i(tablesCreatedMessage);
    logger.i(tablesCreatedMessage);
  }
}
