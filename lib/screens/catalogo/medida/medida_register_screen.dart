import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:miapp/screens/catalogo/medida/medida_list_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../db/db_crud.dart';
import '../../../models/medida.dart';
import 'package:miapp/navigation/app_drawer.dart';

class MedidaRegisterScreen extends StatefulWidget {
  const MedidaRegisterScreen({super.key});

  @override
  MedidaRegisterScreenState createState() => MedidaRegisterScreenState();
}

class MedidaRegisterScreenState extends State<MedidaRegisterScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _medidaController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  String usuario = "";
  String empresa = "";
  String base = "";
  String operador = "";


  @override
  void initState() {
    super.initState();
        _cargarDatosIniciales();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = CurvedAnimation(parent: _animationController, curve: Curves.easeIn);
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _medidaController.dispose();
    super.dispose();
  }


Future<void> _cargarDatosIniciales() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  String? userData = prefs.getString("userData");


  setState(() {
    if (userData != null) {
      Map<String, dynamic> user = jsonDecode(userData);
      usuario = user["USUARIO"] ?? "";
      empresa = user["EMPRESA"] ?? "";
      base = user["BASE"] ?? "";
      operador = user["OPERADOR"] ?? "";
    }

  });
}

  void _addMedida() async {
      int? empresaInt = int.tryParse(empresa.trim());
    if (empresaInt == null || _medidaController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("⚠️ El campo 'medida' es obligatorio.")),
      );
      return;
    }

    Medida newMedida = Medida(
      empresa: empresaInt, // Empresa no requerida
      medida: _medidaController.text.trim().toUpperCase(),
      sincronizado: 0,
    );

    await DBOperations.instance.insert('medida', newMedida.toMap());

    _medidaController.clear();

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Medida agregada correctamente")));

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const MedidaListScreen()),
    );
  }

  void _onItemTapped(int index) {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AppDrawer(onSelectItem: _onItemTapped),
      appBar: AppBar(
        title: const Text("Registrar Medida"),
        backgroundColor: const Color(0xFFFFCC00),
      ),
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Card(
                elevation: 10,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.straighten, size: 48, color: Colors.orange),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _medidaController,
                        inputFormatters: [UpperCaseTextFormatter()],
                        decoration: const InputDecoration(
                          labelText: 'Medida',
                          prefixIcon: Icon(Icons.edit_note),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 30),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFFCC00),
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: const Icon(Icons.save_alt),
                          label: const Text(
                            "Guardar Medida",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          onPressed: _addMedida,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 🔤 Formateador para forzar texto en mayúsculas
class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    return newValue.copyWith(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}
