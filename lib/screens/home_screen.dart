import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:animate_do/animate_do.dart'; // 🚀 Animaciones
import '../navigation/bottom_nav.dart';
import '../navigation/app_drawer.dart';
import 'profile_screen.dart';
import 'settings_screen.dart';
import '../db/db_crud.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  String? _currentUser;
  List<Map<String, dynamic>> bases = [];
  List<Map<String, dynamic>> semMstr = [];

  final Logger _logger = Logger();

  String empresa = "";
  String base = "";
  String nombreempresa = "";

  final List<Widget> _screens = [];

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadEmpresaBase();
    _screens.addAll([
      _buildWelcomeScreen(), // Pantalla de bienvenida con animaciones
      const ProfileScreen(),
      const SettingsScreen(),
    ]);
  }

  /// 🔹 **Carga empresa y base desde SharedPreferences**
  Future<void> _loadEmpresaBase() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userData = prefs.getString("userData");

    if (userData != null) {
      Map<String, dynamic> user = jsonDecode(userData);
      setState(() {
        nombreempresa = user["NOMBREEMPRESA"] ?? "Empresa desconocida";
        empresa = user["EMPRESA"] ?? "";
        base = user["BASE"] ?? "";
      });
      // _logger.i("🔹 Empresa y base cargadas: EMPRESA=$empresa, BASE=$base");
    } else {
      _logger.w("⚠️ No se encontraron datos de empresa y base en SharedPreferences.");
    }
  }

  /// 🔹 **Cargar usuario autenticado y sus datos**
  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _currentUser = prefs.getString('authenticated_user');

    if (_currentUser != null) {
      bases = await DBOperations.instance.getBasesForCurrentUser();
      semMstr = await DBOperations.instance.getSemMstrForCurrentUser();
    }

    setState(() {});
  }
void _onItemTapped(int index) {
  print("🔁 Cambiando a pestaña: $index");
  setState(() => _selectedIndex = index);
}
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      drawer: AppDrawer(onSelectItem: _onItemTapped),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNav(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }

  /// 🔹 **Pantalla de bienvenida con animaciones**
  Widget _buildWelcomeScreen() {
    return FadeIn(
      duration: const Duration(milliseconds: 500),
      child: SingleChildScrollView( // 🚀 Agregar scroll para evitar overflow
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),

              // 🔹 Animación en el título de bienvenida
              FadeInDown(
                duration: const Duration(milliseconds: 600),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Colors.blueAccent, Colors.blueAccent],
                    // colors: [Color.fromARGB(255, 255, 255, 255), Colors.blueAccent],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(color: const Color.fromARGB(66, 75, 74, 74), blurRadius: 5, offset: Offset(2, 4)),
                    ],
                  ),
                  child: const Text(
                    "¡Bienvenido a SALLC!",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 250, 250, 250),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ), 
              ),

              const SizedBox(height: 20),

              // 🔹 Animación en el icono
              Bounce(
                duration: const Duration(milliseconds: 800),
                child: const Icon(Icons.local_shipping, size: 80, color: Colors.amber),
              ),
              const SizedBox(height: 10),

              // 🔹 Animación en el texto principal
              FadeInLeft(
                duration: const Duration(milliseconds: 700),
                child: const Text(
                  "Sistema de Administración de Llantas para CEDIS (SALLC)",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.amber),
                ),
              ),

              const SizedBox(height: 10),

              FadeInLeft(
                duration: const Duration(milliseconds: 900),
                child: Text(
                  "Optimiza la gestión del inventario y mantenimiento de llantas en los Centros de Distribución (CEDIS), reduciendo costos y aumentando la seguridad en el transporte.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
                ),
              ),

              const SizedBox(height: 20),

              // 🔹 Animación en la tarjeta de información
              SlideInUp(
                duration: const Duration(milliseconds: 800),
                child: _buildInfoCard("¿Por qué usar SALLC?", [
                  "✔ Control en tiempo real del inventario de llantas.",
                  "✔ Monitoreo del desgaste con semáforo de estado.",
                  "✔ Gestión eficiente de la pila de desecho.",
                  "✔ Reportes automatizados para toma de decisiones.",
                ]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 🔹 **Método para construir una tarjeta con información**
  Widget _buildInfoCard(String title, List<String> points) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueAccent),
            ),
            const SizedBox(height: 8),
            Divider(),
            ...points.map((point) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.check_circle, color: Colors.green, size: 20),
                  const SizedBox(width: 8),
                  Expanded(child: Text(point, style: const TextStyle(fontSize: 16))),
                ],
              ),
            )).toList(),
          ],
        ),
      ),
    );
  }
}

