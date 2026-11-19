class UserModel {
  final int? id;
  final String nombre;
  final String correo;
  final String? password;
  final String? direccion;
  final int tipoUsuario;
  final String? fotoPerfil;

  UserModel({
    this.id,
    required this.nombre,
    required this.correo,
    this.password,
    this.direccion,
    this.tipoUsuario = 2,
    this.fotoPerfil,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final rawId = json['id_usr'] ?? json['id_usuario'] ?? json['id'];
    final int? parsedId = rawId != null ? int.tryParse(rawId.toString()) : null;

    return UserModel(
      id: parsedId,
      nombre: (json['nom_usr'] ?? json['nombre'] ?? '').toString(),
      correo: (json['mail'] ?? json['correo'] ?? '').toString(),
      password: json['password']?.toString(),
      direccion: json['dir_usr']?.toString() ?? json['direccion']?.toString(),
      tipoUsuario: (json['tip_usu'] as num? ?? 2).toInt(),
      fotoPerfil: json['foto_perfil']?.toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id_usr': id,
      'nom_usr': nombre,
      'mail': correo,
      'dir_usr': direccion,
      'tip_usu': tipoUsuario,
      'foto_perfil': fotoPerfil,
    };
  }

  Map<String, dynamic> toJsonCrear() {
    return {
      'nom_usr': nombre,
      'mail': correo,
      'password': password ?? '12345678',
      'dir_usr': direccion,
      'tip_usu': tipoUsuario,
    };
  }

  Map<String, dynamic> toJsonActualizar() {
    final map = <String, dynamic>{
      'nom_usr': nombre,
      'mail': correo,
      'dir_usr': direccion,
      'tip_usu': tipoUsuario,
      'foto_perfil': fotoPerfil,
    };
    if (password != null && password!.trim().isNotEmpty) {
      map['password'] = password!.trim();
    }
    return map;
  }

  Map<String, dynamic> toJson() => toJsonActualizar();
}