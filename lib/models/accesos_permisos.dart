class AccesoPermiso {
  int empresa;
  String base;
  String usuario;
  String acceso;

  AccesoPermiso({
    required this.empresa,
    required this.base,
    required this.usuario,
    required this.acceso,
  });

  /// 🔹 Convierte un `Map` (de la BD) en un objeto `AccesoPermiso`
  factory AccesoPermiso.fromMap(Map<String, dynamic> map) {
    int empresaConvertida = 0;
    if (map.containsKey('empresa') && map['empresa'] != null) {
      empresaConvertida = int.tryParse(map['empresa'].toString().trim()) ?? 0;
    } else if (map.containsKey('EMPRESA') && map['EMPRESA'] != null) {
      empresaConvertida = int.tryParse(map['EMPRESA'].toString().trim()) ?? 0;
    }

    String baseConvertida =
        map['base']?.toString().trim() ?? map['BASE']?.toString().trim() ?? "Sin definir";

    String usuarioConvertido =
        map['usuario']?.toString().trim() ?? map['USUARIO']?.toString().trim() ?? "Sin usuario";

    String accesoConvertido =
        map['acceso']?.toString().trim() ?? map['ACCESO']?.toString().trim() ?? "Sin acceso";

    return AccesoPermiso(
      empresa: empresaConvertida,
      base: baseConvertida,
      usuario: usuarioConvertido,
      acceso: accesoConvertido,
    );
  }

  /// 🔹 Convierte un objeto `AccesoPermiso` a un `Map` para almacenar en la BD
  Map<String, dynamic> toMap() {
    return {
      'empresa': empresa,
      'base': base,
      'usuario': usuario,
      'acceso': acceso,
    };
  }

  /// 🔹 Convierte un JSON en un objeto `AccesoPermiso`
  factory AccesoPermiso.fromJson(Map<String, dynamic> json) {
    int empresaConvertida = json['EMPRESA'] is int
        ? json['EMPRESA']
        : int.tryParse(json['EMPRESA']?.toString().trim() ?? '0') ?? 0;

    String baseConvertida = json['BASE']?.toString().trim() ?? "Sin definir";

    String usuarioConvertido = json['USUARIO']?.toString().trim() ?? "Sin usuario";

    String accesoConvertido = json['ACCESO']?.toString().trim() ?? "Sin acceso";

    return AccesoPermiso(
      empresa: empresaConvertida,
      base: baseConvertida,
      usuario: usuarioConvertido,
      acceso: accesoConvertido,
    );
  }
}
