import 'dart:convert';
import 'dart:io'; // Para detectar si hay conexión a internet
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:miapp/global/global.dart';
import 'package:miapp/models/desdet.dart';
import 'package:miapp/models/desmstr.dart';
import 'package:miapp/models/fallas.dart';
import 'package:miapp/models/marca_renovado.dart';
import 'package:miapp/models/unidades.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../db/opciontablas.dart';
import 'package:sqflite/sqflite.dart';
import 'package:logger/logger.dart';

import '../models/medida.dart';
import '../models/marca.dart';
import '../models/modelo_renovado.dart';
import '../models/rango_carga.dart';
import '../models/tipo_unidad.dart';
import '../models/bases.dart';

class AuthService {
  final Dio _dio = Dio();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final Logger _logger = Logger();

  // URL base del servidor
  String empresa = "";
  String base = "";
  final String _baseUrl =
      'http://atlastoluca.dyndns.org:20100/datasnap/rest/TServerMethods1';

  AuthService() {
    _loadEmpresaBase();
  }

  /// 🔹 **Carga empresa y base desde SharedPreferences**
  Future<void> _loadEmpresaBase() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userData = prefs.getString("userData");

    if (userData != null) {
      Map<String, dynamic> user = jsonDecode(userData);
      empresa = user["EMPRESA"] ?? "";
      base = user["BASE"] ?? "";
      // _logger.i("🔹 Empresa y base cargadas: EMPRESA=$empresa, BASE=$base");
    } else {
      _logger.w(
          "⚠️ No se encontraron datos de empresa y base en SharedPreferences.");
    }
  }

  /// 🔹 **Login de usuario** (con soporte para modo offline)
  Future<Map<String, dynamic>?> login(String username, String password) async {
    try {
      if (await hasInternetConnection()) {
        return await _loginFromServer(username, password);
      } else {
        return await _loginFromSQLite(username, password);
      }
    } catch (e) {
      _logger.e("🚨 Error en login: $e");
      return null;
    }
  }

  /// 🔹 **Verifica si hay conexión a internet**
  // Future<bool> hasInternetConnection() async {
  //   try {
  //     final result = await InternetAddress.lookup('example.com');
  //     return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
  //   } catch (_) {
  //     return false;
  //   }
  // }
  Future<bool> hasInternetConnection() async {
  try {
    final response = await http.get(
      Uri.parse('https://google.com'),
    ).timeout(const Duration(seconds: 5));

    return response.statusCode == 200;
  } catch (e) {
    _logger.e('❌ No hay conexión a internet: $e');
    return false;
  }
}


  /// 🔹 **Login desde el servidor**
  Future<Map<String, dynamic>?> _loginFromServer(
      String username, String password) async {
    try {
      String loginUrl = '$_baseUrl/validaUsuario/$username/$password';
      Response response = await _dio.get(loginUrl);

      _logger.i("🔹 Respuesta del servidor: ${response.data}");

      if (response.statusCode == 200 && response.data != null) {
        if (response.data['DATA'] != null && response.data['DATA'].isNotEmpty) {
          await _storage.write(key: 'auth_token', value: username);
          return response.data;
        }
      }
      _logger.w("⚠️ Usuario o contraseña incorrectos.");
      return null;
    } catch (e) {
      _logger.e("🚨 DioException en _loginFromServer: $e");
      return null;
    }
  }

  /// 🔹 **Login desde SQLite (modo offline)**
  Future<Map<String, dynamic>?> _loginFromSQLite(
      String username, String password) async {
    final db = await _dbHelper.database;

    final result = await db.query(
      'accesos_usuarios',
      where: 'usuario = ? AND psw = ?',
      whereArgs: [username, password],
      orderBy: 'falta DESC',
      limit: 1,
    );

    if (result.isNotEmpty) {
      _logger.i("✅ Usuario autenticado desde SQLite: $result");
      return {
        'DATA': [result.first]
      };
    } else {
      _logger.w("⛔ No se encontró usuario en SQLite.");
      return null;
    }
  }

  /// 🔹 **Obtiene datos de la empresa base, los guarda en SQLite y en localStorage**
  Future<Map<String, dynamic>?> syncUsuarioEmpresaBase(
      String username, String password, String empresa, String base) async {
    try {
      String url =
          '$_baseUrl/usuarioEmpresaBase/$username/$password/$empresa/$base';
      _logger.i("🏢 Obteniendo datos de empresa base para usuario: $username");

      Response response =
          await _dio.get(url).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200 && response.data != null) {
        _logger.i("✅ Datos de empresa base recibidos: ${response.data}");

        // 📌 Verificar si la respuesta contiene los datos esperados
        if (response.data['DATA'] != null && response.data['DATA'].isNotEmpty) {
          Map<String, dynamic> empresaData = response.data['DATA'][0];

          // Guardar los datos en SQLite
          await _insertUsuarioEmpresaBase(empresaData);

          // Guardar los datos en localStorage para persistencia entre recargas
          await guardarEnLocalStorage(empresaData);

          _logger.i("✅ Datos de empresa base guardados en localStorage");

          // 📌 Retornar los datos obtenidos para su uso en la UI
          return empresaData;
        } else {
          _logger.w("⚠️ No se encontraron datos para este usuario.");
          return null;
        }
      } else {
        _logger
            .e("❌ Error en obtención de empresa base (${response.statusCode})");
        return null;
      }
    } catch (e) {
      _logger.e("🚨 Error al obtener empresa base: $e");
      return null;
    }
  }

  /// 🔹 **Guarda los datos obtenidos en SQLite**
  Future<void> _insertUsuarioEmpresaBase(Map<String, dynamic> data) async {
    final db = await _dbHelper.database;

    try {
      // 📌 Insertar en la tabla accesos_usuarios (Actualizar si ya existe)
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

      // 📌 Insertar en la tabla empresas
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

      // 📌 Insertar en la tabla bases
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

      // 📌 Actualizar el último acceso en SQLite para que se recuerde sin internet
      await db.update(
        'accesos_usuarios',
        {
          'falta': DateTime.now().toIso8601String()
        }, // Guardar la última fecha de acceso
        where: 'usuario = ? AND base = ?',
        whereArgs: [data['USUARIO'], data['BASE']],
      );

      _logger.i("✅ Datos insertados correctamente en SQLite del api_service.");
    } catch (e) {
      _logger.e("❌ Error al insertar datos en SQLite: $e");
    }
  }

  /// 🔹 **Función para generar el folio basado en la serie del usuario y la fecha actual**
  String obtenerFolio(String? serieId) {
    if (serieId == null || serieId.isEmpty || serieId == "SIN_SERIE") {
      _logger.e(
          "❌ Error: No se puede generar el folio porque SERIE está vacía o no válida.");
      return "SIN_SERIE";
    }

    DateTime now = DateTime.now();
    String month = now.month.toString().padLeft(2, '0'); // Mes con 2 dígitos
    String year =
        now.year.toString().substring(2, 4); // Últimos 2 dígitos del año

    String folio = "$serieId$month$year";
    _logger.i("📌 Folio generado correctamente: $folio");

    return folio;
  }

  /// 🔹 **Obtener la serie desde SQLite si no está en la API**
  Future<String> obtenerSerieDesdeSQLite(
      String empresaId, String baseId) async {
    final db = await _dbHelper.database;

    final result = await db.query(
      'bases',
      columns: ['serie'],
      where: 'empresa = ? AND base = ?',
      whereArgs: [empresaId, baseId],
      limit: 1,
    );

    if (result.isNotEmpty) {
      final serieValue = result.first['serie'];

      if (serieValue != null && serieValue.toString().isNotEmpty) {
        _logger.i(
            "🔹 Serie obtenida desde SQLite: $serieValue para EMPRESA: $empresaId, BASE: $baseId");
        return serieValue.toString();
      }
    }

    _logger.e(
        "⛔ No se encontró 'SERIE' en SQLite para EMPRESA: $empresaId, BASE: $baseId. Verifica la base de datos.");
    return "SIN_SERIE"; // Evita valores erróneos
  }


  Future<List<dynamic>> _fetchData(String endpoint, String resourceName) async {
    try {
      String url = '$_baseUrl/$endpoint';
      Response response = await _dio.get(url);

      _logger.i(
          "📌 Datos obtenidos de la API para $resourceName: ${response.data}");

      if (response.statusCode == 200) {
        return response.data['DATA'] ?? [];
      }
      throw Exception(
          "Error al obtener $resourceName: Código ${response.statusCode}");
    } catch (e) {
      _logger.e("🚨 Error en _fetchData ($resourceName): $e");
      return [];
    }
  }

  /// 🔹 **Métodos para obtener datos desde la API**
  Future<List<dynamic>> getEmpresasLista() async =>
      _fetchData('empresasLista', "Empresas");
  Future<List<dynamic>> getFallasLista(int empresaId) async =>
      _fetchData('fallasLista/$empresaId', "Fallas");
  Future<List<dynamic>> getMarcasLista(int empresaId) async =>
      _fetchData('marcasLista/$empresaId', "Marcas");
  Future<List<dynamic>> getMarcaRenovadoLista(int empresaId) async =>
      _fetchData('marcaRenovadoLista/$empresaId', "Marca Renovado");
  Future<List<dynamic>> getMedidasLista(int empresaId) async =>
      _fetchData('medidasLista/$empresaId', "Medidas");
  Future<List<dynamic>> getModeloRenovadoLista(int empresaId) async =>
      _fetchData('modeloRenLista/$empresaId', "Modelo Renovado");
  Future<List<dynamic>> getRangoCargaLista(int empresaId) async =>
      _fetchData('rangoCargaLista/$empresaId', "Rango Carga");
  Future<List<dynamic>> getTipoUnidadLista(int empresaId) async =>
      _fetchData('tipoUnidadLista/$empresaId', "Tipo Unidad");
  Future<List<dynamic>> getBaseLista(int empresaId) async =>
      _fetchData('ListaBases/$empresaId', "Bases");
  Future<List<dynamic>> getUnidadesLista(
      int empresaId, String baseId, String serie) async {
    final folio = obtenerFolio(serie);
    return _fetchData('unidadesLista/$empresaId/$baseId/$folio', "Unidades");
  }

  Future<List<dynamic>> getListaEsteMes(
    int empresaId,
    String baseId,
  ) async =>
      _fetchData('GetListaEsteMes/$empresaId/$baseId', "FECHAMES");
  Future<List<dynamic>> getListaMesAnterior(
    int empresaId,
    String baseId,
  ) async =>
      _fetchData('GetListaMesAnterior/$empresaId/$baseId', "FECHAMESANTERIOR");
  Future<List<dynamic>> getListaEsteAAA(
    int empresaId,
    String baseId,
  ) async =>
      _fetchData('GetListaEsteAAA/$empresaId/$baseId', "FECHAAÑO");
  Future<List<dynamic>> getListaAnteriores(
    int empresaId,
    String baseId,
  ) async =>
      _fetchData('GetListaAnteriores/$empresaId/$baseId', "FECHAANTERIORES");

Future<List<dynamic>> getDesDetxFolio(int empresaId, String baseId, String folio) async =>
      _fetchData('DesDetxFolio/$empresaId/$baseId/$folio', "DesDetxFolio");

Future<void> _insertData<T>(List<T> dataList, Future<void> Function(List<T>) insertFunction, String tableName) async {
  if (dataList.isNotEmpty) {
    // _logger.i("📌 Intentando insertar ${dataList.length} registros en $tableName: $dataList");
    try {
      await insertFunction(dataList);
      _logger.i("✅ Datos insertados en $tableName correctamente de api_service.");
    } catch (e) {
      _logger.e("❌ Error al insertar datos en $tableName: $e");
    }
  } else {
    _logger.w("⚠️ No hay datos para insertar en $tableName.");
  }
}

  /// 🔹 Uso del método genérico para insertar los datos obtenidos de la API
  Future<void> syncData(int empresaId, String baseId, String serie) async {
    try {
      _logger.i(
          "🔄 Iniciando sincronización de datos para empresa ID: $empresaId...");

      // 📌 Obtener datos desde la API
      final medidasResponse = await getMedidasLista(empresaId);
      // final marcasResponse = await getMarcasLista(empresaId);
      final marcasResponse = await getMarcasLista(empresaId); await insertarMarcasDesdeServidor(marcasResponse);
      final fallasResponse = await getFallasLista(empresaId);
      final modeloRenovadoResponse = await getModeloRenovadoLista(empresaId);
      final rangoCargaResponse = await getRangoCargaLista(empresaId);
      final tipoUnidadResponse = await getTipoUnidadLista(empresaId);
      final baseResponse = await getBaseLista(empresaId);
      final marcaRenovadoResponse = await getMarcaRenovadoLista(empresaId);
      final unidadesResponse = await getUnidadesLista(empresaId, baseId, serie);
      final pilaEsteMesResponse = await getListaEsteMes(empresaId, baseId);
      final pilaMesAnteriorResponse = await getListaMesAnterior(empresaId, baseId);
      final pilaEsteAAAResponse = await getListaEsteAAA(empresaId, baseId);
      final pilaAnterioresResponse = await getListaAnteriores(empresaId, baseId);
      final desDetxFolioResponse = await getDesDetxFolio(empresaId, baseId, serie);

      // 📌 Convertir respuestas a listas de modelos
      List<Medida> medidaList = medidasResponse
          .map((e) => Medida.fromMap(e as Map<String, dynamic>))
          .toList();
      List<Marca> marcaList = marcasResponse
          .map((e) => Marca.fromMap(e as Map<String, dynamic>))
          .toList();
      List<Fallas> fallaList = fallasResponse
          .map((e) => Fallas.fromMap(e as Map<String, dynamic>))
          .toList();
      List<ModeloRenovado> modeloRenovadoList = modeloRenovadoResponse
          .map((e) => ModeloRenovado.fromMap(e as Map<String, dynamic>))
          .toList();
      List<RangoCarga> rangoCargaList = rangoCargaResponse
          .map((e) => RangoCarga.fromMap(e as Map<String, dynamic>))
          .toList();
      List<TipoUnidad> tipoUnidadList = tipoUnidadResponse
          .map((e) => TipoUnidad.fromMap(e as Map<String, dynamic>))
          .toList();
      List<MarcaRenovado> marcaRenovadoList = marcaRenovadoResponse
          .map((e) => MarcaRenovado.fromMap(e as Map<String, dynamic>))
          .toList();
      List<Base> baseList = baseResponse
          .map((e) => Base.fromMap(e as Map<String, dynamic>))
          .toList();
      List<Unidad> unidadList = unidadesResponse
          .map((e) => Unidad.fromMap(e as Map<String, dynamic>))
          .toList();
        // List<DesMstr> pilaDesechoList = [
      [
        ...pilaEsteMesResponse,
        ...pilaMesAnteriorResponse,
        ...pilaEsteAAAResponse,
        ...pilaAnterioresResponse,
      ].map((e) => DesMstr.fromMap(e as Map<String, dynamic>)).toList();
      List<DesDet> desDetList = desDetxFolioResponse
          .map((e) => DesDet.fromMap(e as Map<String, dynamic>))
          .toList();
      

    //  await _dbHelper.deleteDesDetByFolio(serie); // Usas `serie` como folio actual aquí


      // 📌 Insertar datos en SQLite usando el método genérico
      await _insertData(medidaList, _dbHelper.insertMedidas, "medidas");
      await _insertData(marcaList, _dbHelper.insertMarcas, "marcas");
      await _insertData(fallaList, _dbHelper.insertFallas, "fallas");
      await _insertData(modeloRenovadoList, _dbHelper.insertModeloRenovado,
          "modelo_renovado");
      await _insertData(
          rangoCargaList, _dbHelper.insertRangoCarga, "rango_carga");
      await _insertData(
          tipoUnidadList, _dbHelper.insertTipoUnidad, "tipo_unidad");
      await _insertData(
          marcaRenovadoList, _dbHelper.insertMarcaRenovado, "marca_renovado");
      await _insertData(baseList, _dbHelper.insertBase, "bases");
      await _insertData(unidadList, _dbHelper.insertUnidades, "unidades");
      // await _insertData(pilaDesechoList, _dbHelper.insertDesMstr, "desmstr");
      await _insertData(desDetList, _dbHelper.insertDesDet, "desdet");



      _logger.i("✅ Sincronización de datos completada.");
    } catch (e, stacktrace) {
      _logger.e("❌ Error en la sincronización: $e\n$stacktrace");
    }
  }


Future<String?> obtenerFoliopiladesecho(String empresa, String base, String serie) async {
    if (empresa.isEmpty || base.isEmpty || serie.isEmpty) {
      _logger.e('Parámetros insuficientes para obtener el folio.');
      return null;
    }

    final String url = '$_baseUrl/GetListaFoliodes_mstr/$empresa/$base';
    _logger.i('URL generada: $url');

    try {
      Response response = await _dio.get(url);
      Map<String, dynamic> data = response.data;

      if (data.containsKey('DATA') && data['DATA'] is List && data['DATA'].isNotEmpty) {
        String folioActual = data['DATA'][0]['FOLIO'];
        _logger.i('Folio actual obtenido de la API: $folioActual');
        return _incrementarFolio(folioActual);
      } else {
        _logger.w('No se encontraron datos en la API. Intentando con SharedPreferences...');
        return await _obtenerFolioDesdeSharedPreferences(serie);
      }
    } catch (e) {
      // _logger.e('Error en obtenerFolio desde API: $e');
      _logger.w('Intentando obtener folio desde SharedPreferences...');
      return await _obtenerFolioDesdeSharedPreferences(serie);
    }
}


Future<String?> _obtenerFolioDesdeSharedPreferences(String serie) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();

  try {
    final String? jsonRegistros = prefs.getString("ultimosRegistros");

    if (jsonRegistros != null && jsonRegistros.isNotEmpty) {
      final List<dynamic> decodedList = jsonDecode(jsonRegistros);

      if (decodedList.isNotEmpty && decodedList[0] is Map<String, dynamic>) {
        final Map<String, dynamic> primerRegistro = decodedList[0];
        final String? folioActual = primerRegistro['FOLIO'];

        if (folioActual != null && folioActual.isNotEmpty) {
          _logger.i('✅ Folio obtenido de SharedPreferences: $folioActual');
          return _incrementarFolio(folioActual);
        }
      }
    }

    _logger.w('⚠️ No se encontró un folio válido en SharedPreferences. Generando folio inicial.');
    return '${serie}0001';

  } catch (e) {
    _logger.e('❌ Error leyendo SharedPreferences: $e');
    return '${serie}0001';
  }
}


String _incrementarFolio(String folioActual) {
    String prefijo = folioActual.replaceAll(RegExp(r'\d'), '');
    String numero = folioActual.replaceAll(RegExp(r'\D'), '');
    int nuevoNumero = int.parse(numero) + 1;
    return '$prefijo${nuevoNumero.toString().padLeft(numero.length, '0')}';
}

Future<bool> hayDatosNoSincronizados() async {
  final db = await DatabaseHelper.instance.database;

  final desdet = await db.query('desdet', where: 'sincronizado = 0');
  final desmstr = await db.query('desmstr', where: 'sincronizado = 0');

  return desdet.isNotEmpty || desmstr.isNotEmpty;
}
/// ----------------CATALOGO  --------------------------------------------------------------------
/// 

/// 🔹 Ejecuta una instrucción SQL en el servidor y verifica si fue exitosa
Future<bool> ejecutarSQLRemoto(String sql) async {
  final String url = "$_baseUrl/SQL_insert_update_delete/$sql";
  try {
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final body = response.body.trim().toLowerCase();
      // _logger.i("🛰 SQL ejecutado: $sql → Respuesta: $body");

      // ✅ Asegura que no solo llegó 200, sino que respondió algo como "true" o "ok"
      return body.contains("true") || body.contains("ok");
    } else {
      _logger.w("⚠️ Error HTTP al ejecutar SQL: ${response.statusCode}");
      return false;
    }
  } catch (e) {
    _logger.e("❌ Error al ejecutar SQL remoto: $e");
    return false;
  }
}




/// ----------------SEMAFOREO --------------------------------------------------------------------

/// 🔹 Obtiene datos del semaforeo desde la API
Future<List<Map<String, dynamic>>> getSemaforeo(
    int empresaId, String baseId, int fechaDesde, int fechaHasta) async {
  try {
    final String url =
        '$_baseUrl/Semaforeo/$empresaId/$baseId/$fechaDesde/$fechaHasta';

    _logger.i('📡 Consultando semaforeo: $url');

    final response = await _dio.get(url);

    if (response.statusCode == 200 && response.data != null) {
      final data = response.data['DATA'];
      if (data != null && data is List) {
        _logger.i("✅ ${data.length} registros recibidos del semaforeo");
        return List<Map<String, dynamic>>.from(data);
      } else {
        _logger.w("⚠️ Respuesta sin datos válidos.");
        return [];
      }
    } else {
      _logger.e("❌ Error de respuesta HTTP: ${response.statusCode}");
      return [];
    }
  } catch (e) {
    _logger.e("🚨 Error en getSemaforeo: $e");
    return [];
  }
}


// Future<List<String>> getUnidadesDisponibles(String empresa, String base, String folio) async {
//   final url = Uri.parse('$_baseUrl/UnidadesSemaforo/$empresa/$base/$folio');
//   final response = await http.get(url);

//   if (response.statusCode == 200) {
//     final json = jsonDecode(response.body);
//     final data = json['DATA'] as List;
//     return data.map<String>((e) => e['UNIDAD'].toString()).toList();
//   }

//   return [];
// }

Future<List<String>> getUnidadesDisponibles(String empresa, String base, String folio) async {
  final url = Uri.parse('$_baseUrl/UnidadesSemaforo/$empresa/$base/$folio');
  final response = await http.get(url);

  if (response.statusCode == 200) {
    final json = jsonDecode(response.body);

    // ⚠️ Validación importante para evitar el error
    if (json['DATA'] != null && json['DATA'] is List) {
      final data = json['DATA'] as List;
      return data.map<String>((e) => e['UNIDAD'].toString()).toList();
    } else {
      return []; // ⛔ Retorna lista vacía si DATA viene null o no es lista
    }
  }

  return [];
}

Future<bool> validarUnidadEnServidor(
    String empresa, String base, String folio, String unidad) async {
  final url = Uri.parse(
    "$_baseUrl/validaUnidad/$empresa/$base/$folio/$unidad"
  );

  _logger.i("🌐 URL: $url");

  try {
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final body = response.body.trim().toLowerCase().replaceAll('"', '');
      final resultado = body == "true";

      _logger.i("🔍 Resultado procesado: unidad=$unidad ➤ registrado=$resultado");
      return resultado;
    } else {
      _logger.w("⚠️ Respuesta HTTP no exitosa: ${response.statusCode}");
      return false;
    }
  } catch (e) {
    _logger.e("❌ Error al validar unidad '$unidad': $e");
    return false;
  }
}

Future<void> insertarMarcasDesdeServidor(List<dynamic> marcasData) async {
  final db = await DatabaseHelper.instance.database;

  for (var marca in marcasData) {
    try {
      await db.insert(
        'marca',
        {
          'empresa': marca['EMPRESA'],
          'marca': marca['MARCA'],
          'procedencia': marca['PROCEDENCIA'],
          'sincronizado': 1, // 👈 importante: viene del servidor
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      print("❌ Error insertando marca: $e");
    }
  }
}
Future<void> insertarMedidasDesdeServidor(List<dynamic> medidasData) async {
  final db = await DatabaseHelper.instance.database;

  for (var medida in medidasData) {
    try {
      await db.insert(
        'medida',
        {
          'empresa': medida['EMPRESA'],
          'medida': medida['MEDIDA'],
          'sincronizado': 1, // ✅ viene del servidor
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      print("❌ Error insertando medida: $e");
    }
  }
}





Future<bool> actualizarCatalogosDesdeApi() async {
    try {
      // final db = await _dbHelper.database;

      _logger.i("🔄 Iniciando limpieza de catálogos...");

      final tablas = [
        'medida',
        'marca',
        'fallas',
        'modelo_renovado',
        'rango_carga',
        'tipo_unidad',
        'marca_renovado',
        'bases',
        'unidades',
      ];

      for (var tabla in tablas) {
        await borrarSiExiste(tabla);
      }

      // if (empresa.isEmpty || base.isEmpty) {
      //   await _loadEmpresaBase();
      // }

      _logger.i("🌐 Sincronizando catálogos desde API...");

      final resultado = await syncDataConResultado(
        int.parse(empresa),
        base,
        "",
      );

      if (resultado == 0) {
        _logger.w("⚠️ Sincronización completada pero sin datos nuevos.");
        return false;
      }

      _logger.i("✅ Catálogos actualizados correctamente.");
      return true;
    } catch (e) {
      _logger.e("❌ Error en actualización de catálogos: $e");
      return false;
    }
  }

  Future<void> borrarSiExiste(String tabla) async {
    final db = await _dbHelper.database;
    if (await existeTabla(db, tabla)) {
      await db.delete(tabla);
      _logger.i("🧹 Tabla '$tabla' limpiada correctamente.");
    } else {
      _logger.w("⚠️ Tabla '$tabla' no existe. Se omite el borrado.");
    }
  }

  Future<bool> existeTabla(Database db, String nombreTabla) async {
    final result = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table' AND name = ?",
      [nombreTabla],
    );
    return result.isNotEmpty;
  }

  Future<int> syncDataConResultado(int empresaId, String baseId, String serie) async {
    int totalCatalogosConDatos = 0;

    final medidas = await getMedidasLista(empresaId);
    final marcas = await getMarcasLista(empresaId);
    final fallas = await getFallasLista(empresaId);
    final modeloRen = await getModeloRenovadoLista(empresaId);
    final rangoCarga = await getRangoCargaLista(empresaId);
    final tipoUnidad = await getTipoUnidadLista(empresaId);
    final marcaRenovado = await getMarcaRenovadoLista(empresaId);
    final bases = await getBaseLista(empresaId);

    if (medidas.isNotEmpty) totalCatalogosConDatos++;
    if (marcas.isNotEmpty) totalCatalogosConDatos++;
    if (fallas.isNotEmpty) totalCatalogosConDatos++;
    if (modeloRen.isNotEmpty) totalCatalogosConDatos++;
    if (rangoCarga.isNotEmpty) totalCatalogosConDatos++;
    if (tipoUnidad.isNotEmpty) totalCatalogosConDatos++;
    if (marcaRenovado.isNotEmpty) totalCatalogosConDatos++;
    if (bases.isNotEmpty) totalCatalogosConDatos++;

    await _insertData(medidas.map((e) => Medida.fromMap(e)).toList(), _dbHelper.insertMedidas, "medidas");
    await _insertData(marcas.map((e) => Marca.fromMap(e)).toList(), _dbHelper.insertMarcas, "marcas");
    await _insertData(fallas.map((e) => Fallas.fromMap(e)).toList(), _dbHelper.insertFallas, "fallas");
    await _insertData(modeloRen.map((e) => ModeloRenovado.fromMap(e)).toList(), _dbHelper.insertModeloRenovado, "modelo_renovado");
    await _insertData(rangoCarga.map((e) => RangoCarga.fromMap(e)).toList(), _dbHelper.insertRangoCarga, "rango_carga");
    await _insertData(tipoUnidad.map((e) => TipoUnidad.fromMap(e)).toList(), _dbHelper.insertTipoUnidad, "tipo_unidad");
    await _insertData(marcaRenovado.map((e) => MarcaRenovado.fromMap(e)).toList(), _dbHelper.insertMarcaRenovado, "marca_renovado");
    await _insertData(bases.map((e) => Base.fromMap(e)).toList(), _dbHelper.insertBase, "bases");

    return totalCatalogosConDatos;
  }

Future<List<Map<String, dynamic>>> obtenerDesdetDelServidor(
  String empresa, String base, String folio) async {
  final url = Uri.parse(
    'http://atlastoluca.dyndns.org:20100/datasnap/rest/TServerMethods1/DesDetxFolio/$empresa/$base/$folio',
  );

  try {
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['Data'] is List) {
        return List<Map<String, dynamic>>.from(data['Data']);
      }
    }
  } catch (e) {
    print("❌ Error al obtener registros del servidor: $e");
  }
  return [];
}



  /// 🔹 **Cierra sesión eliminando el token almacenado**
  Future<void> logout() async {
    await _storage.delete(key: 'auth_token');
  }
}
