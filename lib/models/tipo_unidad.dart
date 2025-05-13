class TipoUnidad {
  int empresa;
  String tunidad;

  TipoUnidad({
    required this.empresa,
    required this.tunidad,
  });

  /// 🔹 Convierte un `Map` (de la BD) en un objeto `TipoUnidad`
  factory TipoUnidad.fromMap(Map<String, dynamic> map) {
    int empresaConvertida = 0;
    if (map.containsKey('empresa') && map['empresa'] != null) {
      empresaConvertida = int.tryParse(map['empresa'].toString().trim()) ?? 0;
    } else if (map.containsKey('EMPRESA') && map['EMPRESA'] != null) {
      empresaConvertida = int.tryParse(map['EMPRESA'].toString().trim()) ?? 0;
    }

    String tunidadConvertida = map['tunidad']?.toString().trim() ??
        map['TUNIDAD']?.toString().trim() ??
        "Sin definir";

    return TipoUnidad(
      empresa: empresaConvertida,
      tunidad: tunidadConvertida,
    );
  }

  /// 🔹 Convierte un objeto `TipoUnidad` a un `Map` para almacenar en la BD
  Map<String, dynamic> toMap() {
    return {
      "empresa": empresa,
      "tunidad": tunidad,
    };
  }

  /// 🔹 Convierte un JSON en un objeto `TipoUnidad`
  factory TipoUnidad.fromJson(Map<String, dynamic> json) {
    int empresaConvertida = json['EMPRESA'] is int
        ? json['EMPRESA']
        : int.tryParse(json['EMPRESA']?.toString().trim() ?? '0') ?? 0;

    String tunidadConvertida = json['TUNIDAD']?.toString().trim() ?? "Sin definir";

    return TipoUnidad(
      empresa: empresaConvertida,
      tunidad: tunidadConvertida,
    );
  }
}
