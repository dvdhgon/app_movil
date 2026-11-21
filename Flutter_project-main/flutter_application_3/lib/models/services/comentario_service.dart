import 'dart:convert';
import 'package:http/http.dart' as http;
import '../comentario_model.dart';

class ComentarioService {
  static const String baseUrl = 'http://127.0.0.1:8000';

  Future<List<ComentarioModel>> obtenerComentarios() async {
    final respuesta = await http.get(
      Uri.parse('$baseUrl/comentarios'),
    );

    if (respuesta.statusCode != 200) {
      throw Exception('Error al consultar comentarios');
    }

    final List<dynamic> datos = jsonDecode(respuesta.body);

    return datos
        .map(
          (json) => ComentarioModel.fromJson(
            json as Map<String, dynamic>,
          ),
        )
        .toList();
  }

  Future<List<ComentarioModel>> obtenerComentariosPorBlog(int blogId) async {
    final respuesta = await http.get(
      Uri.parse('$baseUrl/comentarios?blog_id=$blogId'),
    );

    if (respuesta.statusCode != 200) {
      throw Exception('Error al consultar comentarios de la publicación');
    }

    final List<dynamic> datos = jsonDecode(respuesta.body);

    return datos
        .map(
          (json) => ComentarioModel.fromJson(
            json as Map<String, dynamic>,
          ),
        )
        .toList();
  }

  Future<ComentarioModel> agregarComentario(
    ComentarioModel comentario,
  ) async {
    final respuesta = await http.post(
      Uri.parse('$baseUrl/comentarios'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
      },
      body: jsonEncode(comentario.toJsonCrear()),
    );

    if (respuesta.statusCode != 201 && respuesta.statusCode != 200) {
      throw Exception(
        'No se pudo registrar el comentario: ${respuesta.body}',
      );
    }

    return ComentarioModel.fromJson(
      jsonDecode(respuesta.body) as Map<String, dynamic>,
    );
  }
}
