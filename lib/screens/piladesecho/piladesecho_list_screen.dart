// © 2025 Kevin Lael de Jesús Flores
// Todos los derechos reservados.
// Este código es parte de la aplicación [Mi app].
// Prohibida su reproducción o distribución sin autorización.


import 'dart:collection';
import 'dart:convert';
// import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:miapp/db/db_crud.dart';
import 'package:miapp/db/opciontablas.dart';
import 'package:miapp/screens/piladesecho/piladesecho_mtr__register_screen.dart';
import 'package:miapp/services/api_service.dart';
import 'package:miapp/models/desmstr.dart';
import 'package:miapp/screens/piladesecho/piladesecho_desdet_list_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:miapp/navigation/app_drawer.dart';
import 'package:miapp/db/consultastablasSQL.dart';
// import 'package:sqflite/sqflite.dart';

class PiladesechoListScreen extends StatefulWidget {
  const PiladesechoListScreen({super.key});

  @override
  PiladesechoListScreenState createState() => PiladesechoListScreenState();
}

class PiladesechoListScreenState extends State<PiladesechoListScreen> {
  final Logger _logger = Logger();
  final AuthService _authService = AuthService();
  final Queries _queries = Queries();
  List<Map<String, dynamic>> pilasDesecho = [];
  bool isLoading = false;
  bool hayDatosLocalesPendientes = false;

  bool _esDelMesActual(String? fechaStr) {
  if (fechaStr == null || fechaStr.isEmpty) return false;
  try {
    final fecha = DateTime.parse(fechaStr);
    final ahora = DateTime.now();
    return fecha.month == ahora.month && fecha.year == ahora.year;
  } catch (e) {
    return false;
  }
}


  final List<String> periodos = [
    "Mes actual",
    "Mes Anterior",
    "Este Año",
    "Anteriores"
  ];
  String selectedPeriodo = "Mes actual";

  String empresa = "";
  String base = "";
  String? selectedFolio;

  @override
  void initState() {
    super.initState();
    _loadEmpresaBase();
    //INICIA A ENVIAR DATOS
    _verificarPendientes();
  }

  Future<void> _loadEmpresaBase() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userData = prefs.getString("userData");

    if (userData != null) {
      Map<String, dynamic> user = jsonDecode(userData);
      setState(() {
        empresa = user["EMPRESA"] ?? "";
        base = user["BASE"] ?? "";
      });
      await _fetchData(); // ✅ Aseguramos que _fetchData() se llama después de obtener empresa y base
    }
  }

  Future<void> _generateFolioAndNavigate() async {
    if (empresa.isEmpty || base.isEmpty) {
      _logger.e("⚠️ Empresa o base no definidas");
      return;
    }

    String? serie = await _authService.obtenerSerieDesdeSQLite(empresa, base);
    if (serie.isEmpty) {
      serie = "DEFAULT";
    }

    String? nuevoFolio =
        await _authService.obtenerFoliopiladesecho(empresa, base, serie);

    if (nuevoFolio != null) {
      Navigator.push(
        // ignore: use_build_context_synchronously
        context,
        MaterialPageRoute(
          builder: (context) => PilaRegisterMtrScreen(
            folio: nuevoFolio,
            nuevoFolio: true,
          ),
        ),
      ).then((value) {
        if (value != null && value is String) {
          setState(() {
            selectedFolio = value;
          });
          _fetchData(); // 🔄 ACTUALIZA LA LISTA AL VOLVER
        }
      });
    } else {
      _logger.e("❌ No se pudo generar el folio");
    }
  }

  String _formatDate(String? date) {
    if (date == null || date.isEmpty) return "";
    try {
      DateTime parsedDate = DateTime.parse(date);
      return DateFormat("dd/MM/yyyy").format(parsedDate);
    } catch (e) {
      return date;
    }
  }

  Future<void> _fetchData() async {
    if (empresa.isEmpty || base.isEmpty) {
      return;
    }

    setState(() => isLoading = true);

    try {
      List<Map<String, dynamic>> responseData = [];
      bool hasInternet = await _authService.hasInternetConnection();

      if (hasInternet) {
        switch (selectedPeriodo) {
          case "Mes actual":
            responseData = List<Map<String, dynamic>>.from(
                await _authService.getListaEsteMes(int.parse(empresa), base));
            break;
          case "Mes Anterior":
            responseData = List<Map<String, dynamic>>.from(await _authService
                .getListaMesAnterior(int.parse(empresa), base));
            break;
          case "Este Año":
            responseData = List<Map<String, dynamic>>.from(
                await _authService.getListaEsteAAA(int.parse(empresa), base));
            break;
          case "Anteriores":
            responseData = List<Map<String, dynamic>>.from(await _authService
                .getListaAnteriores(int.parse(empresa), base));
            break;
          default:
            responseData = [];
        }
      } else {
        List<DesMstr> lista = [];

        switch (selectedPeriodo) {
          case "Mes actual":
            lista = await _queries.sqlListaEsteMes(empresa, base);
            break;
          case "Mes Anterior":
            lista = await _queries.sqlListaMesAnterior(empresa, base);
            break;
          case "Este Año":
            lista = await _queries.sqlListaEsteAAA(empresa, base,
                "${DateTime.now().year}-01-01", "${DateTime.now().year}-12-31");
            break;
          case "Anteriores":
            lista = await _queries.sqlListaAnteriores(
                empresa, base, "${DateTime.now().year}-01-01");
            break;
          default:
            lista = [];
        }

        // print("📋 Datos obtenidos de SQLite (${selectedPeriodo}): ${lista.length} registros");

        responseData = lista.map((desmstr) => desmstr.toMap()).toList();

        // 🚨 Si no hay datos en la base de datos local, intenta cargar los últimos registros guardados
        if (responseData.isEmpty) {
          List<Map<String, dynamic>>? ultimosRegistros =
              await _obtenerUltimosRegistros();
          if (ultimosRegistros != null && ultimosRegistros.isNotEmpty) {
            responseData = ultimosRegistros;
            print(
                "🔄 Mostrando últimos registros guardados: ${ultimosRegistros.length}");
          } else {
            print("⚠️ No hay registros guardados en SharedPreferences");
          }
        }
      }

      setState(() {
        pilasDesecho = responseData;
        isLoading = false;
      });

      // Guardar los últimos registros si hay datos
      if (pilasDesecho.isNotEmpty) {
        await _guardarUltimosRegistros(pilasDesecho);
      }
    } catch (e) {
      setState(() {
        pilasDesecho = [];
        isLoading = false;
      });
      // print("🚨 Error fetching data: $e");
    }
  }

  Future<void> _guardarUltimosRegistros(
      List<Map<String, dynamic>> registros) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String jsonRegistros = jsonEncode(registros);
    await prefs.setString("ultimosRegistros", jsonRegistros);
    // print("💾 Últimos registros guardados: ${registros.length}");
  }

  Future<List<Map<String, dynamic>>?> _obtenerUltimosRegistros() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? jsonRegistros = prefs.getString("ultimosRegistros");

    if (jsonRegistros != null) {
      return List<Map<String, dynamic>>.from(jsonDecode(jsonRegistros));
    }
    return null;
  }

  /// ENVIAR DATOS

  Future<void> _verificarPendientes() async {
    final pendientes = await DBOperations.instance.queryWhere(
      'desdet',
      where: 'SINCRONIZADO = ?',
      whereArgs: [0],
    );

    for (final p in pendientes) {
      debugPrint("🟠 Pendiente REG: ${p['REG']}, FOLIO: ${p['FOLIO']}");
    }

    setState(() {
      hayDatosLocalesPendientes = pendientes.isNotEmpty;
    });
  }



  Future<void> _enviarDatosPendientes() async {
    final hasInternet = await _authService.hasInternetConnection();

    if (!hasInternet) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text("📴 Sin conexión. Conéctate a internet para sincronizar."),
        ),
      );
      return;
    }

    final db = await DatabaseHelper.instance.database;

    final registros = await db.query(
      'desdet',
      where: 'sincronizado = 0',
    );

    int enviados = 0;
    int omitidos = 0;

    for (final registro in registros) {
      final reg = registro['reg'];
      final folio = registro['folio'];

      if (reg == null ||
          folio == null ||
          reg.toString().toLowerCase() == 'null' ||
          folio.toString().toLowerCase() == 'null') {
        if (omitidos < 3) {
          // Limita cuántos errores se imprimen
          debugPrint("! REG inválido o FOLIO nulo. Se omite registro.");
        }
        omitidos++;
        continue;
      }

      final regInt = int.tryParse(reg.toString());
      if (regInt == null) {
        if (omitidos < 3) {
          debugPrint("! REG no numérico. Se omite registro.");
        }
        omitidos++;
        continue;
      }

      try {
        final jsonDesdet = _convertirAFormatoJsonOrdenado(registro);

        debugPrint("📤 Enviando FOLIO $folio REG $regInt");

        final response = await http.post(
          Uri.parse(
              "http://atlastoluca.dyndns.org:20100/datasnap/rest/TServerMethods1/PilaDesecho"),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(jsonDesdet),
        );

        if (response.statusCode == 200) {
          final result = jsonDecode(response.body);
          if (!result.toString().contains("NO insertado")) {
            await db.update(
              'desdet',
              {'sincronizado': 1},
              where: 'folio = ? AND reg = ? AND sincronizado = 0',
              whereArgs: [folio, regInt],
            );
            enviados++;
          }
        }
      } catch (e) {
        debugPrint("❌ Error al enviar REG $reg: $e");
      }
    }

    if (omitidos > 0) {
      debugPrint(
          "❗ $omitidos registros omitidos por tener FOLIO o REG inválido.");
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              "✅ Sincronización completada: $enviados enviados, $omitidos omitidos."),
        ),
      );
    }
    await _verificarPendientes();
    await _fetchData();
  }

  String _safeString(dynamic value) {
    if (value == null) return "null";
    final str = value.toString().trim();
    return (str.isEmpty || str.toLowerCase() == "null") ? "null" : str;
  }

  Map<String, dynamic> _convertirAFormatoJsonOrdenado(
      Map<String, dynamic> original) {
    Map<String, dynamic> nuevo = LinkedHashMap();

    List<String> ordenDeseado = [
      "FOLIO",
      "REG",
      "PROCEDENCIA",
      "SIS_MEDIDA",
      "MARCA",
      "MODELO",
      "MEDIDA",
      "PISO_REMANENTE",
      "RANGO_CARGA",
      "ORIREN",
      "MARCA_REN",
      "MODELO_REN",
      "SERIE",
      "DOT",
      "FALLA1",
      "FALLA2",
      "FALLA3",
      "FALLA4",
      "FALLA5",
      "ANIO",
      "FSISTEMA",
      "EMPRESA",
      "BASE",
      "OPERADOR"
    ];

    for (String key in ordenDeseado) {
      final value = original[key] ??
          original[key.toLowerCase()] ??
          original[key.toUpperCase()];
      nuevo[key] = _safeString(value);
    }

    return nuevo;
  }

  Map<String, dynamic> convertirAFormatoJsonApi(Map<String, dynamic> original) {
    final Map<String, dynamic> nuevo = {};

    original.forEach((key, value) {
      String clave = key.toUpperCase();

      if (value == null || value.toString().trim().isEmpty) {
        nuevo[clave] = "null";
      } else {
        nuevo[clave] = value.toString();
      }
    });

    return nuevo;
  }

  Future<void> _eliminarFolioDesmstr(String folio) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("¿Eliminar folio completo?"),
        content: Text(
            "¿Deseas eliminar el folio '$folio' y todos sus registros asociados?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text("Cancelar"),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text("Eliminar", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    try {
      final url = Uri.parse(
        "http://atlastoluca.dyndns.org:20100/datasnap/rest/TServerMethods1/PilaDesecho/$empresa/$base/$folio/$folio",
      );

      final response = await http.delete(url);

      if (response.statusCode == 200) {
        final db = await DatabaseHelper.instance.database;

        // Eliminar en SQLite (detalle primero, luego maestro)
        await db.delete('desdet', where: 'folio = ?', whereArgs: [folio]);
        await db.delete('desmstr', where: 'folio = ?', whereArgs: [folio]);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text("🗑️ Folio '$folio' eliminado correctamente.")),
        );

        await _fetchData(); // refrescar tabla
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text("❌ No se pudo eliminar el folio en el servidor.")),
        );
      }
    } catch (e) {
      print("❌ Error al eliminar folio: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Error al eliminar el folio.")),
      );
    }
  }

//--------------------------------------------------------------------------------------------------
  Future<void> _debugPrintDesdetDesdeSQLite(String folio) async {
    // final db = await dbHelper.database;
    final db = await DatabaseHelper.instance.database;

    final registros = await db.query(
      'desdet',
      where: 'folio = ?',
      whereArgs: [folio],
      orderBy: 'reg',
    );

    debugPrint("📋 Lista completa de 'desdet' en SQLite para FOLIO: $folio");

    for (final r in registros) {
      debugPrint(
          "➡️ REG: ${r['reg']}, FOLIO: ${r['folio']}, SINCRONIZADO: ${r['sincronizado']}");
    }

    debugPrint("🔚 Fin de registros.");
  }

// ..............................................................................................

  Widget _buildDataTable() {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columnSpacing: 16,
          headingRowColor: WidgetStateProperty.all(const Color(0xFFFFCC00)),
          dataRowColor: WidgetStateProperty.resolveWith<Color?>(
              (Set<WidgetState> states) {
            return null;
          }),
          columns: const [
            DataColumn(
                label: Text("Folio",
                    style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(
                label: Text("Fecha",
                    style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(
                label: Text("Empresa",
                    style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(
                label: Text("Base",
                    style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(
                label: Text("Medida",
                    style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(
                label: Text("Llantas",
                    style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(
                label: Text("Operador",
                    style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(
                label: Text("Fecha del Sistema",
                    style: TextStyle(fontWeight: FontWeight.bold))),
          ],
          rows: pilasDesecho.map((fila) {
            return DataRow(
              selected: selectedFolio == fila["FOLIO"],
              onSelectChanged: (selected) async {
                setState(() {
                  selectedFolio = fila["FOLIO"];
                });
                debugPrint("🔹 Folio seleccionado: $selectedFolio");
                await _debugPrintDesdetDesdeSQLite(
                    selectedFolio!); // 👈 Aquí va tu debug automático
              },

              cells: [
                DataCell(Text(fila["FOLIO"] ?? ""), onTap: () {
                  setState(() {
                    selectedFolio = fila["FOLIO"];
                  });
                  print("🔹 Folio seleccionado: $selectedFolio");
                }),
                DataCell(Text(_formatDate(fila["FECHA"]))),
                DataCell(Text(fila["EMPRESA"].toString())),
                DataCell(Text(fila["BASE"] ?? "")),
                DataCell(Text(fila["SIS_MEDIDA"] ?? "")),
                // DataCell(Text(fila["NUM_Llantas"].toString())),
                DataCell(Text(fila["NREGISTROS"]?.toString() ?? "0")),
                DataCell(Text(fila["OPERADOR"] ?? "")),
                DataCell(Text(_formatDate(fila["FSISTEMA"]))),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AppDrawer(onSelectItem: (index) => Navigator.pop(context)),
      appBar: AppBar(
        title: const Text(
          "Pilas de Desecho",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.amber,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Actualizar',
            onPressed: _fetchData,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final isWide = constraints.maxWidth > 600;

                    return isWide
                        ? Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 2,
                                child: _buildDropdownPeriodo(),
                              ),
                              const SizedBox(width: 24),
                              Expanded(
                                flex: 3,
                                child: _buildActionButtons(),
                              ),
                            ],
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _buildDropdownPeriodo(),
                              const SizedBox(height: 16),
                              _buildActionButtons(),
                            ],
                          );
                  },
                ),
              ),
            ),
          ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : pilasDesecho.isEmpty
                    ? const Center(child: Text("No hay registros disponibles"))
                    : _buildDataTable(),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownPeriodo() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedPeriodo,
          icon: const Icon(Icons.arrow_drop_down),
          onChanged: (String? newValue) {
            if (newValue != null) {
              setState(() {
                selectedPeriodo = newValue;
              });
              _fetchData();
            }
          },
          items: periodos.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value, style: const TextStyle(fontSize: 14)),
            );
          }).toList(),
        ),
      ),
    );
  }

  // Widget _buildActionButtons() {
  //   return Row(
  //     mainAxisAlignment: MainAxisAlignment.end,
  //     children: [
  //       // NUEVO 
  //       Tooltip(
  //         message: 'Nueva pila',
  //         child: IconButton(
  //           icon: const Icon(Icons.add, color: Colors.blue),
  //           onPressed: _generateFolioAndNavigate,
  //         ),
  //       ),
       
  //       // DETALLES
  //       Tooltip(
  //         message: 'Detalles',
  //         child: IconButton(
  //           icon: const Icon(Icons.edit, color: Colors.orange),
  //           onPressed: selectedFolio != null
  //               ? () {
  //                   Navigator.push(
  //                     context,
  //                     MaterialPageRoute(
  //                       builder: (context) => PiladesechoListadesdetScreen(
  //                         folio: selectedFolio!,
  //                       ),
  //                     ),
  //                   ).then((_) => _fetchData());
  //                 }
  //               : null,
  //         ),
  //       ),
  //        //ELIMINAR 
  //       Tooltip(
  //         message: 'Eliminar folio',
  //         child: IconButton(
  //           icon: const Icon(Icons.delete_forever, color: Colors.red),
  //           onPressed: selectedFolio != null
  //               ? () => _eliminarFolioDesmstr(selectedFolio!)
  //               : null,
  //         ),
  //       ),
  //       // SINCRONIZAR 
  //       Tooltip(
  //         message: hayDatosLocalesPendientes
  //             ? 'Sincronizar registros pendientes'
  //             : 'Todo está sincronizado',
  //         child: IconButton(
  //           icon: Icon(
  //             hayDatosLocalesPendientes ? Icons.outbox : Icons.done_all,
  //             color: hayDatosLocalesPendientes ? Colors.red : Colors.grey,
  //           ),
  //           tooltip: 'Sincronizar',
  //           onPressed:
  //               hayDatosLocalesPendientes ? _enviarDatosPendientes : null,
  //         ),
  //       )
  //     ],
  //   );

  Widget _buildActionButtons() {
  // Buscar los datos del folio seleccionado
  final filaSeleccionada = pilasDesecho.firstWhere(
    (e) => e["FOLIO"] == selectedFolio,
    orElse: () => {},
  );

  // Validar si la fecha es del mes actual
  bool puedeEditar = false;
  if (filaSeleccionada.isNotEmpty) {
    try {
      final fechaStr = filaSeleccionada["FECHA"];
      final fecha = DateTime.parse(fechaStr);
      final ahora = DateTime.now();
      puedeEditar = fecha.month == ahora.month && fecha.year == ahora.year;
    } catch (_) {
      puedeEditar = false;
    }
  }

  return Row(
    mainAxisAlignment: MainAxisAlignment.end,
    children: [
      // NUEVO
      Tooltip(
        message: 'Nueva pila',
        child: IconButton(
          icon: const Icon(Icons.add, color: Colors.blue),
          onPressed: _generateFolioAndNavigate,
        ),
      ),

      // DETALLES
      Tooltip(
        message: puedeEditar
            ? 'Ver detalles'
            : 'Solo se puede editar en el mes actual',
        child: IconButton(
          icon: Icon(Icons.edit,
              color: puedeEditar ? Colors.orange : Colors.grey),
          onPressed: (selectedFolio != null && puedeEditar)
              ? () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PiladesechoListadesdetScreen(
                        folio: selectedFolio!,
                      ),
                    ),
                  ).then((_) => _fetchData());
                }
              : null,
        ),
      ),

      // ELIMINAR
      Tooltip(
        message: puedeEditar
            ? 'Eliminar folio'
            : 'Solo se puede eliminar en el mes actual',
        child: IconButton(
          icon: Icon(Icons.delete_forever,
              color: puedeEditar ? Colors.red : Colors.grey),
          onPressed: (selectedFolio != null && puedeEditar)
              ? () => _eliminarFolioDesmstr(selectedFolio!)
              : null,
        ),
      ),

      // SINCRONIZAR
      Tooltip(
        message: hayDatosLocalesPendientes
            ? 'Sincronizar registros pendientes'
            : 'Todo está sincronizado',
        child: IconButton(
          icon: Icon(
            hayDatosLocalesPendientes ? Icons.outbox : Icons.done_all,
            color: hayDatosLocalesPendientes ? Colors.red : Colors.grey,
          ),
          tooltip: 'Sincronizar',
          onPressed:
              hayDatosLocalesPendientes ? _enviarDatosPendientes : null,
        ),
      ),
    ],
  );
}
}
