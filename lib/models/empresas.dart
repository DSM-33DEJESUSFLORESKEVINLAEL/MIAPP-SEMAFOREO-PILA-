class Empresa {
  int empresa;
  String nombre;
  int desmontajeInmediato;
  int desmontajeProxDesde;
  int desmontajeProxHasta;
  int buenasCondiciones;

  Empresa({
    required this.empresa,
    required this.nombre,
    required this.desmontajeInmediato,
    required this.desmontajeProxDesde,
    required this.desmontajeProxHasta,
    required this.buenasCondiciones,
  });

  /// 🔹 Convierte un `Map` (de la BD) en un objeto `Empresa`
  factory Empresa.fromMap(Map<String, dynamic> map) {
    int empresaConvertida = 0;
    if (map.containsKey('empresa') && map['empresa'] != null) {
      empresaConvertida = int.tryParse(map['empresa'].toString().trim()) ?? 0;
    } else if (map.containsKey('EMPRESA') && map['EMPRESA'] != null) {
      empresaConvertida = int.tryParse(map['EMPRESA'].toString().trim()) ?? 0;
    }

    String nombreConvertido =
        map['nombre']?.toString().trim() ?? map['NOMBRE']?.toString().trim() ?? "Sin nombre";

    int desmontajeInmediatoConvertido = map['desmontaje_inmediato'] is int
        ? map['desmontaje_inmediato']
        : int.tryParse(map['desmontaje_inmediato']?.toString().trim() ?? '0') ?? 0;

    int desmontajeProxDesdeConvertido = map['desmontaje_prox_desde'] is int
        ? map['desmontaje_prox_desde']
        : int.tryParse(map['desmontaje_prox_desde']?.toString().trim() ?? '0') ?? 0;

    int desmontajeProxHastaConvertido = map['desmontaje_prox_hasta'] is int
        ? map['desmontaje_prox_hasta']
        : int.tryParse(map['desmontaje_prox_hasta']?.toString().trim() ?? '0') ?? 0;

    int buenasCondicionesConvertido = map['buenas_condiciones'] is int
        ? map['buenas_condiciones']
        : int.tryParse(map['buenas_condiciones']?.toString().trim() ?? '0') ?? 0;

    return Empresa(
      empresa: empresaConvertida,
      nombre: nombreConvertido,
      desmontajeInmediato: desmontajeInmediatoConvertido,
      desmontajeProxDesde: desmontajeProxDesdeConvertido,
      desmontajeProxHasta: desmontajeProxHastaConvertido,
      buenasCondiciones: buenasCondicionesConvertido,
    );
  }

  /// 🔹 Convierte un objeto `Empresa` a un `Map` para almacenar en la BD
  Map<String, dynamic> toMap() {
    return {
      'empresa': empresa,
      'nombre': nombre,
      'desmontaje_inmediato': desmontajeInmediato,
      'desmontaje_prox_desde': desmontajeProxDesde,
      'desmontaje_prox_hasta': desmontajeProxHasta,
      'buenas_condiciones': buenasCondiciones,
    };
  }

  /// 🔹 Convierte un JSON en un objeto `Empresa`
  factory Empresa.fromJson(Map<String, dynamic> json) {
    int empresaConvertida = json['EMPRESA'] is int
        ? json['EMPRESA']
        : int.tryParse(json['EMPRESA']?.toString().trim() ?? '0') ?? 0;

    String nombreConvertido = json['NOMBRE']?.toString().trim() ?? "Sin nombre";

    int desmontajeInmediatoConvertido = json['DESMONTAJE_INMEDIATO'] is int
        ? json['DESMONTAJE_INMEDIATO']
        : int.tryParse(json['DESMONTAJE_INMEDIATO']?.toString().trim() ?? '0') ?? 0;

    int desmontajeProxDesdeConvertido = json['DESMONTAJE_PROX_DESDE'] is int
        ? json['DESMONTAJE_PROX_DESDE']
        : int.tryParse(json['DESMONTAJE_PROX_DESDE']?.toString().trim() ?? '0') ?? 0;

    int desmontajeProxHastaConvertido = json['DESMONTAJE_PROX_HASTA'] is int
        ? json['DESMONTAJE_PROX_HASTA']
        : int.tryParse(json['DESMONTAJE_PROX_HASTA']?.toString().trim() ?? '0') ?? 0;

    int buenasCondicionesConvertido = json['BUENAS_CONDICIONES'] is int
        ? json['BUENAS_CONDICIONES']
        : int.tryParse(json['BUENAS_CONDICIONES']?.toString().trim() ?? '0') ?? 0;

    return Empresa(
      empresa: empresaConvertida,
      nombre: nombreConvertido,
      desmontajeInmediato: desmontajeInmediatoConvertido,
      desmontajeProxDesde: desmontajeProxDesdeConvertido,
      desmontajeProxHasta: desmontajeProxHastaConvertido,
      buenasCondiciones: buenasCondicionesConvertido,
    );
  }
}
