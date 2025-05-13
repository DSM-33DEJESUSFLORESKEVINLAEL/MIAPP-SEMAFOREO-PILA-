class Semaforo {
  int empresa;
  String base;
  String folio;
  String fecha;
  String? operador;
  int? numSemana;
  int? numMes;
  int? nRegistros;
  int? sinLlanta;
  int? cero;
  int? desmontajeInmediato;
  int? desmontajeProximo;
  int? buenasCondiciones;
  int? llantasRevisadas;
  int? llantasOriginales;
  int? llantasRenovadas;
  int? fsistema;
  int? nUnidades;
  int? nLlantas;
  int? nosemUnidades;
  int? nosemLlantas;
  String? cierreOperador;
  String? cierreSupervisor;
  String? cierreEmpresa;
  String? fcierreOperador;
  String? fcierreSupervisor;
  String? fcierreEmpresa;

  Semaforo({
    required this.empresa,
    required this.base,
    required this.folio,
    required this.fecha,
    this.operador,
    this.numSemana,
    this.numMes,
    this.nRegistros,
    this.sinLlanta,
    this.cero,
    this.desmontajeInmediato,
    this.desmontajeProximo,
    this.buenasCondiciones,
    this.llantasRevisadas,
    this.llantasOriginales,
    this.llantasRenovadas,
    this.fsistema,
    this.nUnidades,
    this.nLlantas,
    this.nosemUnidades,
    this.nosemLlantas,
    this.cierreOperador,
    this.cierreSupervisor,
    this.cierreEmpresa,
    this.fcierreOperador,
    this.fcierreSupervisor,
    this.fcierreEmpresa,
  });

  factory Semaforo.fromMap(Map<String, dynamic> map) {
    return Semaforo(
      empresa: _parseInt(map, ['EMPRESA', 'empresa']),
      base: _parseString(map, ['BASE', 'base']),
      folio: _parseString(map, ['FOLIO', 'folio']),
      fecha: _parseString(map, ['FECHA', 'fecha']),
      operador: _parseNullableString(map, ['OPERADOR', 'operador']),
      numSemana: _parseNullableInt(map, ['NUM_SEMANA', 'num_semana']),
      numMes: _parseNullableInt(map, ['NUM_MES', 'num_mes']),
      nRegistros: _parseNullableInt(map, ['NREGISTROS', 'nregistros']),
      sinLlanta: _parseNullableInt(map, ['SIN_LLANTA', 'sin_llanta']),
      cero: _parseNullableInt(map, ['CERO', 'cero']),
      desmontajeInmediato: _parseNullableInt(map, ['DESMONTAJE_INMEDIATO', 'desmontaje_inmediato']),
      desmontajeProximo: _parseNullableInt(map, ['DESMONTAJE_PROXIMO', 'desmontaje_proximo']),
      buenasCondiciones: _parseNullableInt(map, ['BUENAS_CONDICIONES', 'buenas_condiciones']),
      llantasRevisadas: _parseNullableInt(map, ['LLANTAS_REVISADAS', 'llantas_revisadas']),
      llantasOriginales: _parseNullableInt(map, ['LLANTAS_ORIGINALES', 'llantas_originales']),
      llantasRenovadas: _parseNullableInt(map, ['LLANTAS_RENOVADAS', 'llantas_renovadas']),
      fsistema: _parseNullableInt(map, ['FSISTEMA', 'fsistema']),
      nUnidades: _parseNullableInt(map, ['NUNIDADES', 'nunidades']),
      nLlantas: _parseNullableInt(map, ['NLLANTAS', 'nllantas']),
      nosemUnidades: _parseNullableInt(map, ['NOSEM_UNIDADES', 'nosem_unidades']),
      nosemLlantas: _parseNullableInt(map, ['NOSEM_LLANTAS', 'nosem_llantas']),
      cierreOperador: _parseNullableString(map, ['CIERRE_OPERADOR', 'cierre_operador']),
      cierreSupervisor: _parseNullableString(map, ['CIERRE_SUPERVISOR', 'cierre_supervisor']),
      cierreEmpresa: _parseNullableString(map, ['CIERRE_EMPRESA', 'cierre_empresa']),
      fcierreOperador: _parseNullableString(map, ['FCIERRE_OPERADOR', 'fcierre_operador']),
      fcierreSupervisor: _parseNullableString(map, ['FCIERRE_SUPERVISOR', 'fcierre_supervisor']),
      fcierreEmpresa: _parseNullableString(map, ['FCIERRE_EMPRESA', 'fcierre_empresa']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'empresa': empresa,
      'base': base,
      'folio': folio,
      'fecha': fecha,
      'operador': operador,
      'num_semana': numSemana,
      'num_mes': numMes,
      'nregistros': nRegistros,
      'sin_llanta': sinLlanta,
      'cero': cero,
      'desmontaje_inmediato': desmontajeInmediato,
      'desmontaje_proximo': desmontajeProximo,
      'buenas_condiciones': buenasCondiciones,
      'llantas_revisadas': llantasRevisadas,
      'llantas_originales': llantasOriginales,
      'llantas_renovadas': llantasRenovadas,
      'fsistema': fsistema,
      'nunidades': nUnidades,
      'nllantas': nLlantas,
      'nosem_unidades': nosemUnidades,
      'nosem_llantas': nosemLlantas,
      'cierre_operador': cierreOperador,
      'cierre_supervisor': cierreSupervisor,
      'cierre_empresa': cierreEmpresa,
      'fcierre_operador': fcierreOperador,
      'fcierre_supervisor': fcierreSupervisor,
      'fcierre_empresa': fcierreEmpresa,
    };
  }

  static int _parseInt(Map<String, dynamic> map, List<String> keys) {
    for (var key in keys) {
      if (map.containsKey(key) && map[key] != null) {
        return int.tryParse(map[key].toString()) ?? 0;
      }
    }
    return 0;
  }

  static int? _parseNullableInt(Map<String, dynamic> map, List<String> keys) {
    for (var key in keys) {
      if (map.containsKey(key) && map[key] != null) {
        return int.tryParse(map[key].toString());
      }
    }
    return null;
  }

  static String _parseString(Map<String, dynamic> map, List<String> keys) {
    for (var key in keys) {
      if (map.containsKey(key) && map[key] != null) {
        return map[key].toString();
      }
    }
    return '';
  }

  static String? _parseNullableString(Map<String, dynamic> map, List<String> keys) {
    for (var key in keys) {
      if (map.containsKey(key) && map[key] != null) {
        return map[key].toString();
      }
    }
    return null;
  }
}
