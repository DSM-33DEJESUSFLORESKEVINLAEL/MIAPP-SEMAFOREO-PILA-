class DesMstr {
  int EMPRESA;
  String BASE;
  String FOLIO;
  String FECHA;
  String? SIS_MEDIDA;
  String? OPERADOR;
  int? NUM_SEMANA;
  int? NUM_MES;
  int? NUM_LLANTAS; // <- CAMBIO: campo para el número de llantas
  String? FSISTEMA;

  DesMstr({
    required this.EMPRESA,
    required this.BASE,
    required this.FOLIO,
    required this.FECHA,
    this.SIS_MEDIDA,
    this.OPERADOR,
    this.NUM_SEMANA,
    this.NUM_MES,
    this.NUM_LLANTAS,
    this.FSISTEMA,
  });

  factory DesMstr.fromMap(Map<String, dynamic> map) {
    return DesMstr(
      EMPRESA: _parseInt(map, ['empresa', 'EMPRESA']),
      BASE: _parseString(map, ['base', 'BASE']),
      FOLIO: _parseString(map, ['folio', 'FOLIO']),
      FECHA: _parseString(map, ['fecha', 'FECHA']),
      SIS_MEDIDA: _parseNullableString(map, ['sis_medida', 'SIS_MEDIDA']),
      OPERADOR: _parseNullableString(map, ['operador', 'OPERADOR']),
      NUM_SEMANA: _parseNullableInt(map, ['num_semana', 'NUM_SEMANA']),
      NUM_MES: _parseNullableInt(map, ['num_mes', 'NUM_MES']),
      NUM_LLANTAS: _parseNullableInt(map, ['nregistros', 'NREGISTROS', 'NUM_REGISTROS']),
      FSISTEMA: _parseNullableString(map, ['fsistema', 'FSISTEMA']),
    );
  }

Map<String, dynamic> toMap() {
  return {
    'EMPRESA': EMPRESA,
    'BASE': BASE,
    'FOLIO': FOLIO,
    'FECHA': FECHA,
    'SIS_MEDIDA': SIS_MEDIDA,
    'OPERADOR': OPERADOR,
    'NUM_SEMANA': NUM_SEMANA,
    'NUM_MES': NUM_MES,
    'nregistros': NUM_LLANTAS, // <- CAMBIADO PARA QUE COINCIDA CON LA BD
    'FSISTEMA': FSISTEMA,
  };
}


  factory DesMstr.fromJson(Map<String, dynamic> json) {
    return DesMstr(
      EMPRESA: _parseInt(json, ['EMPRESA', 'empresa']),
      BASE: _parseString(json, ['BASE', 'base']),
      FOLIO: _parseString(json, ['FOLIO', 'folio']),
      FECHA: _parseString(json, ['FECHA', 'fecha']),
      SIS_MEDIDA: _parseNullableString(json, ['SIS_MEDIDA', 'sis_medida']),
      OPERADOR: _parseNullableString(json, ['OPERADOR', 'operador']),
      NUM_SEMANA: _parseNullableInt(json, ['NUM_SEMANA', 'num_semana']),
      NUM_MES: _parseNullableInt(json, ['NUM_MES', 'num_mes']),
      NUM_LLANTAS: _parseNullableInt(json, ['NREGISTROS', 'nregistros', 'NUM_LLANTAS']),
      FSISTEMA: _parseNullableString(json, ['FSISTEMA', 'fsistema']),
    );
  }

  static int _parseInt(Map<String, dynamic> map, List<String> keys) {
    for (var key in keys) {
      if (map.containsKey(key) && map[key] != null) {
        return int.tryParse(map[key].toString().trim()) ?? 0;
      }
    }
    return 0;
  }

  static String _parseString(Map<String, dynamic> map, List<String> keys) {
    for (var key in keys) {
      if (map.containsKey(key) && map[key] != null) {
        return map[key].toString().trim();
      }
    }
    return '';
  }

  static String? _parseNullableString(Map<String, dynamic> map, List<String> keys) {
    for (var key in keys) {
      if (map.containsKey(key) && map[key] != null) {
        return map[key].toString().trim();
      }
    }
    return null;
  }

  static int? _parseNullableInt(Map<String, dynamic> map, List<String> keys) {
    for (var key in keys) {
      if (map.containsKey(key) && map[key] != null) {
        return int.tryParse(map[key].toString().trim());
      }
    }
    return null;
  }
}
