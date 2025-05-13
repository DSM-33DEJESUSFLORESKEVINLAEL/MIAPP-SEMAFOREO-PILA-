import 'package:flutter/material.dart';
import 'package:miapp/navigation/app_drawer.dart';
import '../../../db/db_crud.dart';
import '../../../models/rango_carga.dart';

class RangoCargaListScreen extends StatefulWidget {
  const RangoCargaListScreen({super.key});

  @override
  RangoCargaListScreenState createState() => RangoCargaListScreenState();
}

class RangoCargaListScreenState extends State<RangoCargaListScreen> {
  List<RangoCarga> _rangosCarga = [];

  @override
  void initState() {
    super.initState();
    _loadRangosCarga();
  }

  void _loadRangosCarga() async {
    List<Map<String, dynamic>> data = await DBOperations.instance.queryAllRows('rango_carga');
    setState(() {
      _rangosCarga = data.map((item) => RangoCarga.fromMap(item)).toList();
    });
  }

  void _deleteRangoCarga(String rc) async {
    await DBOperations.instance.delete('rango_carga', 'rc', rc);
    _loadRangosCarga();
  }

/// 🔹 **Cambiar la pantalla seleccionada**
  void _onItemTapped(int index) {
    setState(() {
    });
    Navigator.pop(context); // ✅ Cierra el Drawer al seleccionar una opción
  }
 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AppDrawer(onSelectItem: _onItemTapped), // Asegurar que el Drawer está definido en Scaffold
      appBar: AppBar(
        title: const Text("Lista de Rangos de Carga"),
        actions: [
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: _rangosCarga.isEmpty
            ? const Center(child: Text("No hay rangos de carga registrados"))
            : SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columnSpacing: 20,
                  headingRowColor: WidgetStateProperty.all<Color>(const Color(0xFFFFCC00)),
                  columns: const [
                    DataColumn(label: Text("RC")),
                    DataColumn(label: Text("Descripción")),
                    DataColumn(label: Text("Acciones")),
                  ],
                  rows: _rangosCarga.map((rangoCarga) {
                    return DataRow(cells: [
                      DataCell(Text(rangoCarga.rc)),
                      DataCell(Text(rangoCarga.descripcion )),
                      DataCell(
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteRangoCarga(rangoCarga.rc),
                            ),
                          ],
                        ),
                      ),
                    ]);
                  }).toList(),
                ),
              ),
      ),
    );
  }
}
