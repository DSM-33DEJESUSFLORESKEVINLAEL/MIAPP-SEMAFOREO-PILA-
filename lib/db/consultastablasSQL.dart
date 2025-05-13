import 'package:miapp/models/desmstr.dart';

import 'opciontablas.dart';

class Queries {
  Future<List<Map<String, dynamic>>> sqllogin(String usuario, String clave) async {
    final db = await DatabaseHelper.instance.database;
    return await db.rawQuery('''
      SELECT accesos_usuarios.empresa, empresas.nombre AS nombre_empresa, accesos_usuarios.base
      FROM empresas
      INNER JOIN accesos_usuarios ON empresas.empresa = accesos_usuarios.empresa
      WHERE usuario = ? AND psw = ?
    ''', [usuario, clave]);
  }

  Future<List<Map<String, dynamic>>> sqlUsuarioEmpresaBase(String usuario, String clave, String empresa, String base) async {
    final db = await DatabaseHelper.instance.database;
    return await db.rawQuery('''
      SELECT accesos_usuarios.usuario, accesos_usuarios.nombre AS nombreusuario, accesos_usuarios.psw,
      accesos_usuarios.falta, accesos_usuarios.fbaja, accesos_usuarios.puesto, accesos_usuarios.obs,
      accesos_usuarios.empresa, accesos_usuarios.base, empresas.nombre AS nombreempresa, 
      empresas.desmontaje_inmediato, empresas.desmontaje_prox_desde, empresas.desmontaje_prox_hasta, 
      empresas.buenas_condiciones, bases.serie, bases.emp_cte, bases.cliente, bases.lugar, bases.grupo
      FROM accesos_usuarios
      LEFT JOIN bases ON bases.empresa = accesos_usuarios.empresa AND bases.base = accesos_usuarios.base
      LEFT JOIN empresas ON accesos_usuarios.empresa = empresas.empresa
      WHERE usuario = ? AND psw = ? AND accesos_usuarios.empresa = ? AND accesos_usuarios.base = ?
    ''', [usuario, clave, empresa, base]);
  }

  Future<List<Map<String, dynamic>>> sqlAccesos(String empresa, String base, String usuario) async {
    final db = await DatabaseHelper.instance.database;
    return await db.rawQuery('''
      SELECT DISTINCT acceso 
      FROM accesos_permisos
      WHERE empresa = ? AND base = ? AND usuario = ?
    ''', [empresa, base, usuario]);
  }

  Future<List<Map<String, dynamic>>> sqlListaPilaDesecho(String empresa, String base, String fechaInicio, String fechaFin) async {
    final db = await DatabaseHelper.instance.database;
    return await db.rawQuery('''
      SELECT desmstr.folio, desmstr.fecha, desmstr.empresa, desmstr.base, desmstr.sis_medida, 
      desmstr.operador, desmstr.num_semana, desmstr.num_mes, desmstr.nregistros, empresas.nombre, desmstr.fsistema
      FROM desmstr
      INNER JOIN empresas ON empresas.empresa = desmstr.empresa
      WHERE desmstr.empresa = ? AND desmstr.base = ? AND fecha BETWEEN ? AND ?
      ORDER BY desmstr.fecha DESC, desmstr.folio DESC
    ''', [empresa, base, fechaInicio, fechaFin]);
  }

Future<List<DesMstr>> sqlListaEsteMes(String empresa, String base) async {
  final db = await DatabaseHelper.instance.database;
  List<Map<String, dynamic>> results = await db.rawQuery('''
    SELECT empresa, base, folio, fecha, sis_medida, operador, 
           num_semana, num_mes, nregistros, fsistema
    FROM desmstr
    WHERE empresa = ?
      AND base = ?
    ORDER BY fecha DESC, folio DESC
  ''', [empresa, base]);

  print("📌 Registros encontrados en SQLite: ${results.length}");
  for (var item in results) {
    print("📌 Registro consultas tablas: $item");
  }

  return results.map((map) => DesMstr.fromMap(map)).toList();
}




  Future<List<DesMstr>> sqlListaMesAnterior(String empresa, String base) async {
    final db = await DatabaseHelper.instance.database;
    final List<Map<String, dynamic>> result = await db.rawQuery('''
      SELECT 
        empresa, base, folio, fecha, sis_medida, operador, 
        num_semana, num_mes, nregistros, fsistema
      FROM desmstr
      WHERE strftime('%m', fecha) = strftime('%m', 'now', '-1 month')
        AND strftime('%Y', fecha) = strftime('%Y', 'now')
        AND empresa = ? 
        AND base = ?
      ORDER BY fecha DESC, folio DESC
    ''', [empresa, base]);

    return result.map((map) => DesMstr.fromMap(map)).toList();
  }

  Future<List<DesMstr>> sqlListaEsteAAA(
      String empresa, String base, String fechaInicio, String fechaFin) async {
    final db = await DatabaseHelper.instance.database;
    final List<Map<String, dynamic>> result = await db.rawQuery('''
      SELECT 
        empresa, base, folio, fecha, sis_medida, operador, 
        num_semana, num_mes, nregistros, fsistema
      FROM desmstr
      WHERE fecha BETWEEN ? AND ?
        AND empresa = ? 
        AND base = ?
      ORDER BY fecha DESC, folio DESC
    ''', [fechaInicio, fechaFin, empresa, base]);

    return result.map((map) => DesMstr.fromMap(map)).toList();
  }

  Future<List<DesMstr>> sqlListaAnteriores(
      String empresa, String base, String fecha) async {
    final db = await DatabaseHelper.instance.database;
    final List<Map<String, dynamic>> result = await db.rawQuery('''
      SELECT 
        empresa, base, folio, fecha, sis_medida, operador, 
        num_semana, num_mes, nregistros, fsistema
      FROM desmstr
      WHERE fecha < ?
        AND empresa = ? 
        AND base = ?
      ORDER BY fecha DESC, folio DESC
    ''', [fecha, empresa, base]);



    return result.map((map) => DesMstr.fromMap(map)).toList();
  }
}
