import 'package:flutter/material.dart';

class BottomNav extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;
  final bool showNavigation; // 🔹 Nuevo parámetro para controlar visibilidad

  const BottomNav({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
    this.showNavigation = false, // 🔹 Por defecto se muestran los botontab
  });

  @override
  Widget build(BuildContext context) {
    return showNavigation
        ? BottomNavigationBar(
            currentIndex: selectedIndex,
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: "Inicio"),
              BottomNavigationBarItem(icon: Icon(Icons.person), label: "Perfil"),
            ],
            onTap: onItemTapped,
          )
        : const SizedBox.shrink(); // 🔹 No muestra nada si showNavigation es false
  }
}
