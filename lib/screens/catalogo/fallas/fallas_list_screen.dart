import 'package:flutter/material.dart';
import '../../../db/db_crud.dart';
import '../../../models/fallas.dart';
import 'package:miapp/navigation/app_drawer.dart';

class FallasListScreen extends StatefulWidget {
  const FallasListScreen({super.key});

  @override
  FallasListScreenState createState() => FallasListScreenState();
}

class FallasListScreenState extends State<FallasListScreen> {
  List<Fallas> _fallas = [];
  bool _isLoading = true; // 🔹 Estado para mostrar el indicador de carga

  @override
  void initState() {
    super.initState();
    _loadFallas();
  }

  void _loadFallas() async {
    setState(() {
      _isLoading = true; // 🔄 Activar el estado de carga INMEDIATAMENTE
    });

    List<Map<String, dynamic>> fallasData =
        await DBOperations.instance.queryAllRows('fallas');

    await Future.delayed(const Duration(milliseconds: 300)); // ⏳ Pequeño retraso para animación fluida

    setState(() {
      _fallas = fallasData.map((data) => Fallas.fromMap(data)).toList();
      _isLoading = false; // ✅ Desactivar indicador de carga
    });
  }

  void _deleteFalla(String falla) async {
    await DBOperations.instance.delete('fallas', 'falla', falla);
    _loadFallas();
  }

  /// 🔹 **Cambiar la pantalla seleccionada**
  void _onItemTapped(int index) {
    Navigator.pop(context); // ✅ Cierra el Drawer al seleccionar una opción
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AppDrawer(onSelectItem: _onItemTapped), // Drawer en Scaffold
      appBar: AppBar(
        title: const Text("Lista de Fallas"),
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
                    Text("Cargando fallas...", style: TextStyle(fontSize: 16)),
                  ],
                ),
              )
            : Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          columnSpacing: 20,
                          headingRowColor: WidgetStateColor.resolveWith(
                            (states) => const Color(0xFFFFCC00),
                          ),
                          columns: const [
                            DataColumn(label: Text("Falla")),
                            DataColumn(label: Text("Descripción")),
                            DataColumn(label: Text("Área")),
                            DataColumn(label: Text("Acciones")),
                          ],
                          rows: _fallas.map((falla) {
                            return DataRow(cells: [
                              DataCell(Text(falla.falla)),
                              DataCell(Text(falla.descripcion?.toString() ?? 'N/A')),
                              DataCell(Text(falla.area?.toString() ?? 'N/A')),
                              DataCell(
                                Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.delete, color: Colors.red),
                                      onPressed: () => _deleteFalla(falla.falla),
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
