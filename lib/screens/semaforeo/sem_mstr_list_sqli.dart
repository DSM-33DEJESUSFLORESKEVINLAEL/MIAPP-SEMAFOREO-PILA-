import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:miapp/db/db_crud.dart';
import 'package:miapp/db/opciontablas.dart';
import 'package:miapp/screens/semaforeo/sem_mstr_register_screen.dart';
import 'package:miapp/services/api_service.dart';

class SemMstrListSqlScreen extends StatefulWidget {
  const SemMstrListSqlScreen({Key? key}) : super(key: key);

  @override
  State<SemMstrListSqlScreen> createState() => _SemMstrListSqlScreenState();
}

class _SemMstrListSqlScreenState extends State<SemMstrListSqlScreen> {
  List<Map<String, dynamic>> registros = [];
  List<Map<String, dynamic>> detalles = [];
  bool cargando = true;
  bool hayDatosLocalesPendientes = false;

  @override
  void initState() {
    super.initState();
    _asegurarCampoSincronizado();
    _cargarRegistros();
  }

  void _asegurarCampoSincronizado() async {
    final db = await DatabaseHelper.instance.database;
    try {
      await db.execute(
          "ALTER TABLE sem_det ADD COLUMN sincronizado INTEGER DEFAULT 0");
      debugPrint("✅ Campo 'sincronizado' agregado a sem_det");
    } catch (e) {
      debugPrint("ℹ️ Campo 'sincronizado' ya existe o error al agregarlo: $e");
    }
  }

  String formatField(dynamic value) {
    if (value == null ||
        value.toString().trim().isEmpty ||
        value.toString().trim().toLowerCase() == 'null') {
      return 'null'; // <-- Obligatorio para que el backend lo acepte
    }
    return value.toString().trim();
  }

  Map<String, String> construirJsonDesdeDetalle(
      Map<String, dynamic> mstr, Map<String, dynamic> det) {
    int sinLlanta = 0, sumaCero = 0, retiro = 0, proximoRetiro = 0;
    int buenas = 0, sumaO = 0, sumaR = 0, sumaMM = 0, nLlantas = 0;

    for (int i = 1; i <= 12; i++) {
      String mmStr = formatField(det['mm$i']);
      String obs = formatField(det['obs$i']).toUpperCase();
      String or = formatField(det['or$i']);
      int mm = int.tryParse(mmStr) ?? -1;

      final hasDatos = mmStr.isNotEmpty || obs.isNotEmpty;
      if (hasDatos) {
        nLlantas = i;
        if (mm > 0) sumaMM += mm;

        if (obs == 'SIN LLANTA') {
          sinLlanta++;
        } else {
          if (or == 'O') sumaO++;
          if (or == 'R') sumaR++;
        }

        if (mmStr == '0') {
          sumaCero++;
        } else if (mm != -1 && mm <= 3) {
          retiro++;
        } else if (mm >= 4 && mm <= 5) {
          proximoRetiro++;
        } else if (mm >= 6) {
          buenas++;
        }
      }
    }

    int mmPromedio = nLlantas > 0 ? (sumaMM ~/ nLlantas) : 0;

    final Map<String, String> json = {
      "FOLIO": formatField(mstr["folio"]),
      "USUARIO": formatField(det["usuario"]),
      "REG": formatField(det["reg"]),
      "OBS": formatField(det["obs"]),
      "FSISTEMA": formatField(mstr["fsistema"]),
      "SIN_LLANTA": "$sinLlanta",
      "CERO": "$sumaCero",
      "RETIRO": "$retiro",
      "PROX_RETIRO": "$proximoRetiro",
      "BUENAS": "$buenas",
      "ORIGINALES": "$sumaO",
      "RENOVADAS": "$sumaR",
      "NUM_LLANTAS": "$nLlantas",
      "MM_PROMEDIO": "$mmPromedio",
      "MM_SUMA": "$sumaMM",
      "EDO_UNIDAD": "1",
      "EMPRESA": formatField(mstr["empresa"]),
      "BASE": formatField(mstr["base"]),
      "UNIDAD": formatField(det["unidad"]),
      "TUNIDAD": formatField(det["tunidad"]),
      "MEDIDA_DIRECCION": formatField(det["medida_direccion"]),
      "MEDIDA_TRASERA": formatField(det["medida_trasera"]),
    };

    for (int i = 1; i <= 12; i++) {
      json["MM$i"] = formatField(det["mm$i"]);
      json["OR$i"] = formatField(det["or$i"]);
      json["OBS$i"] = formatField(det["obs$i"]);
      json["TMARCA$i"] = formatField(det["tmarca$i"]);
      json["DOT$i"] = formatField(det["dot$i"]);
      json["BIT$i"] = formatField(det["bit$i"]);
    }

    return json;
  }

  Future<void> _sincronizarDatos() async {
    final hasInternet = await AuthService().hasInternetConnection();
    if (!hasInternet) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ No hay conexión a internet')),
      );
      return;
    }

    final mstrList = await DBOperations.instance.queryAllRows('sem_mstr');
    final detList = await DBOperations.instance.queryAllRows('sem_det');

    for (var det in detList) {
      final reg = formatField(det['reg']);
      final folio = formatField(det['folio']);

      if (det['sincronizado'] == 1) {
        debugPrint("⏩ REG $reg del FOLIO $folio ya sincronizado. Se omite.");
        continue;
      }

      try {
        final mstr = mstrList.firstWhere(
          (m) => m['folio'].toString() == folio,
          orElse: () => {},
        );
        if (mstr.isEmpty) continue;

        final jsonContent = construirJsonDesdeDetalle(mstr, det);

        debugPrint("📤 Enviando sem_det: FOLIO $folio, REG $reg");
        debugPrint(jsonEncode(jsonContent));

        final response = await http.post(
          Uri.parse(
              "http://atlastoluca.dyndns.org:20100/datasnap/rest/TServerMethods1/Semaforeo"),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(jsonContent),
        );

        if (response.statusCode == 200) {
          final result = jsonDecode(response.body);
          if (!result.toString().contains("NO insertado")) {
            debugPrint(
                "✅ REG $reg del FOLIO $folio sincronizado correctamente");
            await DBOperations.instance.update(
              'sem_det',
              {'sincronizado': 1},
              'folio = ? AND reg = ?',
              [folio, reg],
            );
          } else {
            debugPrint("⚠️ REG $reg del FOLIO $folio no fue insertado");
          }
        } else {
          debugPrint("❌ Error al enviar REG $reg: \${response.body}");
        }
      } catch (e) {
        debugPrint("❌ Error con REG $reg del FOLIO $folio: $e");
      }
    }

    _cargarRegistros();
  }

  Future<void> _cargarRegistros() async {
    final data = await DBOperations.instance.queryAllRows('sem_mstr');
    final data1 = await DBOperations.instance.queryAllRows('sem_det');

    setState(() {
      registros = data;
      detalles = data1;
      cargando = false;
    });
  }

  String limpiar(dynamic valor) {
    if (valor == null || valor.toString().toLowerCase() == 'null') return '';
    return valor.toString();
  }

  // Future<void> _eliminarPorReg(String folio, String reg) async {
  //   final confirm = await showDialog<bool>(
  //     context: context,
  //     builder: (context) => AlertDialog(
  //       title: const Text("Confirmar eliminación"),
  //       content: Text("¿Deseas eliminar el REG $reg del folio $folio?"),
  //       actions: [
  //         TextButton(
  //             onPressed: () => Navigator.pop(context, false),
  //             child: const Text("Cancelar")),
  //         TextButton(
  //             onPressed: () => Navigator.pop(context, true),
  //             child: const Text("Eliminar")),
  //       ],
  //     ),
  //   );

  //   if (confirm != true) return;

  //   try {
  //     final int? regInt = int.tryParse(reg);
  //     if (regInt == null) {
  //       throw Exception("REG inválido");
  //     }

  //     await DBOperations.instance.deleteByWhere(
  //       'sem_det',
  //       'folio = ? AND reg = ?',
  //       [folio, regInt],
  //     );

  //     ScaffoldMessenger.of(context)
  //         .showSnackBar(SnackBar(content: Text("✅ REG $reg eliminado")));
  //     _cargarRegistros();
  //   } catch (e) {
  //     debugPrint("❌ Error al eliminar REG $reg: $e");
  //     ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(content: Text("❌ Error al eliminar registro")));
  //   }
  // }
  Future<void> _eliminarPorReg(String folio, String reg) async {
  final confirm = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text("Confirmar eliminación"),
      content: Text("¿Deseas eliminar el REG $reg del folio $folio?"),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancelar")),
        TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Eliminar")),
      ],
    ),
  );

  if (confirm != true) return;

  try {
    final int? regInt = int.tryParse(reg);
    if (regInt == null) throw Exception("REG inválido");

    // Obtener datos del registro actual
    final item = detalles.firstWhere(
        (element) => limpiar(element['folio']) == folio && limpiar(element['reg']) == reg);
    final sincronizado = item['sincronizado'] ?? 0;

    if (sincronizado == 1) {
      final String empresa = limpiar(item['empresa']);
      final String base = limpiar(item['base']);
      final String unidad = limpiar(item['unidad']);

      final url =
          'http://atlastoluca.dyndns.org:20100/datasnap/rest/TServerMethods1/Semaforeo/$empresa/$base/$folio/$unidad';
      final response = await http.delete(Uri.parse(url));

      if (response.statusCode != 200) {
        debugPrint("❌ No se pudo eliminar del servidor: ${response.body}");
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("❌ Error al eliminar en servidor")));
        return;
      }
    }

    // Eliminar de SQLite si fue exitoso en API o si era local
    await DBOperations.instance.deleteByWhere(
      'sem_det',
      'folio = ? AND reg = ?',
      [folio, regInt],
    );

    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("✅ REG $reg eliminado correctamente")));
    _cargarRegistros();
  } catch (e) {
    debugPrint("❌ Error al eliminar REG $reg: $e");
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ Error al eliminar registro")));
  }
}


  void _mostrarDetalleCompleto(Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Detalle REG ${item['reg']} - FOLIO ${item['folio']}"),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView(
              shrinkWrap: true,
              children: item.entries.map((e) {
                return ListTile(
                  title: Text(e.key.toUpperCase()),
                  subtitle: Text(e.value?.toString() ?? ''),
                );
              }).toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cerrar"),
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de Semáforeo'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add), // ícono de +
            tooltip: 'Nuevo registro',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SemaforoRegisterScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.outbox),
            color: hayDatosLocalesPendientes
                ? Colors.grey
                : const Color(0xFF01D436),
            tooltip: 'Sincronizar con servidor',
            onPressed: _sincronizarDatos,
          ),
        ],
      ),
      body: cargando
          ? const Center(child: CircularProgressIndicator())
          : detalles.isEmpty
              ? const Center(child: Text("No hay registros disponibles"))
              : RefreshIndicator(
                  onRefresh: _cargarRegistros,
                  child: ListView.builder(
                    itemCount: detalles.length,
                    itemBuilder: (context, index) {
                      final item = detalles[index];
                      final sincronizado = item['sincronizado'];
                      final folio = limpiar(item['folio']);
                      final reg = limpiar(item['reg']);

                      Color? bgColor;
                      if (sincronizado == 1) {
                        bgColor = Colors.green[100];
                      } else if (sincronizado == -1) {
                        bgColor = Colors.red[100];
                      } else {
                        bgColor = Colors.white;
                      }

                      return Card(
                        color: bgColor,
                        margin: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        child: ListTile(
                          onTap: () => _mostrarDetalleCompleto(item),
                          title: Text('Folio: $folio - REG: $reg'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Unidad: ${limpiar(item['unidad'])}'),
                              Text('Tipo Unidad: ${limpiar(item['tunidad'])}'),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (sincronizado == 1)
                                const Icon(Icons.check, color: Colors.green)
                              else if (sincronizado == -1)
                                const Icon(Icons.error, color: Colors.red),
                              // 🔧 Botón de editar
                              IconButton(
                                icon: const Icon(Icons.edit,
                                    color: Colors.blueAccent),
                                tooltip: 'Editar registro',
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          SemaforoRegisterScreen(
                                              registroAEditar: item),
                                    ),
                                  ).then((_) => _cargarRegistros());
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete,
                                    color: Colors.redAccent),
                                tooltip: 'Eliminar registro',
                                onPressed: () => _eliminarPorReg(folio, reg),
                              )
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
