import 'package:flutter/material.dart';
import 'package:miapp/screens/catalogo/marca/marca_register_screen.dart';
import 'package:miapp/services/api_service.dart';
import '../../../db/db_crud.dart';
import '../../../models/marca.dart';
import 'package:miapp/navigation/app_drawer.dart';

class MarcaListScreen extends StatefulWidget {
  const MarcaListScreen({super.key});

  @override
  MarcaListScreenState createState() => MarcaListScreenState();
}

class MarcaListScreenState extends State<MarcaListScreen> {
  List<Marca> _marcas = [];
  bool _isLoading = true; // 🔹 Estado para mostrar el indicador de carga

  @override
  void initState() {
    super.initState();
    _loadMarcas();
  }

  void _loadMarcas() async {
    setState(() {
      _isLoading = true; // 🔄 Activar el estado de carga INMEDIATAMENTE
    });

    List<Map<String, dynamic>> marcasData =
        await DBOperations.instance.queryAllRows('marca');

    await Future.delayed(const Duration(
        milliseconds: 300)); // ⏳ Pequeño retraso para animación fluida

    setState(() {
      _marcas = marcasData.map((data) => Marca.fromMap(data)).toList();
      _isLoading = false; // ✅ Desactivar indicador de carga
    });
  }

  void deleteMarca(int id) async {
    await DBOperations.instance.delete('marca', 'id', id);
    _loadMarcas();
  }

  void updateMarca(int empresa, String nuevaMarca, String nuevaProcedencia) async {
  await DBOperations.instance.updateByWhere(
    'marca',
    {
      'marca': nuevaMarca,
      'procedencia': nuevaProcedencia,
      'sincronizado': 0, // 👈 Lo marcamos como no sincronizado otra vez
    },
    where: 'empresa = ? AND marca = ?',
    whereArgs: [empresa, nuevaMarca],
  );
  _loadMarcas(); // 🔄 Recarga la lista después de actualizar
}


 Future<void> _sincronizarMarcas() async {
  final authService = AuthService();
  final tieneInternet = await authService.hasInternetConnection();

  if (!tieneInternet) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("📴 Sin conexión. No se puede sincronizar.")),
    );
    return;
  }

  // Mostrar el mensaje de sincronización
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
          Text("Por favor espera mientras se sincronizan las marcas"),
        ],
      ),
    ),
  );

  final List<Map<String, dynamic>> marcasData =
      await DBOperations.instance.queryAllRows('marca');
  int enviados = 0;

  for (var data in marcasData) {
    final marca = Marca.fromMap(data);

    if (marca.sincronizado == 1) continue;

    final marcaStr = marca.marca;
    final empresaStr = marca.empresa.toString();
    final procedenciaStr =
        (marca.procedencia != null && marca.procedencia!.isNotEmpty)
            ? "'${marca.procedencia}'"
            : "'null'";

    final sql =
        "insert into marcas(MARCA,PROCEDENCIA,EMPRESA) values ('$marcaStr',$procedenciaStr,'$empresaStr')";

    final insertado = await authService.ejecutarSQLRemoto(sql);
    

    if (insertado) {
      enviados++;
      await DBOperations.instance.updateByWhere(
        'marca',
        {'sincronizado': 1},
        where: 'empresa = ? AND marca = ?',
        whereArgs: [marca.empresa, marca.marca],
      );
    }
  }

  // Cerrar el mensaje de sincronización
  Navigator.pop(context);

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text("✔ Sincronización completada: $enviados marcas enviadas"),
    ),
  );

  _loadMarcas();
}

  void _navigateToRegisterScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const MarcaRegisterScreen()),
    ).then((_) => _loadMarcas()); // 🔄 
  }

  void _onItemTapped(int index) {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AppDrawer(onSelectItem: _onItemTapped),
      appBar: AppBar(
        title: const Text("Lista de Marcas"),
        actions: [
          IconButton(
            icon: const Icon(Icons.sync, color: Colors.green),
            tooltip: 'Sincronizar marcas',
            onPressed: _sincronizarMarcas,
          ),
          IconButton(
            icon:
                const Icon(Icons.add, color: Color.fromARGB(255, 54, 14, 231)),
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
                    Text("Cargando datos...", style: TextStyle(fontSize: 16)),
                  ],
                ),
              )
              
            : _marcas.isEmpty
                ? const Center(child: Text("No hay marcas registradas"))
                : SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width * 1.2,
                        child: DataTable(
                          columnSpacing: 20,
                          headingRowColor: WidgetStateColor.resolveWith(
                            (states) => const Color(0xFFFFCC00),
                          ),
                          columns: [
                            DataColumn(label: Text("Marca")),
                            DataColumn(label: Text("Procedencia")),
                            DataColumn(label: Text("Acciones")),
                          ],
                          rows: _marcas.map((marca) {
                            final bool esSincronizada = marca.sincronizado == 1;

                            
                            return DataRow(
                              color: MaterialStateProperty.resolveWith<Color?>(
                                (states) =>
                                    esSincronizada ? Colors.blue[0] : null,
                              ),
                              cells: [
                                DataCell(Row(
                                  children: [
                                    Text(marca.marca),
                                    if (esSincronizada)
                                      const Padding(
                                        padding: EdgeInsets.only(left: 6),
                                        child: Icon(Icons.check,
                                            color: Colors.green, size: 18),
                                      ),
                                  ],
                                )),
                                DataCell(Text(marca.procedencia ?? 'N/A')),
                                DataCell(
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit,
                                            color: Colors.blue),
                                        onPressed: () => _showEditDialog(marca),
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

  void _showEditDialog(Marca marca) {
    TextEditingController marcaController =
        TextEditingController(text: marca.marca);
    TextEditingController procedenciaController =
        TextEditingController(text: marca.procedencia ?? '');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Actualizar Marca"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: marcaController,
                decoration: const InputDecoration(labelText: "Nueva Marca"),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: procedenciaController,
                decoration:
                    const InputDecoration(labelText: "Nueva Procedencia"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancelar"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFCC00),
              ),
              onPressed: () {
                updateMarca(marca.empresa, marcaController.text,
                    procedenciaController.text);
                Navigator.pop(context);
              },
              child: const Text("Actualizar",
                  style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }
}
