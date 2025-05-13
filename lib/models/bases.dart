class Base {
  int empresa;
  String base;
  String? serie;
  String? serieCompras;
  String? serieEconomico;
  int? empCte;
  String? cliente;
  String? lugar;
  String? grupo;

  Base({
    required this.empresa,
    required this.base,
    this.serie,
    this.serieCompras,
    this.serieEconomico,
    this.empCte,
    this.cliente,
    this.lugar,
    this.grupo,
  });

  /// 🔹 Convierte un `Map` (de la BD) en un objeto `Base`
  factory Base.fromMap(Map<String, dynamic> map) {
    int empresaConvertida = 0;
    if (map.containsKey('empresa') && map['empresa'] != null) {
      empresaConvertida = int.tryParse(map['empresa'].toString().trim()) ?? 0;
    } else if (map.containsKey('EMPRESA') && map['EMPRESA'] != null) {
      empresaConvertida = int.tryParse(map['EMPRESA'].toString().trim()) ?? 0;
    }

    String baseConvertida =
        map['base']?.toString().trim() ?? map['BASE']?.toString().trim() ?? "Sin definir";

    String? serieConvertida = map['serie']?.toString().trim() ?? map['SERIE']?.toString().trim();

    String? serieComprasConvertida =
        map['serie_compras']?.toString().trim() ?? map['SERIE_COMPRAS']?.toString().trim();

    String? serieEconomicoConvertida =
        map['serie_economico']?.toString().trim() ?? map['SERIE_ECONOMICO']?.toString().trim();

    int? empCteConvertido = map['emp_cte'] is int
        ? map['emp_cte']
        : int.tryParse(map['emp_cte']?.toString().trim() ?? '');

    String? clienteConvertido = map['cliente']?.toString().trim() ?? map['CLIENTE']?.toString().trim();

    String? lugarConvertido = map['lugar']?.toString().trim() ?? map['LUGAR']?.toString().trim();

    String? grupoConvertido = map['grupo']?.toString().trim() ?? map['GRUPO']?.toString().trim();

    return Base(
      empresa: empresaConvertida,
      base: baseConvertida,
      serie: serieConvertida,
      serieCompras: serieComprasConvertida,
      serieEconomico: serieEconomicoConvertida,
      empCte: empCteConvertido,
      cliente: clienteConvertido,
      lugar: lugarConvertido,
      grupo: grupoConvertido,
    );
  }

  /// 🔹 Convierte un objeto `Base` a un `Map` para almacenar en la BD
  Map<String, dynamic> toMap() {
    return {
      'empresa': empresa,
      'base': base,
      'serie': serie,
      'serie_compras': serieCompras,
      'serie_economico': serieEconomico,
      'emp_cte': empCte,
      'cliente': cliente,
      'lugar': lugar,
      'grupo': grupo,
    };
  }

  /// 🔹 Convierte un JSON en un objeto `Base`
  factory Base.fromJson(Map<String, dynamic> json) {
    int empresaConvertida = json['EMPRESA'] is int
        ? json['EMPRESA']
        : int.tryParse(json['EMPRESA']?.toString().trim() ?? '0') ?? 0;

    String baseConvertida = json['BASE']?.toString().trim() ?? "Sin definir";

    String? serieConvertida = json['SERIE']?.toString().trim();

    String? serieComprasConvertida = json['SERIE_COMPRAS']?.toString().trim();

    String? serieEconomicoConvertida = json['SERIE_ECONOMICO']?.toString().trim();

    int? empCteConvertido = json['EMP_CTE'] is int
        ? json['EMP_CTE']
        : int.tryParse(json['EMP_CTE']?.toString().trim() ?? '');

    String? clienteConvertido = json['CLIENTE']?.toString().trim();

    String? lugarConvertido = json['LUGAR']?.toString().trim();

    String? grupoConvertido = json['GRUPO']?.toString().trim();

    return Base(
      empresa: empresaConvertida,
      base: baseConvertida,
      serie: serieConvertida,
      serieCompras: serieComprasConvertida,
      serieEconomico: serieEconomicoConvertida,
      empCte: empCteConvertido,
      cliente: clienteConvertido,
      lugar: lugarConvertido,
      grupo: grupoConvertido,
    );
  }
}
