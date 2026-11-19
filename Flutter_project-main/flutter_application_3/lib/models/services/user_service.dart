import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../user_model.dart';

class UserService {
  static const String baseUrl = 'http://127.0.0.1:8000';

  // Obtener la lista de usuarios
  Future<List<UserModel>> obtenerUsuarios() async {
    final respuesta = await http
        .get(Uri.parse('$baseUrl/usuarios'))
        .timeout(const Duration(seconds: 10));

    if (respuesta.statusCode != 200) {
      throw Exception('Error al consultar usuarios: ${respuesta.statusCode}');
    }

    final List<dynamic> datos = jsonDecode(respuesta.body);
    return datos
        .map((json) => UserModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  // Consultar un usuario actualizado desde MySQL por su ID
  Future<UserModel> obtenerUsuarioPorId(int id) async {
    final respuesta = await http
        .get(Uri.parse('$baseUrl/usuarios/$id'))
        .timeout(const Duration(seconds: 10));

    if (respuesta.statusCode == 200) {
      return UserModel.fromJson(
        jsonDecode(respuesta.body) as Map<String, dynamic>,
      );
    }
    throw Exception(_mensajeError(respuesta));
  }

  // Buscar usuario por correo en MySQL
  Future<UserModel?> buscarPorCorreo(String correo) async {
    final lista = await obtenerUsuarios();
    final limpio = correo.trim().toLowerCase();
    for (final u in lista) {
      if (u.correo.trim().toLowerCase() == limpio) {
        return u;
      }
    }
    return null;
  }

  // Agregar usuario
  Future<UserModel> agregarUsuario(UserModel usuario) async {
    final respuesta = await http
        .post(
          Uri.parse('$baseUrl/usuarios'),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          body: jsonEncode(usuario.toJsonCrear()),
        )
        .timeout(const Duration(seconds: 10));

    if (respuesta.statusCode == 201) {
      return UserModel.fromJson(
        jsonDecode(respuesta.body) as Map<String, dynamic>,
      );
    }
    throw Exception(_mensajeError(respuesta));
  }

  // Subir foto de perfil desde galería o cámara
  Future<UserModel> subirFotoPerfil(int idUsuario, XFile archivo) async {
    final bytes = await archivo.readAsBytes();
    final uri = Uri.parse('$baseUrl/usuarios/$idUsuario/foto');

    final request = http.MultipartRequest('POST', uri)
      ..files.add(
        http.MultipartFile.fromBytes(
          'foto',
          bytes,
          filename: archivo.name,
        ),
      );

    final streamResponse =
        await request.send().timeout(const Duration(seconds: 15));
    final respuesta = await http.Response.fromStream(streamResponse);

    if (respuesta.statusCode == 200) {
      return UserModel.fromJson(
        jsonDecode(respuesta.body) as Map<String, dynamic>,
      );
    }
    throw Exception(_mensajeError(respuesta));
  }

  // Actualizar usuario en MySQL
  Future<UserModel> actualizarUsuario(UserModel usuario) async {
    final respuesta = await http
        .put(
          Uri.parse('$baseUrl/usuarios/${usuario.id}'),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          body: jsonEncode(usuario.toJsonActualizar()),
        )
        .timeout(const Duration(seconds: 10));

    if (respuesta.statusCode == 200) {
      return UserModel.fromJson(
        jsonDecode(respuesta.body) as Map<String, dynamic>,
      );
    }
    throw Exception(_mensajeError(respuesta));
  }

  // Eliminar usuario
  Future<void> eliminarUsuario(int id) async {
    final respuesta = await http
        .delete(Uri.parse('$baseUrl/usuarios/$id'))
        .timeout(const Duration(seconds: 10));

    if (respuesta.statusCode != 200 && respuesta.statusCode != 204) {
      throw Exception(_mensajeError(respuesta));
    }
  }

  String _mensajeError(http.Response respuesta) {
    try {
      final datos = jsonDecode(respuesta.body);
      if (datos is Map && datos['detail'] != null) {
        return datos['detail'].toString();
      }
    } catch (_) {}
    return 'Error HTTP ${respuesta.statusCode}: ${respuesta.body}';
  }
}