class AccesosUsuario {
  int empresa;
  String base;
  String usuario;
  String nombre;
  String psw;
  String? falta;
  String? fbaja;
  String? puesto;
  String? obs;
  String? mail;

  AccesosUsuario({
    required this.empresa,
    required this.base,
    required this.usuario,
    required this.nombre,
    required this.psw,
    this.falta,
    this.fbaja,
    this.puesto,
    this.obs,
    this.mail,
  });

  /// 🔹 Convierte un `Map` (de la BD) en un objeto `AccesosUsuario`
  factory AccesosUsuario.fromMap(Map<String, dynamic> map) {
    int empresaConvertida = 0;
    if (map.containsKey('empresa') && map['empresa'] != null) {
      empresaConvertida = int.tryParse(map['empresa'].toString().trim()) ?? 0;
    } else if (map.containsKey('EMPRESA') && map['EMPRESA'] != null) {
      empresaConvertida = int.tryParse(map['EMPRESA'].toString().trim()) ?? 0;
    }

    String baseConvertida =
        map['base']?.toString().trim() ?? map['BASE']?.toString().trim() ?? "Sin definir";

    String usuarioConvertido =
        map['usuario']?.toString().trim() ?? map['USUARIO']?.toString().trim() ?? "Sin usuario";

    String nombreConvertido =
        map['nombre']?.toString().trim() ?? map['NOMBRE']?.toString().trim() ?? "Sin nombre";

    String pswConvertido =
        map['psw']?.toString().trim() ?? map['PSW']?.toString().trim() ?? "Sin contraseña";

    String? faltaConvertida = map['falta']?.toString().trim() ?? map['FALTA']?.toString().trim();

    String? fbajaConvertida = map['fbaja']?.toString().trim() ?? map['FBAJA']?.toString().trim();

    String? puestoConvertido = map['puesto']?.toString().trim() ?? map['PUESTO']?.toString().trim();

    String? obsConvertida = map['obs']?.toString().trim() ?? map['OBS']?.toString().trim();

    String? mailConvertido = map['mail']?.toString().trim() ?? map['MAIL']?.toString().trim();

    return AccesosUsuario(
      empresa: empresaConvertida,
      base: baseConvertida,
      usuario: usuarioConvertido,
      nombre: nombreConvertido,
      psw: pswConvertido,
      falta: faltaConvertida,
      fbaja: fbajaConvertida,
      puesto: puestoConvertido,
      obs: obsConvertida,
      mail: mailConvertido,
    );
  }

  /// 🔹 Convierte un objeto `AccesosUsuario` a un `Map` para almacenar en la BD
  Map<String, dynamic> toMap() {
    return {
      'empresa': empresa,
      'base': base,
      'usuario': usuario,
      'nombre': nombre,
      'psw': psw,
      'falta': falta,
      'fbaja': fbaja,
      'puesto': puesto,
      'obs': obs,
      'mail': mail,
    };
  }

  /// 🔹 Convierte un JSON en un objeto `AccesosUsuario`
  factory AccesosUsuario.fromJson(Map<String, dynamic> json) {
    int empresaConvertida = json['EMPRESA'] is int
        ? json['EMPRESA']
        : int.tryParse(json['EMPRESA']?.toString().trim() ?? '0') ?? 0;

    String baseConvertida = json['BASE']?.toString().trim() ?? "Sin definir";

    String usuarioConvertido = json['USUARIO']?.toString().trim() ?? "Sin usuario";

    String nombreConvertido = json['NOMBRE']?.toString().trim() ?? "Sin nombre";

    String pswConvertido = json['PSW']?.toString().trim() ?? "Sin contraseña";

    String? faltaConvertida = json['FALTA']?.toString().trim();

    String? fbajaConvertida = json['FBAJA']?.toString().trim();

    String? puestoConvertido = json['PUESTO']?.toString().trim();

    String? obsConvertida = json['OBS']?.toString().trim();

    String? mailConvertido = json['MAIL']?.toString().trim();

    return AccesosUsuario(
      empresa: empresaConvertida,
      base: baseConvertida,
      usuario: usuarioConvertido,
      nombre: nombreConvertido,
      psw: pswConvertido,
      falta: faltaConvertida,
      fbaja: fbajaConvertida,
      puesto: puestoConvertido,
      obs: obsConvertida,
      mail: mailConvertido,
    );
  }
}
