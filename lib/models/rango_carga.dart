class RangoCarga {
  int empresa;
  String rc;
  String descripcion;

  RangoCarga({
    required this.empresa,
    required this.rc,
    required this.descripcion,
  });

  /// 🔹 Convierte un `Map` (de la BD) en un objeto `RangoCarga`
  factory RangoCarga.fromMap(Map<String, dynamic> map) {
    int empresaConvertida = 0;
    if (map.containsKey('empresa') && map['empresa'] != null) {
      empresaConvertida = int.tryParse(map['empresa'].toString().trim()) ?? 0;
    } else if (map.containsKey('EMPRESA') && map['EMPRESA'] != null) {
      empresaConvertida = int.tryParse(map['EMPRESA'].toString().trim()) ?? 0;
    }

    String rcConvertido =
        map['rc']?.toString().trim() ?? map['RC']?.toString().trim() ?? "Sin definir";

    String descripcionConvertida =
        map['descripcion']?.toString().trim() ?? map['DESCRIPCION']?.toString().trim() ?? "Sin descripción";

    return RangoCarga(
      empresa: empresaConvertida,
      rc: rcConvertido,
      descripcion: descripcionConvertida,
    );
  }

  /// 🔹 Convierte un objeto `RangoCarga` a un `Map` para almacenar en la BD
  Map<String, dynamic> toMap() {
    return {
      "empresa": empresa,
      "rc": rc,
      "descripcion": descripcion,
    };
  }

  /// 🔹 Convierte un JSON en un objeto `RangoCarga`
  factory RangoCarga.fromJson(Map<String, dynamic> json) {
    int empresaConvertida = json['EMPRESA'] is int
        ? json['EMPRESA']
        : int.tryParse(json['EMPRESA']?.toString().trim() ?? '0') ?? 0;

    String rcConvertido = json['RC']?.toString().trim() ?? "Sin definir";

    String descripcionConvertida = json['DESCRIPCION']?.toString().trim() ?? "Sin descripción";

    return RangoCarga(
      empresa: empresaConvertida,
      rc: rcConvertido,
      descripcion: descripcionConvertida,
    );
  }
}
