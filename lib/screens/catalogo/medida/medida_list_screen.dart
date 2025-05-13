import 'package:flutter/material.dart';
import '../../../db/db_crud.dart';
import '../../../models/medida.dart';
import 'medida_register_screen.dart';
import 'package:miapp/navigation/app_drawer.dart';
import 'package:miapp/services/api_service.dart';

class MedidaListScreen extends StatefulWidget {
  const MedidaListScreen({super.key});

  @override
  MedidaListScreenState createState() => MedidaListScreenState();
}

class MedidaListScreenState extends State<MedidaListScreen> {
  List<Medida> _medidas = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMedidas();
  }

  void _loadMedidas() async {
    setState(() {
      _isLoading = true;
    });

    List<Map<String, dynamic>> medidasData = await DBOperations.instance.queryAllRows('medida');
    final uniqueMap = {
      for (var medida in medidasData) medida['medida']: medida
    };

    setState(() {
      _medidas = uniqueMap.values.map((data) => Medida.fromMap(data)).toList();
      _isLoading = false;
    });
  }

  void _showEditDialog(Medida medida) {
    TextEditingController medidaController = TextEditingController(text: medida.medida);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Actualizar Medida"),
          content: TextField(
            controller: medidaController,
            decoration: const InputDecoration(labelText: "Nueva Medida"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancelar"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFFCC00)),
              onPressed: () async {
                await DBOperations.instance.updateByWhere(
                  'medida',
                  {
                    'medida': medidaController.text.trim().toUpperCase(),
                    'sincronizado': 0,
                  },
                  where: 'empresa = ? AND medida = ?',
                  whereArgs: [medida.empresa, medida.medida],
                );
                Navigator.pop(context);
                _loadMedidas();
              },
              child: const Text("Actualizar", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _sincronizarMedidas() async {
    final authService = AuthService();
    final tieneInternet = await authService.hasInternetConnection();

    if (!tieneInternet) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("📴 Sin conexión. No se puede sincronizar.")),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        title: Text("Sincronizando..."),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text("Por favor espera mientras se sincronizan las medidas"),
          ],
        ),
      ),
    );

    final List<Map<String, dynamic>> medidasData = await DBOperations.instance.queryAllRows('medida');
    int enviados = 0;

    for (var data in medidasData) {
      final medida = Medida.fromMap(data);
      if (medida.sincronizado == 1) continue;

      final medidaStr = medida.medida;
      final empresaStr = medida.empresa.toString();
      final medidaEscapada = medidaStr.replaceAll("/", "*").replaceAll("'", "''");
      final sql = "INSERT INTO MEDIDAS (EMPRESA, MEDIDA) VALUES ('$empresaStr', '$medidaEscapada')";


      final insertado = await authService.ejecutarSQLRemoto(sql);
      //  print("🔎 SQL final: $sql");

      if (insertado) {
        enviados++;
        await DBOperations.instance.updateByWhere(
          'medida',
          {'sincronizado': 1},
          where: ' empresa = ? AND medida = ? ' ,
          whereArgs: [ medida.empresa,medida.medida],
        );
      }
    }

    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("✔ $enviados medida(s) sincronizadas")),
    );

    _loadMedidas();
  }

  void _navigateToRegisterScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const MedidaRegisterScreen()),
    ).then((_) => _loadMedidas());
  }

  void _onItemTapped(int index) {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AppDrawer(onSelectItem: _onItemTapped),
      appBar: AppBar(
        title: const Text("Lista de Medidas"),
        actions: [
          IconButton(
            icon: const Icon(Icons.sync, color: Colors.green),
            tooltip: 'Sincronizar medidas',
            onPressed: _sincronizarMedidas,
          ),
          IconButton(
            icon: const Icon(Icons.add, color: Color.fromARGB(255, 54, 14, 231)),
            onPressed: _navigateToRegisterScreen,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: _isLoading
            ? const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 10),
                    Text("Cargando medidas...", style: TextStyle(fontSize: 16)),
                  ],
                ),
              )
            : _medidas.isEmpty
                ? const Center(child: Text("No hay medidas registradas"))
                : SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width * 1.1,
                        child: DataTable(
                          columnSpacing: 30,
                          headingRowColor: WidgetStateColor.resolveWith(
                            (states) => const Color(0xFFFFCC00),
                          ),
                          columns: const [
                            DataColumn(label: Text("Medida", style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text("Acciones", style: TextStyle(fontWeight: FontWeight.bold))),
                          ],
                          rows: _medidas.map((medida) {
                            final esSincronizada = medida.sincronizado == 1;
                            return DataRow(
                              color: MaterialStateProperty.resolveWith<Color?>(
                                (states) => esSincronizada ? Colors.blue[50] : null,
                              ),
                              cells: [
                                DataCell(Row(
                                  children: [
                                    Text(medida.medida),
                                    if (esSincronizada)
                                      const Padding(
                                        padding: EdgeInsets.only(left: 6),
                                        child: Icon(Icons.check, color: Colors.green, size: 18),
                                      ),
                                  ],
                                )),
                                DataCell(
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit, color: Colors.blue),
                                        onPressed: () => _showEditDialog(medida),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
      ),
    );
  }
}
