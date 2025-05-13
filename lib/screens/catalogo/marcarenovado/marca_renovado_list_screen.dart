import 'package:flutter/material.dart';
import '../../../db/db_crud.dart';
import '../../../models/marca_renovado.dart';
import 'package:miapp/navigation/app_drawer.dart';

class MarcaRenovadoListScreen extends StatefulWidget {
  const MarcaRenovadoListScreen({super.key});

  @override
  MarcaRenovadoListScreenState createState() => MarcaRenovadoListScreenState();
}

class MarcaRenovadoListScreenState extends State<MarcaRenovadoListScreen> {
  List<MarcaRenovado> _marcasRenovadas = [];
  bool _isLoading = true; // 🔹 Estado para mostrar el indicador de carga

  @override
  void initState() {
    super.initState();
    _loadMarcasRenovadas();
  }

  void _loadMarcasRenovadas() async {
    setState(() {
      _isLoading = true; // 🔄 Activar el estado de carga INMEDIATAMENTE
    });

    List<Map<String, dynamic>> marcaRenovadoData = await DBOperations.instance.queryAllRows('marca_renovado');
    await Future.delayed(const Duration(milliseconds: 300)); // ⏳ Pequeño retraso para animación fluida

    setState(() {
      _marcasRenovadas = marcaRenovadoData.map((item) => MarcaRenovado.fromMap(item)).toList();
      _isLoading = false; // ✅ Desactivar indicador de carga
    });
  }

  void _deleteMarcaRenovada(String marca) async {
    await DBOperations.instance.delete('marca_renovado', 'marca', marca);
    _loadMarcasRenovadas();
  }

  void _updateMarcaRenovada(String marca, String nuevaDescripcion) async {
    // await DBOperations.instance.update(
    //   'marca_renovado',
    //   {'descripcion': nuevaDescripcion},
    //   'marca',
    //   marca,
    // );
    _loadMarcasRenovadas();
  }

 

  void _onItemTapped(int index) {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AppDrawer(onSelectItem: _onItemTapped),
      appBar: AppBar(
        title: const Text("Lista de Marcas Renovadas"),
        actions: [
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
            : _marcasRenovadas.isEmpty
                ? const Center(child: Text("No hay marcas renovadas registradas"))
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
                            const DataColumn(label: Text("Marca")),
                            const DataColumn(label: Text("Descripción")),
                            const DataColumn(label: Text("Acciones")),
                          ],
                          rows: _marcasRenovadas.map((marcaRenovada) {
                            return DataRow(cells: [
                              DataCell(Text(marcaRenovada.marca)),
                              DataCell(Text(marcaRenovada.descripcion)),
                              DataCell(
                                Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit, color: Colors.blue),
                                      onPressed: () => _showEditDialog(marcaRenovada),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete, color: Colors.red),
                                      onPressed: () => _deleteMarcaRenovada(marcaRenovada.marca),
                                    ),
                                  ],
                                ),
                              ),
                            ]);
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
      ),
    );
  }

  void _showEditDialog(MarcaRenovado marcaRenovada) {
    TextEditingController descripcionController =
        TextEditingController(text: marcaRenovada.descripcion);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Actualizar Marca Renovada"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: descripcionController,
                decoration: const InputDecoration(labelText: "Nueva Descripción"),
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
                _updateMarcaRenovada(marcaRenovada.marca, descripcionController.text);
                Navigator.pop(context);
              },
              child: const Text("Actualizar", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }
}
