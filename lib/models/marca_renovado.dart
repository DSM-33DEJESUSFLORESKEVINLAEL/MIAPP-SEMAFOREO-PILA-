class MarcaRenovado {
  int empresa;
  String marca;
  String descripcion;

  MarcaRenovado({
    required this.empresa,
    required this.marca,
    required this.descripcion,
  });

  /// 🔹 Convierte un `Map` (de la BD) en un objeto `MarcaRenovado`
  factory MarcaRenovado.fromMap(Map<String, dynamic> map) {
    int empresaConvertida = 0;
    if (map.containsKey('empresa') && map['empresa'] != null) {
      empresaConvertida = int.tryParse(map['empresa'].toString().trim()) ?? 0;
    } else if (map.containsKey('EMPRESA') && map['EMPRESA'] != null) {
      empresaConvertida = int.tryParse(map['EMPRESA'].toString().trim()) ?? 0;
    }

    String marcaConvertida =
        map['marca']?.toString().trim() ?? map['MARCA']?.toString().trim() ?? "Sin definir";

    String descripcionConvertida = 
        map['descripcion']?.toString().trim() ?? map['DESCRIPCION']?.toString().trim() ?? "Sin descripción";

    return MarcaRenovado(
      empresa: empresaConvertida,
      marca: marcaConvertida,
      descripcion: descripcionConvertida,
    );
  }

  /// 🔹 Convierte un objeto `MarcaRenovado` a un `Map` para almacenar en la BD
  Map<String, dynamic> toMap() {
    return {
      "empresa": empresa,
      "marca": marca,
      "descripcion": descripcion,
    };
  }

  /// 🔹 Convierte un JSON en un objeto `MarcaRenovado`
  factory MarcaRenovado.fromJson(Map<String, dynamic> json) {
    int empresaConvertida = json['EMPRESA'] is int
        ? json['EMPRESA']
        : int.tryParse(json['EMPRESA']?.toString().trim() ?? '0') ?? 0;

    String marcaConvertida = json['MARCA']?.toString().trim() ?? "Sin definir";

    String descripcionConvertida = json['DESCRIPCION']?.toString().trim() ?? "Sin descripción";

    return MarcaRenovado(
      empresa: empresaConvertida,
      marca: marcaConvertida,
      descripcion: descripcionConvertida,
    );
  }
}
