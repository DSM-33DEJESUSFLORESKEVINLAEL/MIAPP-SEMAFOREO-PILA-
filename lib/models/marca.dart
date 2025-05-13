class Marca {
  int empresa;
  String marca;
  String? procedencia;
  int sincronizado;

  Marca({
    required this.empresa,
    required this.marca,
    required this.procedencia,
    required this.sincronizado,
  });

  /// 🔹 **Convierte un mapa de SQLite en un objeto `Marca`**
  factory Marca.fromMap(Map<String, dynamic> map) {

    int empresaConvertida = 0;
    if (map.containsKey('empresa') && map['empresa'] != null) {
      empresaConvertida = int.tryParse(map['empresa'].toString().trim()) ?? 0;
    } else if (map.containsKey('EMPRESA') && map['EMPRESA'] != null) {
      empresaConvertida = int.tryParse(map['EMPRESA'].toString().trim()) ?? 0;
    }

    String marcaConvertida = "";
    if (map.containsKey('marca') && map['marca'] != null) {
      marcaConvertida = map['marca'].toString().trim();
    } else if (map.containsKey('MARCA') && map['MARCA'] != null) {
      marcaConvertida = map['MARCA'].toString().trim();
    } else {
      marcaConvertida = "Sin nombre";
    }

    String? procedenciaConvertida;
    if (map.containsKey('procedencia') && map['procedencia'] != null) {
      procedenciaConvertida = map['procedencia'].toString().trim();
    } else if (map.containsKey('PROCEDENCIA') && map['PROCEDENCIA'] != null) {
      procedenciaConvertida = map['PROCEDENCIA'].toString().trim();
    } else {
      procedenciaConvertida = "Desconocida";
    }

      int sincronizadoConvertida = 0;
    if (map.containsKey('sincronizado') && map['sincronizado'] != null) {
      sincronizadoConvertida = int.tryParse(map['sincronizado'].toString().trim()) ?? 0;
    } else if (map.containsKey('SINCRONIZADO') && map['SINCRONIZADO'] != null) {
      sincronizadoConvertida = int.tryParse(map['SINCRONIZADO'].toString().trim()) ?? 0;
    }


    return Marca(
      empresa: empresaConvertida,
      marca: marcaConvertida,
      procedencia: procedenciaConvertida,
      sincronizado: sincronizadoConvertida,
    );
  }

  /// 🔹 **Convierte un objeto `Marca` a un mapa para SQLite**
  Map<String, dynamic> toMap() {
    return {
      'empresa': empresa,
      'marca': marca,
      'procedencia': procedencia,
      'sincronizado': sincronizado,
    };
  }

  /// 🔹 **Convierte un JSON en un objeto `Marca`**
  factory Marca.fromJson(Map<String, dynamic> json) {

    int empresaConvertida = json['EMPRESA'] is int
        ? json['EMPRESA']
        : int.tryParse(json['EMPRESA']?.toString().trim() ?? '0') ?? 0;

    String marcaConvertida = json['MARCA']?.toString().trim() ?? "Sin nombre";

    String? procedenciaConvertida;
    if (json.containsKey('PROCEDENCIA') && json['PROCEDENCIA'] != null) {
      procedenciaConvertida = json['PROCEDENCIA'].toString().trim();
    } else {
      procedenciaConvertida = "Desconocida";
    }

     int sincronizadoConvertida = json['SINCRONIZADO'] is int
        ? json['SINCRONIZADO']
        : int.tryParse(json['SINCRONIZADO']?.toString().trim() ?? '0') ?? 0;

    return Marca(
      empresa: empresaConvertida,
      marca: marcaConvertida,
      procedencia: procedenciaConvertida,
      sincronizado: sincronizadoConvertida,
    );
  }
}
