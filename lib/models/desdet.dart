class DesDet {
  int empresa;
  String base;
  String folio;
  int reg;
  String? procedencia;
  String? sisMedida; // ← nuevo campo
  String? operador;
  String? marca;
  String? modelo;
  String? medida;
  int? pisoRemanente;
  String? rangoCarga;
  int? oriren;
  String? marcaRen;
  String? modeloRen;
  String? serie;
  String? dot;
  String? falla1;
  String? falla2;
  String? falla3;
  String? falla4;
  String? falla5;
  int? anio;
  String? fsistema;
  int? sincronizado;


  DesDet({
    required this.empresa,
    required this.base,
    required this.folio,
    required this.reg,
    this.procedencia,
    this.sisMedida, // ← nuevo campo
    this.operador,
    this.marca,
    this.modelo,
    this.medida,
    this.pisoRemanente,
    this.rangoCarga,
    this.oriren,
    this.marcaRen,
    this.modeloRen,
    this.serie,
    this.dot,
    this.falla1,
    this.falla2,
    this.falla3,
    this.falla4,
    this.falla5,
    this.anio,
    this.fsistema,
    this.sincronizado,

  });

  factory DesDet.fromMap(Map<String, dynamic> map) {
    return DesDet(
      empresa: _parseInt(map, ['empresa', 'EMPRESA']),
      base: _parseString(map, ['base', 'BASE']),
      folio: _parseString(map, ['folio', 'FOLIO']),
      reg: _parseInt(map, ['reg', 'REG']),
      procedencia: _parseNullableString(map, ['procedencia', 'PROCEDENCIA']),
      sisMedida:
          _parseNullableString(map, ['sis_medida', 'SIS_MEDIDA']), // ← nuevo
      operador: _parseNullableString(map, ['operador', 'OPERADOR']),
      marca: _parseNullableString(map, ['marca', 'MARCA']),
      modelo: _parseNullableString(map, ['modelo', 'MODELO']),
      medida: _parseNullableString(map, ['medida', 'MEDIDA']),
      pisoRemanente:
          _parseNullableInt(map, ['piso_remanente', 'PISO_REMANENTE']),
      rangoCarga: _parseNullableString(map, ['rango_carga', 'RANGO_CARGA']),
      oriren: _parseNullableInt(map, ['oriren', 'ORIREN']),
      marcaRen: _parseNullableString(map, ['marca_ren', 'MARCA_REN']),
      modeloRen: _parseNullableString(map, ['modelo_ren', 'MODELO_REN']),
      serie: _parseNullableString(map, ['serie', 'SERIE']),
      dot: _parseNullableString(map, ['dot', 'DOT']),
      falla1: _parseNullableString(map, ['falla1', 'FALLA1']),
      falla2: _parseNullableString(map, ['falla2', 'FALLA2']),
      falla3: _parseNullableString(map, ['falla3', 'FALLA3']),
      falla4: _parseNullableString(map, ['falla4', 'FALLA4']),
      falla5: _parseNullableString(map, ['falla5', 'FALLA5']),
      anio: _parseNullableInt(map, ['anio', 'ANIO']),
      fsistema: _parseNullableString(map, ['fsistema', 'FSISTEMA']),
      sincronizado: _parseNullableInt(map, ['sincronizado', 'SINCRONIZADO']),

    );
  }

  Map<String, dynamic> toMap() {
    return {
      'empresa': empresa,
      'base': base,
      'folio': folio,
      'reg': reg,
      'procedencia': procedencia,
      'sis_medida': sisMedida, // ← nuevo campo
      'operador': operador,
      'marca': marca,
      'modelo': modelo,
      'medida': medida,
      'piso_remanente': pisoRemanente,
      'rango_carga': rangoCarga,
      'oriren': oriren,
      'marca_ren': marcaRen,
      'modelo_ren': modeloRen,
      'serie': serie,
      'dot': dot,
      'falla1': falla1,
      'falla2': falla2,
      'falla3': falla3,
      'falla4': falla4,
      'falla5': falla5,
      'anio': anio,
      'fsistema': fsistema,
      'sincronizado': sincronizado,

    };
  }

  factory DesDet.fromJson(Map<String, dynamic> json) {
    return DesDet(
      empresa: _parseInt(json, ['EMPRESA', 'empresa']),
      base: _parseString(json, ['BASE', 'base']),
      folio: _parseString(json, ['FOLIO', 'folio']),
      reg: _parseInt(json, ['REG', 'reg']),
      procedencia: _parseNullableString(json, ['PROCEDENCIA', 'procedencia']),
      sisMedida:
          _parseNullableString(json, ['SIS_MEDIDA', 'sis_medida']), // ← nuevo
      operador: _parseNullableString(json, ['OPERADOR', 'operador']),
      marca: _parseNullableString(json, ['MARCA', 'marca']),
      modelo: _parseNullableString(json, ['MODELO', 'modelo']),
      medida: _parseNullableString(json, ['MEDIDA', 'medida']),
      pisoRemanente:
          _parseNullableInt(json, ['PISO_REMANENTE', 'piso_remanente']),
      rangoCarga: _parseNullableString(json, ['RANGO_CARGA', 'rango_carga']),
      oriren: _parseNullableInt(json, ['ORIREN', 'oriren']),
      marcaRen: _parseNullableString(json, ['MARCA_REN', 'marca_ren']),
      modeloRen: _parseNullableString(json, ['MODELO_REN', 'modelo_ren']),
      serie: _parseNullableString(json, ['SERIE', 'serie']),
      dot: _parseNullableString(json, ['DOT', 'dot']),
      falla1: _parseNullableString(json, ['FALLA1', 'falla1']),
      falla2: _parseNullableString(json, ['FALLA2', 'falla2']),
      falla3: _parseNullableString(json, ['FALLA3', 'falla3']),
      falla4: _parseNullableString(json, ['FALLA4', 'falla4']),
      falla5: _parseNullableString(json, ['FALLA5', 'falla5']),
      anio: _parseNullableInt(json, ['ANIO', 'anio']),
      fsistema: _parseNullableString(json, ['FSISTEMA', 'fsistema']),
      sincronizado: _parseNullableInt(json, ['SINCRONIZADO', 'sincronizado']),

    );
  }

  Map<String, dynamic> toJson() {
    return {
      'empresa': empresa,
      'base': base,
      'folio': folio,
      'reg': reg,
      'procedencia': procedencia,
      'sis_medida': sisMedida,
      'operador': operador,
      'marca': marca,
      'modelo': modelo,
      'medida': medida,
      'piso_remanente': pisoRemanente,
      'rango_carga': rangoCarga,
      'oriren': oriren,
      'marca_ren': marcaRen,
      'modelo_ren': modeloRen,
      'serie': serie,
      'dot': dot,
      'falla1': falla1,
      'falla2': falla2,
      'falla3': falla3,
      'falla4': falla4,
      'falla5': falla5,
      'anio': anio,
      'fsistema': fsistema,
      'sincronizado': sincronizado,

    };
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

  static String? _parseNullableString(
      Map<String, dynamic> map, List<String> keys) {
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
