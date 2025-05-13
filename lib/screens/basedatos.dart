import 'dart:io';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sqflite/sqflite.dart';

class ExportarBDButton extends StatelessWidget {
  const ExportarBDButton({super.key});

  Future<void> _exportar(BuildContext context) async {
    try {
      // ✅ Pedimos permisos según la versión de Android
      bool tienePermiso = false;

      if (Platform.isAndroid) {
        if (await Permission.manageExternalStorage.isGranted) {
          tienePermiso = true;
        } else {
          final status = await Permission.manageExternalStorage.request();
          tienePermiso = status.isGranted;
        }
      }

      if (!tienePermiso) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('❌ Permiso denegado')),
        );
        return;
      }

      // ✅ Rutas
      final origen = '${await getDatabasesPath()}/app_database_v6.db';
      final destino = '/sdcard/Download/app_database_v6.db';

      final archivo = File(origen);
      if (!await archivo.exists()) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('❌ La base de datos no existe')),
        );
        return;
      }

      await archivo.copy(destino);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('✅ Exportado con éxito a: $destino')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Error exportando: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      icon: const Icon(Icons.download),
      label: const Text('Exportar Base de Datos'),
      onPressed: () => _exportar(context),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
