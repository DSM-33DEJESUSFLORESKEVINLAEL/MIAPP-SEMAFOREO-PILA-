import 'package:flutter/material.dart';
import 'package:miapp/navigation/app_drawer.dart';
import '../../../db/db_crud.dart';
import '../../../models/modelo_renovado.dart';

class ModeloRenovadoListScreen extends StatefulWidget {
  const ModeloRenovadoListScreen({super.key});

  @override
  ModeloRenovadoListScreenState createState() => ModeloRenovadoListScreenState();
}

class ModeloRenovadoListScreenState extends State<ModeloRenovadoListScreen> {
  List<ModeloRenovado> _modelosRenovados = [];

  @override
  void initState() {
    super.initState();
    _loadModelosRenovados();
  }

//  void _loadModelosRenovados() async {
//   List<Map<String, dynamic>> data = await DBOperations.instance.queryAllRows('modelo_renovado');
//   setState(() {
//     _modelosRenovados.clear(); // 🔹 Limpia la lista antes de volver a cargar
//     _modelosRenovados = data.map((item) => ModeloRenovado.fromMap(item)).toList();
//   });
// }

void _loadModelosRenovados() async {
  List<Map<String, dynamic>> data = await DBOperations.instance.queryAllRows('modelo_renovado');
  
  // Convertimos a objetos y eliminamos duplicados por 'modelo'
  final modelos = data.map((item) => ModeloRenovado.fromMap(item)).toList();

  final modelosUnicos = <String, ModeloRenovado>{};
  for (var modelo in modelos) {
    modelosUnicos[modelo.modelo] = modelo; // Sobrescribe si hay duplicado
  }

  setState(() {
    _modelosRenovados = modelosUnicos.values.toList();
  });
}

  void _deleteModeloRenovado(String modelo) async {
    await DBOperations.instance.delete('modelo_renovado', 'modelo', modelo);
    _loadModelosRenovados();
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
    drawer: AppDrawer(onSelectItem: _onItemTapped),
    appBar: AppBar(
      title: const Text("Lista de Modelos Renovados"),
      actions: [],
    ),
    body: Padding(
      padding: const EdgeInsets.all(8.0),
      child: _modelosRenovados.isEmpty
          ? const Center(child: Text("No hay modelos renovados registrados"))
          : Column(
              children: [
                const SizedBox(height: 10),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columnSpacing: 20,
                        headingRowColor: WidgetStateProperty.all<Color>(Color(0xFFFFCC00)),
                        columns: const [
                          DataColumn(label: Text("Modelo")),
                          DataColumn(label: Text("Descripción")),
                          DataColumn(label: Text("Acciones")),
                        ],
                        rows: _modelosRenovados.map((modeloRenovado) {
                          return DataRow(cells: [
                            DataCell(Text(modeloRenovado.modelo)),
                            DataCell(Text(modeloRenovado.descripcion)),
                            DataCell(
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    onPressed: () =>
                                        _deleteModeloRenovado(modeloRenovado.modelo),
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
              ],
            ),
    ),
  );
}

}
