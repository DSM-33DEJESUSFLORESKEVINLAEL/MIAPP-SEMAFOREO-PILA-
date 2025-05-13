class SemDet {
  int empresa;
  String base;
  String folio;
  String usuario;
  int reg;
  String unidad;
  String? tunidad;
  String? medidaDireccion;
  String? medidaTrasera;
  int? sinLlanta;
  int? cero;
  int? retiro;
  int? proxRetiro;
  int? buenas;
  int? originales;
  int? renovadas;
  int? numLlantas;
  double? mmPromedio;
  double? mmSuma;
  String? fsistema;
  String? edoUnidad;

  List<int?> mm = List.filled(12, null);
  List<int?> or = List.filled(12, null);
  List<String?> obs = List.filled(12, null);
  List<String?> tmarca = List.filled(12, null);
  List<String?> dot = List.filled(12, null);

  SemDet({
    required this.empresa,
    required this.base,
    required this.folio,
    required this.usuario,
    required this.reg,
    required this.unidad,
    this.tunidad,
    this.medidaDireccion,
    this.medidaTrasera,
    this.sinLlanta,
    this.cero,
    this.retiro,
    this.proxRetiro,
    this.buenas,
    this.originales,
    this.renovadas,
    this.numLlantas,
    this.mmPromedio,
    this.mmSuma,
    this.fsistema,
    this.edoUnidad,
    List<int?>? mm,
    List<int?>? or,
    List<String?>? obs,
    List<String?>? tmarca,
    List<String?>? dot,
  }) {
    this.mm = mm ?? List.filled(12, null);
    this.or = or ?? List.filled(12, null);
    this.obs = obs ?? List.filled(12, null);
    this.tmarca = tmarca ?? List.filled(12, null);
    this.dot = dot ?? List.filled(12, null);
  }

  factory SemDet.fromMap(Map<String, dynamic> json) => SemDet(
        empresa: json["empresa"],
        base: json["base"],
        folio: json["folio"],
        usuario: json["usuario"],
        reg: json["reg"],
        unidad: json["unidad"],
        tunidad: json["tunidad"],
        medidaDireccion: json["medida_direccion"],
        medidaTrasera: json["medida_trasera"],
        sinLlanta: json["sin_llanta"],
        cero: json["cero"],
        retiro: json["retiro"],
        proxRetiro: json["prox_retiro"],
        buenas: json["buenas"],
        originales: json["originales"],
        renovadas: json["renovadas"],
        numLlantas: json["num_llantas"],
        mmPromedio: json["mm_promedio"],
        mmSuma: json["mm_suma"],
        fsistema: json["fsistema"],
        edoUnidad: json["edo_unidad"],
        mm: List.generate(12, (i) => json["mm${i + 1}"]),
        or: List.generate(12, (i) => json["or${i + 1}"]),
        obs: List.generate(12, (i) => json["obs${i + 1}"]),
        tmarca: List.generate(12, (i) => json["tmarca${i + 1}"]),
        dot: List.generate(12, (i) => json["dot${i + 1}"]),
      );

  Map<String, dynamic> toMap() {
    final map = {
      "empresa": empresa,
      "base": base,
      "folio": folio,
      "usuario": usuario,
      "reg": reg,
      "unidad": unidad,
      "tunidad": tunidad,
      "medida_direccion": medidaDireccion,
      "medida_trasera": medidaTrasera,
      "sin_llanta": sinLlanta,
      "cero": cero,
      "retiro": retiro,
      "prox_retiro": proxRetiro,
      "buenas": buenas,
      "originales": originales,
      "renovadas": renovadas,
      "num_llantas": numLlantas,
      "mm_promedio": mmPromedio,
      "mm_suma": mmSuma,
      "fsistema": fsistema,
      "edo_unidad": edoUnidad,
    };

    for (int i = 0; i < 12; i++) {
      map["mm${i + 1}"] = mm[i];
      map["or${i + 1}"] = or[i];
      map["obs${i + 1}"] = obs[i];
      map["tmarca${i + 1}"] = tmarca[i];
      map["dot${i + 1}"] = dot[i];
    }

    return map;
  }
}
