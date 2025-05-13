import 'package:sqflite/sqflite.dart';

import 'opciontablas.dart';
import '../models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logger/logger.dart';
import 'package:flutter/foundation.dart'; // ✅ Necesario para usar debugPrint()

class DBOperations {
  static final DBOperations instance = DBOperations._init();
  static final Logger logger = Logger();
  String? _currentUser;

  DBOperations._init();

  /// 🔹 **Autenticación de Usuario**
  Future<User?> getUser(String username, String password) async {
    try {
      final db = await DatabaseHelper.instance.database;
      List<Map<String, dynamic>> result = await db.query(
        'users',
        where: 'username = ? AND password = ?',
        whereArgs: [username, password],
      );

      if (result.isNotEmpty) return User.fromMap(result.first);
    } catch (e) {
      logger.e("❌ Error al obtener usuario: $e");
    }
    return null;
  }

  Future<List<User>> getAllUsers() async {
    try {
      final db = await DatabaseHelper.instance.database;
      final List<Map<String, dynamic>> result = await db.query('users');
      return result.map((map) => User.fromMap(map)).toList();
    } catch (e) {
      logger.e("❌ Error al obtener usuarios: $e");
      return [];
    }
  }

  /// 🔹 **Guardar usuario autenticado en `SharedPreferences`**
  Future<void> setAuthenticatedUser(String username) async {
    try {
      _currentUser = username;
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('authenticated_user', username);
    } catch (e) {
      logger.e("❌ Error al guardar usuario autenticado: $e");
    }
  }

  /// 🔹 **Obtener usuario autenticado**
  Future<String?> getAuthenticatedUser() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      _currentUser = prefs.getString('authenticated_user');
      return _currentUser;
    } catch (e) {
      logger.e("❌ Error al obtener usuario autenticado: $e");
      return null;
    }
  }

  /// 🔹 **Insertar datos en una tabla**
  Future<int> insert(String table, Map<String, dynamic> data) async {
    try {
      final db = await DatabaseHelper.instance.database;
      return await db.insert(table, data);
    } catch (e) {
      logger.e("❌ Error al insertar en $table: $e");
      return -1;
    }
  }

  Future<int> insertUser(User user) async {
    return await insert('users', user.toMap());
  }

  /// 🔹 **Obtener accesos del usuario autenticado**
  Future<List<Map<String, dynamic>>> getAccesosForCurrentUser() async {
    try {
      final db = await DatabaseHelper.instance.database;
      if (_currentUser == null) return [];

      return await db.query('accesos_usuarios',
          where: 'usuario = ?', whereArgs: [_currentUser]);
    } catch (e) {
      logger.e("❌ Error al obtener accesos: $e");
      return [];
    }
  }

  /// 🔹 **Obtener bases de la empresa del usuario autenticado**
  Future<List<Map<String, dynamic>>> getBasesForCurrentUser() async {
    try {
      final db = await DatabaseHelper.instance.database;
      if (_currentUser == null) return [];

      List<Map<String, dynamic>> userAccesos = await getAccesosForCurrentUser();
      if (userAccesos.isEmpty) return [];

      int empresa = int.tryParse(userAccesos.first['empresa'].toString()) ?? 0;
      String base = userAccesos.first['base'];

      return await db.query('bases',
          where: 'empresa = ? AND base = ?', whereArgs: [empresa, base]);
    } catch (e) {
      logger.e("❌ Error al obtener bases: $e");
      return [];
    }
  }

  /// 🔹 **Obtener `sem_mstr` del usuario autenticado**
  Future<List<Map<String, dynamic>>> getSemMstrForCurrentUser() async {
    try {
      final db = await DatabaseHelper.instance.database;
      if (_currentUser == null) return [];

      List<Map<String, dynamic>> userAccesos = await getAccesosForCurrentUser();
      if (userAccesos.isEmpty) return [];

      int empresa = int.tryParse(userAccesos.first['empresa'].toString()) ?? 0;
      String base = userAccesos.first['base'];

      return await db.query('sem_mstr',
          where: 'empresa = ? AND base = ?', whereArgs: [empresa, base]);
    } catch (e) {
      logger.e("❌ Error al obtener sem_mstr: $e");
      return [];
    }
  }

  /// 🔹 **Obtener todas las filas de una tabla**
  Future<List<Map<String, dynamic>>> queryAllRows(String table) async {
    try {
      final db = await DatabaseHelper.instance.database;
      return await db.query(table);
    } catch (e) {
      logger.e("❌ Error al obtener datos de $table: $e");
      return [];
    }
  }

  /// 🔹 **Eliminar un registro por ID (ahora acepta `int` o `String`)**
  Future<int> delete(String table, String columnId, dynamic id) async {
    try {
      final db = await DatabaseHelper.instance.database;
      return await db.delete(table, where: '$columnId = ?', whereArgs: [id]);
    } catch (e) {
      logger.e("❌ Error al eliminar en $table: $e");
      return -1;
    }
  }

  Future<int> updateByWhere(
    String table,
    Map<String, dynamic> values, {
    required String where,
    required List<Object?> whereArgs,
  }) async {
    final db = await DatabaseHelper.instance.database;
    return await db.update(
      table,
      values,
      where: where,
      whereArgs: whereArgs,
    );
  }

  Future<int> update(
    String table,
    Map<String, dynamic> values,
    String whereClause,
    List<dynamic> whereArgs,
  ) async {
    final db = await DatabaseHelper.instance.database; // ✅ solución #1

    try {
      return await db.update(
        table,
        values,
        where: whereClause,
        whereArgs: whereArgs,
      );
    } catch (e) {
      debugPrint("⛔ ❌ Error al actualizar en $table: $e"); // ✅ ya no dará error
      return 0;
    }
  }



Future<int> getSiguienteRegParaFolio(String folio, {DatabaseExecutor? txn}) async {
  final db = txn ?? await DatabaseHelper.instance.database;

  final result = await db.rawQuery(
    'SELECT MAX(REG) + 1 as siguiente FROM desdet WHERE FOLIO = ?',
    [folio],
  );

  // Si no hay registros previos, iniciar en 1
  final siguiente = result.first['siguiente'];
  return (siguiente is int && siguiente > 0) ? siguiente : 1;
}


Future<bool> exists(String table, {required String where, required List whereArgs}) async {
   final db = await DatabaseHelper.instance.database; 
  final result = await db.query(
    table,
    where: where,
    whereArgs: whereArgs,
    limit: 1,
  );
  return result.isNotEmpty;
}


Future<List<Map<String, dynamic>>> queryWhere(
  String table, {
  required String where,
  required List<dynamic> whereArgs,
}) async {
    final db = await DatabaseHelper.instance.database;
  return await db.query(table, where: where, whereArgs: whereArgs);
}



// Future<void> insertOrUpdate(String table, Map<String, dynamic> data,
//     {ConflictAlgorithm conflictAlgorithm = ConflictAlgorithm.replace}) async {
//   // final db = await database;
//   final db = await DatabaseHelper.instance.database;
//   await db.insert(
//     table,
//     data,
//     conflictAlgorithm: conflictAlgorithm,
//   );
// }

Future<void> insertOrUpdate(String table, Map<String, dynamic> data) async {
  final db = await DatabaseHelper.instance.database;
  final id = await db.update(
    table,
    data,
    where: 'FOLIO = ? AND REG = ?',
    whereArgs: [data['FOLIO'], data['REG']],
  );

  if (id == 0) {
    await db.insert(table, data);
  }
}


Future<int> insert2(
  String table,
  Map<String, dynamic> row, {
  ConflictAlgorithm conflictAlgorithm = ConflictAlgorithm.replace,
}) async {
    final db = await DatabaseHelper.instance.database;
  return await db.insert(table, row, conflictAlgorithm: conflictAlgorithm);
}



  Future<int> deleteByWhere(
      String table, String whereClause, List<dynamic> whereArgs) async {
    final db = await DatabaseHelper.instance.database;
    return await db.delete(table, where: whereClause, whereArgs: whereArgs);
  }
}
