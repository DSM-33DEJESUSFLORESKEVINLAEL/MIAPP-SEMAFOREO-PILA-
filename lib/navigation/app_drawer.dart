// © 2025 Kevin Lael de Jesús Flores
// Todos los derechos reservados.
// Este código es parte de la aplicación [Mi app].
// Prohibida su reproducción o distribución sin autorización.

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:animate_do/animate_do.dart';
import 'package:logger/logger.dart';
import 'package:miapp/screens/piladesecho/piladesecho_list_screen.dart';
import 'package:miapp/screens/profile_screen.dart';
import 'package:miapp/screens/semaforeo/sem_mstr_list_sqli.dart';
import 'package:miapp/screens/semaforeo/sem_mstr_register_screen.dart';
import 'package:miapp/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../screens/catalogo/fallas/fallas_list_screen.dart';
import '../screens/catalogo/marca/marca_register_screen.dart';
import '../screens/catalogo/marca/marca_list_screen.dart';
import '../screens/catalogo/marcarenovado/marca_renovado_list_screen.dart';
import '../screens/catalogo/medida/medida_register_screen.dart';
import '../screens/catalogo/medida/medida_list_screen.dart';
import '../screens/catalogo/modelorenovado/modelo_renovado_list_screen.dart';
import '../screens/catalogo/rangocarga/rango_carga_list_screen.dart';
import '../screens/catalogo/tipounidad/tipo_unidad_list_screen.dart';
import '../screens/catalogo/unidades/unidades_list_screen.dart';

class AppDrawer extends StatefulWidget {
  final Function(int) onSelectItem;
  const AppDrawer({super.key, required this.onSelectItem});

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  final Logger _logger = Logger();
  String empresa = "";
  String base = "";
  String nombreusuario = "";

  @override
  void initState() {
    super.initState();
    _loadEmpresaBase();
  }

  Future<void> _loadEmpresaBase() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userData = prefs.getString("userData");

    if (userData != null) {
      Map<String, dynamic> user = jsonDecode(userData);
      setState(() {
        empresa = user["EMPRESA"] ?? "";
        base = user["BASE"] ?? "";
        nombreusuario = user["NOMBREUSUARIO"] ?? "";
      });
    } else {
      _logger.w("⚠️ No se encontraron datos de empresa y base en SharedPreferences.");
    }
  }

  void navigateWithOrientation({
    required BuildContext context,
    required Widget screen,
    bool landscape = false,
  }) async {
    Navigator.pop(context);

    if (landscape) {
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => screen),
    ).then((_) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SlideInLeft(
      duration: const Duration(milliseconds: 100),
      child: Drawer(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 10,
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 20),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.amber, Colors.amber],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, size: 40, color: Colors.blueAccent),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    nombreusuario,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "Base: $base",
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

            // 🔹 Contenido desplazable del Drawer
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    /// 📌 **Opción: Inicio**
                    FadeInLeft(
                      delay: const Duration(milliseconds: 200),
                      child: ListTile(
                        leading: const Icon(Icons.home),
                        title: const Text("Inicio"),
                        onTap: () {
                          FocusScope.of(context).unfocus();
                          Navigator.pop(context);
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            if (context.mounted) {
                              context.go('/home');
                            }
                          });
                        },
                      ),
                    ),
                    FadeInLeft(
                      delay: const Duration(milliseconds: 300),
                      child: ListTile(
                        leading: const Icon(Icons.system_update_alt),
                        title: const Text("Actualizar Catálogos"),
                        onTap: () {
                          final scaffoldContext = context;
                          Navigator.pop(context); // 1. Cierra el Drawer

                          // 2. Espera que se cierre completamente el Drawer antes de navegar y actualizar
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            if (context.mounted) {
                              context.go(
                                  '/home'); // 🔹 3. Navega inmediatamente a /home

                              // 4. Luego de navegar, ejecuta la actualización
                              Future.delayed(const Duration(milliseconds: 300),
                                  () async {
                                final exito = await AuthService()
                                    .actualizarCatalogosDesdeApi();

                                if (scaffoldContext.mounted) {
                                  ScaffoldMessenger.of(scaffoldContext)
                                      .showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        exito
                                            ? "✅ Catálogos actualizados"
                                            : "❌ Error al actualizar catálogos",
                                      ),
                                    ),
                                  );
                                }
                              });
                            }
                          });
                        },
                      ),
                    ),

                    /// 📌 **Submenú: Catálogo**
                    FadeInLeft(
                      delay: const Duration(milliseconds: 400),
                      child: ExpansionTile(
                        leading: const Icon(Icons.category),
                        title: const Text("Catálogos"),
                        children: [
                          /// 📂 Fallas
                          _buildExpansionTile(context, "Fallas", [
                            _buildListTile(
                                context, "Lista de Fallas", FallasListScreen()),
                          ]),

                          /// 📂 Marca
                          _buildExpansionTile(context, "Marca", [
                            _buildListTile(context, "Registrar Marca",
                                MarcaRegisterScreen()),
                            _buildListTile(
                                context, "Lista de Marcas", MarcaListScreen()),
                          ]),

                          /// 📂 Marca Renovado
                          _buildExpansionTile(context, "Marca Renovado", [
                            _buildListTile(context, "Lista de Marca Renovado",
                                MarcaRenovadoListScreen()),
                          ]),

                          /// 📂 Medida
                          _buildExpansionTile(context, "Medida", [
                            _buildListTile(context, "Registrar Medida",
                                MedidaRegisterScreen()),
                            _buildListTile(context, "Lista de Medidas",
                                MedidaListScreen()),
                          ]),

                          /// 📂 Modelo Renovado
                          _buildExpansionTile(context, "Modelo Renovado", [
                            _buildListTile(context, "Lista de Modelo Renovado",
                                ModeloRenovadoListScreen()),
                          ]),

                          /// 📂 Rango Carga
                          _buildExpansionTile(context, "Rango Carga", [
                            _buildListTile(context, "Lista de Rango Carga",
                                RangoCargaListScreen()),
                          ]),

                          /// 📂 Tipo Unidad
                          _buildExpansionTile(context, "Tipo Unidad", [
                            _buildListTile(context, "Lista de Tipo Unidad",
                                TipoUnidadListScreen()),
                          ]),

                          /// 📂 Unidades
                          _buildExpansionTile(context, "Unidades", [
                            _buildListTile(context, "Lista de Unidades",
                                UnidadesListScreen()),
                          ]),
                        ],
                      ),
                    ),

                    /// 📌 **Submenú: Pila de desecho**

                    FadeInLeft(
                      delay: const Duration(milliseconds: 500),
                      child: ExpansionTile(
                        leading: const Icon(Icons.tire_repair),
                        title: const Text("Pila de desecho"),
                        children: [
                          ListTile(
                            leading: const Icon(Icons.add),
                            title: const Text("Listado"),
                            onTap: () {
                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const PiladesechoListScreen()),
                              );
                            },
                          ),
                        ],
                      ),
                    ),

                    /// 📌 **Submenú: Semaforeo**
                    FadeInLeft(
                      delay: const Duration(milliseconds: 600),
                      child: ExpansionTile(
                        leading: const Icon(Icons.traffic),
                        title: const Text("Semaforeo"),
                        children: [
                          ListTile(
                              leading: const Icon(Icons.add),
                              title: const Text("Registrar Semáforo"),
                              onTap: () {
                                navigateWithOrientation(
                                  context: context,
                                  screen: const SemaforoRegisterScreen(),
                                  // landscape: true, // <- activa horizontal para esta pantalla
                                  landscape: false,
                                );
                              }),
                              // ListTile(
                              // leading: const Icon(Icons.add),
                              // title: const Text("Lista Semáforo"),
                              // onTap: () {
                              //   navigateWithOrientation(
                              //     context: context,
                              //     screen: const SemMstrListScreen(),
                              //     // landscape: true, // <- activa horizontal para esta pantalla
                              //     landscape: false,
                              //   );
                              // }),
                          ListTile(
                              leading: const Icon(Icons.add),
                              title: const Text("Lista Semáforeo"),
                              onTap: () {
                                navigateWithOrientation(
                                  context: context,
                                  screen: const SemMstrListSqlScreen(),
                                  landscape: false,
                                );
                              }),
                        ],
                      ),
                    ),

                    /// 📌 **Opción: perfil**
                    FadeInLeft(
                      delay: const Duration(milliseconds: 700),
                      child: ListTile(
                          leading: const Icon(Icons.person),
                          title: const Text("Perfil"),
                          onTap: () {
                            navigateWithOrientation(
                              context: context,
                              screen: const ProfileScreen(),
                              landscape: false,
                            );
                          }),
                    ),

                  
                    FadeInLeft(
                      delay: const Duration(milliseconds: 800),
                      child: ListTile(
                        leading: const Icon(Icons.exit_to_app),
                        title: const Text("Cerrar Sesión"),
                        onTap: () async {
                          final prefs = await SharedPreferences.getInstance();
                          await prefs.setBool('loggedIn',
                              false); // ✅ Borra la bandera de sesión iniciada
                            await prefs.setBool('datosSincronizados', false); // 🔄 Para forzar sincronización en nuevo login

                          context.go('/'); // ✅ Regresa a login
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListTile(BuildContext context, String title, Widget screen) {
    return ListTile(
      leading: const Icon(Icons.arrow_right),
      title: Text(title),
      onTap: () async {
        Navigator.pop(context);

        // Restaurar orientación vertical (por si venimos de pantalla en landscape)
        await SystemChrome.setPreferredOrientations([
          DeviceOrientation.portraitUp,
          DeviceOrientation.portraitDown,
        ]);

        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => screen),
        );
      },
    );
  }

  /// 🔹 **Método para construir un `ExpansionTile` genérico**
  Widget _buildExpansionTile(
      BuildContext context, String title, List<Widget> children) {
    return ExpansionTile(
      leading: const Icon(Icons.folder),
      title: Text(title),
      children: children,
    );
  }
}
