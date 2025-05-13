import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // 👈 necesario para inputFormatters
import 'package:miapp/screens/catalogo/marca/marca_list_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../db/db_crud.dart';
import '../../../models/marca.dart';
import 'package:miapp/navigation/app_drawer.dart';


class MarcaRegisterScreen extends StatefulWidget {
  const MarcaRegisterScreen({super.key});

  @override
  MarcaRegisterScreenState createState() => MarcaRegisterScreenState();
}

class MarcaRegisterScreenState extends State<MarcaRegisterScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _empresaController = TextEditingController();
  final TextEditingController _marcaController = TextEditingController();
  final TextEditingController _procedenciaController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
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
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation = _animationController.drive(CurveTween(curve: Curves.easeIn));
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _empresaController.dispose();
    _marcaController.dispose();
    _procedenciaController.dispose();
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



 /// 🔹 **Cambiar la pantalla seleccionada**
  void _onItemTapped(int index) {
    setState(() {
    });
    Navigator.pop(context); // ✅ Cierra el Drawer al seleccionar una opción
  }
 
 void _addMarca() async {
  int? empresaInt = int.tryParse(empresa.trim());
  if (empresaInt == null || _marcaController.text.trim().isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("⚠️ Verifica que los datos sean correctos. El campo 'marca' es obligatorio."),
      ),
    );
    return;
  }

  Marca newMarca = Marca(
      empresa: empresaInt,
      marca: _marcaController.text.trim().toUpperCase(), // 👈 asegura mayúsculas al guardar
      procedencia: _procedenciaController.text.trim().isNotEmpty
          ? _procedenciaController.text.trim().toUpperCase() // 👈 asegura mayúsculas al guardar
          : null,
      sincronizado: 0,
    );

  await DBOperations.instance.insert('marca', newMarca.toMap());

  _marcaController.clear();
  _procedenciaController.clear();

  if (!mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text("Marca agregada correctamente")),
  );

  Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (context) => const MarcaListScreen()),
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AppDrawer(onSelectItem: _onItemTapped),
      appBar: AppBar(
        title: const Text("Registrar Marca"),
        backgroundColor: const Color(0xFFFFCC00),
      ),
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
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
                    const Icon(Icons.local_offer_rounded, size: 48, color: Colors.orange),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _marcaController,
                      inputFormatters: [UpperCaseTextFormatter()],
                      decoration: const InputDecoration(
                        labelText: 'Marca',
                        prefixIcon: Icon(Icons.edit_note),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _procedenciaController,
                        inputFormatters: [UpperCaseTextFormatter()],
                      decoration: const InputDecoration(
                        labelText: 'Procedencia (opcional)',
                        prefixIcon: Icon(Icons.flag_outlined),
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
                          "Guardar Marca",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        onPressed: _addMarca,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
/// 🔤 Formateador personalizado para forzar texto en mayúsculas
class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    return newValue.copyWith(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}

