import 'package:flutter/material.dart';
import 'package:miapp/navigation/app_drawer.dart';
import 'package:miapp/screens/basedatos.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String usuario = "";
  String empresa = "";
  String base = "";
  String nombreempresa = "";
  String nombreusuario = "";
  String puesto = "";
  String cliente = "";
  String lugar = "";
  String grupo = "";
  String desmontajeinmediato = "";
  String serie = "";
  String desmontajeProxDesde = "";
  String desmontajeProxHasta = "";
  String buenasCondiciones = "";
  String empCte = "";

  @override
  void initState() {
    super.initState();
    _loadEmpresaBase();
  }

  /// 🔹 **Carga empresa y base desde SharedPreferences**
  Future<void> _loadEmpresaBase() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userData = prefs.getString("userData");

    if (userData != null) {
      Map<String, dynamic> user = jsonDecode(userData);
      setState(() {
        empresa = user["EMPRESA"] ?? "";
        base = user["BASE"] ?? "";
        nombreempresa = user["NOMBREEMPRESA"] ?? "";
        nombreusuario = user["NOMBREUSUARIO"] ?? "";
        usuario = user["USUARIO"] ?? "";
        puesto = user["PUESTO"] ?? "";
        cliente = user["CLIENTE"] ?? "";
        lugar = user["LUGAR"] ?? "";
        grupo = user["GRUPO"] ?? "";
        desmontajeinmediato = user["DESMONTAJE_INMEDIATO"].toString();
        serie = user["SERIE"] ?? "";
        desmontajeProxDesde = user["DESMONTAJE_PROX_DESDE"].toString();
        desmontajeProxHasta = user["DESMONTAJE_PROX_HASTA"].toString();
        buenasCondiciones = user["BUENAS_CONDICIONES"].toString();
        empCte = user["EMP_CTE"].toString();
      });
      debugPrint("🔹 Datos cargados correctamente en ProfileScreen.");
    } else {
      debugPrint("⚠️ No se encontraron datos en SharedPreferences.");
    }
  }
  
  void _onItemTapped(int index) {
    Navigator.pop(context);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AppDrawer(onSelectItem: _onItemTapped),
      appBar: AppBar(title: const Text("Mi Perfil")),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 🔹 Avatar y nombre
              CircleAvatar(
                radius: 50,
                backgroundColor: Colors.blueAccent,
                child: Text(
                  usuario.isNotEmpty ? usuario[0].toUpperCase() : "?",
                  style: const TextStyle(fontSize: 40, color: Colors.white),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                nombreusuario,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              Text(
                puesto,
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 20),
              Divider(),

              // 🔹 Tarjeta de información personal
              _buildInfoCard("Datos Personales", [
                _buildInfoTile("Usuario", usuario),
                _buildInfoTile("Empresa", empresa),
                _buildInfoTile("Nombre Empresa", nombreempresa),
                _buildInfoTile("Base", base),
              ]),

              // 🔹 Tarjeta de datos de trabajo
              _buildInfoCard("Información de Trabajo", [
                _buildInfoTile("Cliente", cliente),
                _buildInfoTile("Lugar", lugar),
                _buildInfoTile("Grupo", grupo),
                _buildInfoTile("Desmontaje Inmediato", desmontajeinmediato),
                _buildInfoTile("Serie", serie),
                _buildInfoTile("Desmontaje Prox. Desde", desmontajeProxDesde),
                _buildInfoTile("Desmontaje Prox. Hasta", desmontajeProxHasta),
                _buildInfoTile("Buenas Condiciones", buenasCondiciones),
                _buildInfoTile("EMP CTE", empCte),
              ]),
              const SizedBox(height: 20),
              const ExportarBDButton(), // ⬅ Aquí se inserta el botón
            ],
          ),
        ),
      ),
      
    );
    
  }

  /// 🔹 Método para construir tarjetas con información
  Widget _buildInfoCard(String title, List<Widget> children) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            Divider(),
            ...children,
          ],
        ),
      ),
    );
  }

  /// 🔹 Método para construir cada elemento de la tarjeta
  Widget _buildInfoTile(String label, String value) {
    return ListTile(
      dense: true,
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(value.isNotEmpty ? value : "No disponible"),
      leading: const Icon(Icons.info_outline, color: Colors.blue),
    );
  }
}
