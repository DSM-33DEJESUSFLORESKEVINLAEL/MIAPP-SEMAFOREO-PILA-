import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key}); // Se agregó `super.key`

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Configuración', style: TextStyle(fontSize: 20)),
    );
  }
}
