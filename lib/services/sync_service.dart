import '../db/opciontablas.dart';
import '../db/creaciontablas.dart';
import 'package:logger/logger.dart';

class SyncService {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  final Logger _logger = Logger(); // 📌 Logger para mejor depuración

  
  /// 🏗 **Crear todas las tablas necesarias en SQLite**
  Future<void> createTables() async {
    try {
      final db = await _dbHelper.database;

      await db.execute(tableUsers);
      await db.execute(tableEmpresas);
      await db.execute(tableBases);
      await db.execute(tableMedida);
      await db.execute(tableMarca);
      await db.execute(tableFallas);
      await db.execute(tableTipoUnidad);
      await db.execute(tableRangoCarga);
      await db.execute(tableAccesosPermisos);
      await db.execute(tableMarcarenovado);
      await db.execute(tableModelorenovado);
      await db.execute(tableUnidades);
      await db.execute(tableAccesosUsuarios);
      await db.execute(tableSemMstr);
      await db.execute(tableSemDet);
      await db.execute(tableDesMstr);
      await db.execute(tableDesDet);

      _logger.i("✅ Todas las tablas han sido creadas exitosamente.");
    } catch (e) {
      _logger.e("🚨 Error al crear tablas: $e");
    }
  }

  /// 🔄 **Almacenar los datos en SQLite**
  Future<void> storeData(Map<String, dynamic> jsonData) async {
    final db = await _dbHelper.database;
    final batch = db.batch();

    try {

      // 📌 Ejecutar las inserciones en batch
      await batch.commit(noResult: true);
      _logger.i("✅ Datos insertados correctamente en SQLite en sync_service.");
    } catch (e) {
      _logger.e("🚨 Error al insertar datos en SQLite: $e");
    }
  }
}
