import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:miapp/navigation/app_drawer.dart';
import '../../models/sem_mstr.dart';
import '../../services/api_service.dart';

class SemMstrListScreen extends StatefulWidget {
  const SemMstrListScreen({super.key});

  @override
  SemMstrListScreenState createState() => SemMstrListScreenState();
}

class SemMstrListScreenState extends State<SemMstrListScreen> {
  List<Semaforo> _semaforos = [];
  String selectedPeriodo = "Todos";
  final AuthService _authService = AuthService();

  final List<String> periodos = [
    "Todos",
    "Hoy",
    "Este mes",
    "Este año",
  ];

  @override
  void initState() {
    super.initState();
    _loadSemaforos();
  }

  int daysSinceBaseDate(DateTime date) {
    final baseDate = DateTime(1899, 12, 30);
    return date.difference(baseDate).inDays;
  }

  Map<String, int> _calcularRangoFechas(String periodo) {
    final now = DateTime.now();
    late DateTime f1, f2;

    switch (periodo) {
      case "Hoy":
        f1 = DateTime(now.year, now.month, now.day);
        f2 = f1;
        break;
      case "Este mes":
        f1 = DateTime(now.year, now.month, 1);
        f2 = DateTime(now.year, now.month + 1, 0);
        break;
      case "Este año":
        f1 = DateTime(now.year, 1, 1);
        f2 = DateTime(now.year, 12, 31);
        break;
      case "Todos":
      default:
        f1 = now.subtract(const Duration(days: 750));
        f2 = now;
        break;
    }

    return {
      'f1': daysSinceBaseDate(f1),
      'f2': daysSinceBaseDate(f2),
    };
  }

  void _loadSemaforos() async {
    final fechas = _calcularRangoFechas(selectedPeriodo);
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString("userData");

    if (userData == null) return;

    final Map<String, dynamic> user = jsonDecode(userData);
    final int empresa = int.parse(user["EMPRESA"]);
    final String base = user["BASE"];

    final List<Map<String, dynamic>> data = await _authService.getSemaforeo(
      empresa,
      base,
      fechas['f1']!,
      fechas['f2']!,
    );

    setState(() {
      _semaforos = data.map((e) => Semaforo.fromMap(e)).toList();
    });
  }

  

  void _onItemTapped(int index) {
    Navigator.pop(context);
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '';
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('dd/MM/yyyy').format(date);
    } catch (_) {
      return dateStr;
    }
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
              _loadSemaforos();
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

  Widget _buildDataTable() {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columnSpacing: 16,
          headingRowColor: WidgetStateProperty.all(const Color(0xFFFFCC00)),
          columns: const [
            DataColumn(label: Text("Folio", style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text("Fecha", style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text("Empresa", style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text("Base", style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text("Operador", style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text("Unidades", style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text("Llantas", style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text("Registros", style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text("Sin Llanta", style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text("Cero", style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text("Des. Inmediato", style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text("Des. Próximo", style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text("Buenas Cond.", style: TextStyle(fontWeight: FontWeight.bold))),
          ],
          rows: _semaforos.map((s) {
            return DataRow(
              cells: [
                DataCell(Text(s.folio)),
                DataCell(Text(_formatDate(s.fecha))),
                DataCell(Text(s.empresa.toString())),
                DataCell(Text(s.base)),
                DataCell(Text(s.operador ?? "")),
                DataCell(Text(s.nUnidades?.toString() ?? "")),
                DataCell(Text(s.nLlantas?.toString() ?? "")),
                DataCell(Text(s.nRegistros?.toString() ?? "")),
                DataCell(Text(s.sinLlanta.toString())),
                DataCell(Text(s.cero.toString())),
                DataCell(Text(s.desmontajeInmediato.toString())),
                DataCell(Text(s.desmontajeProximo.toString())),
                DataCell(Text(s.buenasCondiciones .toString())),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Tooltip(
          message: 'Actualizar',
          child: IconButton(
            icon: const Icon(Icons.refresh, color: Colors.blue),
            onPressed: _loadSemaforos,
          ),
        ),
        Tooltip(
          message: 'Agregar nuevo',
          child: IconButton(
            icon: const Icon(Icons.add, color: Colors.green),
            onPressed: () {
              // Acción de agregar aquí
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AppDrawer(onSelectItem: _onItemTapped),
      appBar: AppBar(title: const Text("Lista de Semáforos")),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(child: _buildDropdownPeriodo()),
                const SizedBox(width: 8),
                _buildActionButtons(),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: _semaforos.isEmpty
                  ? const Center(child: Text("No hay registros disponibles."))
                  : _buildDataTable(),
            ),
          ],
        ),
      ),
    );
  }
}
