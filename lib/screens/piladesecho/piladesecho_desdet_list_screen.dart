import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:miapp/screens/piladesecho/piladesecho_mtr__register_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:miapp/db/opciontablas.dart';
import 'package:miapp/services/api_service.dart';
import 'package:miapp/models/desdet.dart';

class PiladesechoListadesdetScreen extends StatefulWidget {
  final String folio;

  const PiladesechoListadesdetScreen({super.key, required this.folio});

  @override
  PiladesechoListadesdetScreenState createState() =>
      PiladesechoListadesdetScreenState();
}

class PiladesechoListadesdetScreenState
    extends State<PiladesechoListadesdetScreen> {
  final AuthService _authService = AuthService();
  final DatabaseHelper dbHelper = DatabaseHelper.instance;
  List<DesDet> detallesFolio = [];
  bool isLoading = true;
  String empresa = "";
  String base = "";

  @override
  void initState() {
    super.initState();
    print("🟦 Cargando detalles para folio: ${widget.folio}");
    _loadEmpresaBase();
  }

  // ----------------------funcion para cargar empresa--------------------------------
  Future<void> _loadEmpresaBase() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userData = prefs.getString("userData");

    if (userData != null) {
      Map<String, dynamic> user = jsonDecode(userData);
      empresa = user["EMPRESA"]?.toString() ?? "";
      base = user["BASE"]?.toString() ?? "";

      await _syncAndLoadData();
    } else {
      setState(() => isLoading = false);
    }
  }

  // ----------------------funcion para cargar con o sin conexion--------------------------------

  Future<void> _syncAndLoadData() async {
    detallesFolio.clear();

    if (empresa.isEmpty || base.isEmpty) {
      debugPrint(
          "⚠️ No se encontraron datos de empresa/base en SharedPreferences");
      if (mounted) setState(() => isLoading = false); // ✅
      return;
    }

    if (mounted) setState(() => isLoading = true); // ✅

    try {
      final hasInternet = await _authService.hasInternetConnection();
      if (!mounted) return; // ✅

      if (hasInternet) {
        await _authService.syncData(int.parse(empresa), base, widget.folio);
        debugPrint("🌍 Sincronización con API completada.");
      } else {
        debugPrint("📴 Sin conexión. Solo se cargarán datos locales.");
      }
    } catch (e) {
      debugPrint("🚨 Error durante la sincronización con API: $e");
    }

    try {
      final db = await dbHelper.database;
      final registros = await db.query(
        'desdet',
        where: 'folio = ?',
        whereArgs: [widget.folio],
      );

      final List<DesDet> tempDetalles =
          registros.map((e) => DesDet.fromMap(e)).toList();
      if (!mounted) return; // ✅

      final uniqueDetalles = _removerDuplicadosPorReg(tempDetalles);
      final detallesFiltrados = uniqueDetalles
          .where((d) =>
              d.reg != null &&
              d.folio.isNotEmpty &&
              d.folio.toLowerCase() != 'null')
          .toList();

      for (var detalle in uniqueDetalles) {
        debugPrint("🧾 Registro de desdet: ${detalle.toJson()}");
      }
//
      if (mounted) {
        setState(() {
          detallesFolio = detallesFiltrados;
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("🚨 Error obteniendo datos locales de SQLite: $e");
      if (mounted) setState(() => isLoading = false); // ✅
    }
  }

  bool get hayDatosLocalesPendientes {
    return detallesFolio.any((detalle) => detalle.sincronizado == 0);
  }

//-------------------------- funcion para eliminar--------------------------------------
  Future<void> _eliminarFilaDesdet(DesDet detalle) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("¿Eliminar registro?"),
        content: Text(
            "¿Deseas eliminar el registro con REG '${detalle.reg}' del folio '${detalle.folio}'?"),
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

    if (confirmar == true) {
      try {
        // Construir la URL para DELETE
        final String url =
            "http://atlastoluca.dyndns.org:20100/datasnap/rest/TServerMethods1/PilaDesecho/"
            "${detalle.empresa}/${detalle.base}/${detalle.folio}/${detalle.reg}";

        final response = await http.delete(Uri.parse(url));

        if (response.statusCode == 200) {
          // ✅ Eliminar localmente después de confirmar éxito del servidor
          final db = await dbHelper.database;
          final deleted = await db.delete(
            'desdet',
            where: 'folio = ? AND reg = ?',
            whereArgs: [detalle.folio, detalle.reg],
          );

          if (deleted > 0) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text("🗑️ Registro eliminado: REG ${detalle.reg}")),
            );
            await _syncAndLoadData();
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("⚠️ Registro no encontrado en SQLite.")),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(
                    "❌ Error al eliminar en el servidor: ${response.statusCode}")),
          );
        }
      } catch (e) {
        debugPrint("❌ Error al eliminar: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text("❌ Ocurrió un error al eliminar el registro.")),
        );
      }
    }
  }

//----------------------------funcion para editar------------------------------------------------

  // void _editarFilaDesdet(DesDet detalle) {
  //   Navigator.push(
  //     context,
  //     MaterialPageRoute(
  //       builder: (context) => PilaRegisterMtrScreen(
  //         folio: detalle.folio,
  //         nuevoFolio: false,
  //         folioExistente: detalle.folio,
  //       ),
  //     ),
  //   );
  // }

  void _editarFilaDesdet(DesDet detalle) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => PilaRegisterMtrScreen(
        folio: detalle.folio,
        nuevoFolio: false,
        folioExistente: detalle.folio,
        desdet: detalle, // 👈 Pasa el objeto completo
      ),
    ),
  ).then((value) {
    if (value != null && value is String) {
      _syncAndLoadData(); // Recarga al volver
    }
  });
}


//-------------------------- funcion para remover duplicados--------------------------------------

  List<DesDet> _removerDuplicadosPorReg(List<DesDet> lista) {
    final Set<String> registrosUnicos = {};
    final List<DesDet> resultado = [];

    for (var item in lista) {
      final clave = "${item.folio}_${item.reg}";
      if (!registrosUnicos.contains(clave)) {
        registrosUnicos.add(clave);
        resultado.add(item);
      }
    }

    return resultado;
  }

  Widget _buildDataTable() {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columnSpacing: 16,
          headingRowColor: WidgetStateProperty.all(
              const Color(0xFFFFCC00)), // Cambio por obsolescencia
          columns: const [
            DataColumn(label: Text("Acciones")),
            // DataColumn(label: Text("Folio")),
            DataColumn(label: Text("Marca")),
            DataColumn(label: Text("Modelo")),
            DataColumn(label: Text("Medida")),
            DataColumn(label: Text("Piso Remanente")),
            DataColumn(label: Text("Rango Carga")),
            DataColumn(label: Text("Origen")),
            DataColumn(label: Text("Marca renovada")),
            DataColumn(label: Text("Modelo renovado")),
            DataColumn(label: Text("Serie")),
            DataColumn(label: Text("Dot")),
            DataColumn(label: Text("Falla 1")),
            DataColumn(label: Text("Falla 2")),
            DataColumn(label: Text("Falla 3")),
            DataColumn(label: Text("Falla 4")),
            DataColumn(
                label: Text("Falla 5")), // 🔹 Se agregó la columna faltante
            DataColumn(label: Text("Año")),
            DataColumn(label: Text("F sistemas")),
          ],

          rows: detallesFolio.map((detalle) {
            final estaSincronizado = detalle.sincronizado == 1;

            return DataRow(
              color: WidgetStateProperty.resolveWith<Color?>(
                (Set<WidgetState> states) {
                  if (estaSincronizado)
                    return Colors.green.withOpacity(0.2); // Verde suave
                  return null; // Blanco por defecto
                },
              ),

              
              cells: [
                DataCell(Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit_note, color: Color.fromARGB(255, 10, 71, 150)),
                      tooltip: "Editar",
                      onPressed: () => _editarFilaDesdet(detalle),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      tooltip: "Eliminar",
                      onPressed: () => _eliminarFilaDesdet(detalle),
                    ),
                  ],
                )),
                // DataCell(Text(detalle.folio)),
                DataCell(Text(detalle.marca ?? "N/A")),
                DataCell(Text(detalle.modelo ?? "N/A")),
                DataCell(Text(detalle.medida ?? "N/A")),
                DataCell(Text(detalle.pisoRemanente?.toString() ?? "N/A")),
                DataCell(Text(detalle.rangoCarga ?? "N/A")),
                DataCell(Text(detalle.oriren?.toString() ?? "N/A")),
                DataCell(Text(detalle.marcaRen ?? "N/A")),
                DataCell(Text(detalle.modeloRen ?? "N/A")),
                DataCell(Text(detalle.serie?.toString() ?? "N/A")),
                DataCell(Text(detalle.dot?.toString() ?? "N/A")),
                DataCell(Text(detalle.falla1?.toString() ?? "N/A")),
                DataCell(Text(detalle.falla2?.toString() ?? "N/A")),
                DataCell(Text(detalle.falla3?.toString() ?? "N/A")),
                DataCell(Text(detalle.falla4?.toString() ?? "N/A")),
                DataCell(Text(detalle.falla5?.toString() ?? "N/A")),
                DataCell(Text(detalle.anio?.toString() ?? "N/A")),
                DataCell(Text(detalle.fsistema?.toString() ?? "N/A")),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  void _crearNuevoFormularioConMismoFolio() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PilaRegisterMtrScreen(
          folio: widget.folio,
          nuevoFolio: false,
        ),
      ),
    ).then((value) {
      if (value != null && value is String) {
        _syncAndLoadData(); // ✅ Refresca la tabla con los nuevos datos
      }
    });
  }

  String _safeString(dynamic value) {
    return (value == null || value.toString().trim().isEmpty)
        ? "null"
        : value.toString();
  }

  Map<String, dynamic> _convertirAFormatoJsonOrdenado(
      Map<String, dynamic> original) {
    Map<String, dynamic> nuevo = {};

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Folio: ${widget.folio}"),
        actions: [
          IconButton(
            icon: const Icon(Icons.note_add, color: Colors.blue),
            onPressed: _crearNuevoFormularioConMismoFolio,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : detallesFolio.isEmpty
              ? const Center(child: Text("No hay detalles disponibles"))
              : Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: _buildDataTable(),
                ),
    );
  }
}
