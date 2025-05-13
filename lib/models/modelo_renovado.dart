class ModeloRenovado {
  int empresa;
  String modelo;
  String descripcion;

  ModeloRenovado({
    required this.empresa,
    required this.modelo,
    required this.descripcion,
  });

  /// 🔹 Convierte un `Map` (de la BD) en un objeto `ModeloRenovado`
  factory ModeloRenovado.fromMap(Map<String, dynamic> map) {
    int empresaConvertida = 0;
    if (map.containsKey('empresa') && map['empresa'] != null) {
      empresaConvertida = int.tryParse(map['empresa'].toString().trim()) ?? 0;
    } else if (map.containsKey('EMPRESA') && map['EMPRESA'] != null) {
      empresaConvertida = int.tryParse(map['EMPRESA'].toString().trim()) ?? 0;
    }

    String modeloConvertido =
        map['modelo']?.toString().trim() ?? map['MODELO']?.toString().trim() ?? "Sin definir";

    String descripcionConvertida =
        map['descripcion']?.toString().trim() ?? map['DESCRIPCION']?.toString().trim() ?? "Sin descripción";

    return ModeloRenovado(
      empresa: empresaConvertida,
      modelo: modeloConvertido,
      descripcion: descripcionConvertida,
    );
  }

  /// 🔹 Convierte un objeto `ModeloRenovado` a un `Map` para almacenar en la BD
  Map<String, dynamic> toMap() {
    return {
      "empresa": empresa,
      "modelo": modelo,
      "descripcion": descripcion,
    };
  }

  /// 🔹 Convierte un JSON en un objeto `ModeloRenovado`
  factory ModeloRenovado.fromJson(Map<String, dynamic> json) {
    int empresaConvertida = json['EMPRESA'] is int
        ? json['EMPRESA']
        : int.tryParse(json['EMPRESA']?.toString().trim() ?? '0') ?? 0;

    String modeloConvertido = json['MODELO']?.toString().trim() ?? "Sin definir";

    String descripcionConvertida = json['DESCRIPCION']?.toString().trim() ?? "Sin descripción";

    return ModeloRenovado(
      empresa: empresaConvertida,
      modelo: modeloConvertido,
      descripcion: descripcionConvertida,
    );
  }
}
