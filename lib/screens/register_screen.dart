import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:animate_do/animate_do.dart';
import '../db/db_crud.dart';
import '../models/user.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  RegisterScreenState createState() => RegisterScreenState();
}

class RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isRegistering = false;

  void _register() async {
    String username = usernameController.text;
    String password = passwordController.text;

    if (username.isEmpty || password.isEmpty) {
      _showAlert("Todos los campos son obligatorios.");
      return;
    }

    User newUser = User(username: username, password: password);
    try {
      await DBOperations.instance.insertUser(newUser);
      setState(() {
        isRegistering = true;
      });
      Future.delayed(const Duration(milliseconds: 1000), () {
        if (mounted) {
          context.go('/');
        }
      });
    } catch (e) {
      _showAlert("El usuario ya existe. Intenta con otro nombre.");
    }
  }

  void _showAlert(String message) {
    showDialog(
      context: context,
      builder:
          (context) => FadeIn(
            duration: const Duration(milliseconds: 500),
            child: AlertDialog(
              title: const Text("Mensaje"),
              content: Text(message),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("OK"),
                ),
              ],
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFFFCC00),
              Color(0xFFFAF7F7),
              Color(0xFFFFCC00),
            ], // Amarillo a blanco
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 700),
              curve: Curves.easeInOut,
              width: isRegistering ? 0 : 320,
              height: isRegistering ? 10 : null,
              child: BounceInDown(
                duration: const Duration(milliseconds: 1500),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        // ignore: deprecated_member_use
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FadeInDown(
                        duration: const Duration(milliseconds: 1200),
                        child: const Text(
                          "Registro",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      FadeInLeft(
                        duration: const Duration(milliseconds: 1400),
                        child: TextField(
                          controller: usernameController,
                          decoration: InputDecoration(
                            labelText: 'Usuario',
                            prefixIcon: const Icon(Icons.person),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      FadeInRight(
                        duration: const Duration(milliseconds: 1600),
                        child: TextField(
                          controller: passwordController,
                          decoration: InputDecoration(
                            labelText: 'Contraseña',
                            prefixIcon: const Icon(Icons.lock),
                            suffixIcon: const Icon(Icons.visibility),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          obscureText: true,
                        ),
                      ),
                      const SizedBox(height: 15),

                      FadeInUp(
                        duration: const Duration(milliseconds: 1800),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFFFFCC00),
                                Color(0xFFFFCC00),
                              ], // Amarillo a blanco
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(
                              10,
                            ), // Mantener bordes redondeados
                          ),
                          child: ElevatedButton(
                            onPressed: _register,
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  Colors
                                      .transparent, // Hace que el fondo sea el del Container
                              shadowColor:
                                  Colors
                                      .transparent, // Evita sombras de color sólido
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 30,
                                vertical: 12,
                              ),
                              child: Text(
                                "Registrar",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),
                      FadeInUp(
                        duration: const Duration(milliseconds: 2000),
                        child: TextButton(
                          onPressed: () => context.go('/'),
                          child: const Text(
                            "Regresar al Login",
                            style: TextStyle(
                              color: Color.fromARGB(255, 0, 0, 0),
                            ),
                          ),
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
