import 'package:flutter/material.dart';
import 'package:miapp/navigation/app_drawer.dart';
import '../../../db/db_crud.dart';
import '../../../models/tipo_unidad.dart';

class TipoUnidadListScreen extends StatefulWidget {
  const TipoUnidadListScreen({super.key});

  @override
  TipoUnidadListScreenState createState() => TipoUnidadListScreenState();
}

class TipoUnidadListScreenState extends State<TipoUnidadListScreen> {
  List<TipoUnidad> _tiposUnidad = [];

  @override
  void initState() {
    super.initState();
    _loadTiposUnidad();
  }

  void _loadTiposUnidad() async {
    List<Map<String, dynamic>> data = await DBOperations.instance.queryAllRows('tipo_unidad');
    setState(() {
      _tiposUnidad = data.map((item) => TipoUnidad.fromMap(item)).toList();
    });
  }

  void _deleteTipoUnidad(String tunidad) async {
    await DBOperations.instance.delete('tipo_unidad', 'tunidad', tunidad);
    _loadTiposUnidad();
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
        title: const Text("Lista de Tipos de Unidad"),
        actions: [
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: _tiposUnidad.isEmpty
            ? const Center(child: Text("No hay tipos de unidad registrados"))
            : SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columnSpacing: 20,
                  headingRowColor: WidgetStateProperty.all<Color>(const Color(0xFFFFCC00)),
                  columns: const [
                    DataColumn(label: Text("Tipo Unidad")),
                    DataColumn(label: Text("Acciones")),
                  ],
                  rows: _tiposUnidad.map((tipoUnidad) {
                    return DataRow(cells: [
                      DataCell(Text(tipoUnidad.tunidad)),
                      DataCell(
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteTipoUnidad(tipoUnidad.tunidad),
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
