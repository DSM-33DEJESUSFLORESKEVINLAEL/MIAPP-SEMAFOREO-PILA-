class Medida {
  int empresa;
  String medida;
  int sincronizado;


  Medida({required this.empresa, required this.medida,required this.sincronizado,
});

  /// 🔹 **Convierte un mapa de SQLite en un objeto `Medida`**
  factory Medida.fromMap(Map<String, dynamic> map) {

    int empresaConvertida = 0;
    if (map.containsKey('empresa') && map['empresa'] != null) {
      empresaConvertida = int.tryParse(map['empresa'].toString().trim()) ?? 0;
    } else if (map.containsKey('EMPRESA') && map['EMPRESA'] != null) {
      empresaConvertida = int.tryParse(map['EMPRESA'].toString().trim()) ?? 0;
    }

    String medidaConvertida = "";
    if (map.containsKey('medida') && map['medida'] != null) {
      medidaConvertida = map['medida'].toString().trim();
    } else if (map.containsKey('MEDIDA') && map['MEDIDA'] != null) {
      medidaConvertida = map['MEDIDA'].toString().trim();
    } else {
      medidaConvertida = "Sin definir";
    }

      int sincronizadoConvertida = 0;
    if (map.containsKey('sincronizado') && map['sincronizado'] != null) {
      sincronizadoConvertida = int.tryParse(map['sincronizado'].toString().trim()) ?? 0;
    } else if (map.containsKey('SINCRONIZADO') && map['SINCRONIZADO'] != null) {
      sincronizadoConvertida = int.tryParse(map['SINCRONIZADO'].toString().trim()) ?? 0;
    }

    return Medida(
      empresa: empresaConvertida,
      medida: medidaConvertida,
      sincronizado: sincronizadoConvertida,

    );
  }

  /// 🔹 **Convierte un objeto `Medida` a un mapa para SQLite**
  Map<String, dynamic> toMap() {
    return {
      'empresa': empresa,
      'medida': medida,
      'sincronizado': sincronizado,

    };
  }

  /// 🔹 **Convierte un JSON en un objeto `Medida`**
  factory Medida.fromJson(Map<String, dynamic> json) {
    int empresaConvertida = json['EMPRESA'] is int
        ? json['EMPRESA']
        : int.tryParse(json['EMPRESA']?.toString().trim() ?? '0') ?? 0;

    String medidaConvertida = json['MEDIDA']?.toString().trim() ?? "Sin definir";

      int sincronizadoConvertida = json['SINCRONIZADO'] is int
        ? json['SINCRONIZADO']
        : int.tryParse(json['SINCRONIZADO']?.toString().trim() ?? '0') ?? 0;


    return Medida(
      empresa: empresaConvertida,
      medida: medidaConvertida,
      sincronizado: sincronizadoConvertida,

    );
  }
}
