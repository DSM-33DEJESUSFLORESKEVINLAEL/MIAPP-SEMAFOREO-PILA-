// ignore_for_file: file_names

import 'dart:convert' show jsonEncode;
import 'package:shared_preferences/shared_preferences.dart';
/// 🔹 **Guarda los datos de empresa en localStorage**

Future<void> guardarEnLocalStorage(Map<String, dynamic> empresaData) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();

  Map<String, dynamic> user = {
    "EMPRESA": empresaData["EMPRESA"],
    "BASE": empresaData["BASE"],
    "SERIE": empresaData["SERIE"],
    "NOMBREUSUARIO": empresaData["NOMBREUSUARIO"],
    "NOMBREEMPRESA": empresaData["NOMBREEMPRESA"],
    "DESMONTAJE_INMEDIATO": empresaData["DESMONTAJE_INMEDIATO"],
    "DESMONTAJE_PROX_DESDE": empresaData["DESMONTAJE_PROX_DESDE"],
    "DESMONTAJE_PROX_HASTA": empresaData["DESMONTAJE_PROX_HASTA"],
    "BUENAS_CONDICIONES": empresaData["BUENAS_CONDICIONES"],
    "EMP_CTE": empresaData["EMP_CTE"],
    "CLIENTE": empresaData["CLIENTE"],
    "LUGAR": empresaData["LUGAR"],
    "GRUPO": empresaData["GRUPO"],
    "USUARIO": empresaData["USUARIO"],
    "OPERADOR":empresaData["OPERADOR"],
  };

  await prefs.setString("userData", jsonEncode(user));





}
