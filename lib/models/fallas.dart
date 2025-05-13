class Fallas {
  int empresa;
  String falla;
  String? descripcion;
  String? area;

  Fallas({
    required this.empresa,
    required this.falla,
    this.descripcion,
    this.area,
  });

  /// 🔹 Convierte un `Map` (de la BD) en un objeto `Fallas`
  factory Fallas.fromMap(Map<String, dynamic> map) {
    int empresaConvertida = 0;
    if (map.containsKey('empresa') && map['empresa'] != null) {
      empresaConvertida = int.tryParse(map['empresa'].toString().trim()) ?? 0;
    } else if (map.containsKey('EMPRESA') && map['EMPRESA'] != null) {
      empresaConvertida = int.tryParse(map['EMPRESA'].toString().trim()) ?? 0;
    }

    String fallaConvertida = map['falla']?.toString().trim() ??
        map['FALLA']?.toString().trim() ??
        "Sin definir";

    String? descripcionConvertida = map['descripcion']?.toString().trim() ??
        map['DESCRIPCION']?.toString().trim();

    String? areaConvertida =
        map['area']?.toString().trim() ?? map['AREA']?.toString().trim();

    return Fallas(
      empresa: empresaConvertida,
      falla: fallaConvertida,
      descripcion: descripcionConvertida,
      area: areaConvertida,
    );
  }

  /// 🔹 Convierte un objeto `Fallas` a un `Map` para almacenar en la BD
  Map<String, dynamic> toMap() {
    return {
      "empresa": empresa,
      "falla": falla,
      "descripcion": descripcion,
      "area": area,
    };
  }

  /// 🔹 Convierte un JSON en un objeto `Fallas`
  factory Fallas.fromJson(Map<String, dynamic> json) {
    int empresaConvertida = json['EMPRESA'] is int
        ? json['EMPRESA']
        : int.tryParse(json['EMPRESA']?.toString().trim() ?? '0') ?? 0;

    String fallaConvertida = json['FALLA']?.toString().trim() ?? "Sin definir";

    String? descripcionConvertida =
        json['DESCRIPCION']?.toString().trim();

    String? areaConvertida = json['AREA']?.toString().trim();

    return Fallas(
      empresa: empresaConvertida,
      falla: fallaConvertida,
      descripcion: descripcionConvertida,
      area: areaConvertida,
    );
  }
}
