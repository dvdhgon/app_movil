import 'dart:convert';
import 'package:http/http.dart' as http;
import '../post_model.dart'; // Tu import original intacto

class PostService {
  static const String baseUrl = 'http://127.0.0.1:8000';

  // Este método se queda exactamente como lo tenías
  Future<List<PostModel>> obtenerPosts() async {
    final respuesta = await http.get(
      Uri.parse('$baseUrl/blog'),
    );

    if (respuesta.statusCode != 200) {
      throw Exception('Error al consultar publicaciones');
    }

    final List<dynamic> datos = jsonDecode(respuesta.body);

    return datos
        .map(
          (json) => PostModel.fromJson(
            json as Map<String, dynamic>,
          ),
        )
        .toList();
  }

  // Actualizamos únicamente este método a MultipartRequest
  Future<bool> agregarPost({
    required String titulo,
    required String descripcion,
    String? imagen,
    String? tags,
  }) async {
    try {
      var uri = Uri.parse('$baseUrl/blog');
      // Usamos MultipartRequest para que coincida con Form(...) y File(...) del backend
      var request = http.MultipartRequest('POST', uri);

      // Agregamos los campos de texto
      request.fields['titulo'] = titulo;
      request.fields['descripcion'] = descripcion;
      
      if (tags != null && tags.isNotEmpty) {
        request.fields['tags'] = tags;
      }

      // Agregamos la imagen si existe
      if (imagen != null && imagen.isNotEmpty) {
        // La llave debe llamarse 'imagen' porque FastAPI espera imagen: UploadFile
        request.files.add(
          await http.MultipartFile.fromPath(
            'imagen',
            imagen,
          ),
        );
      }

      // Enviamos la petición
      var streamedResponse = await request.send();

      // Validamos el éxito (FastAPI devuelve 201 en tu código)
      if (streamedResponse.statusCode == 201 || streamedResponse.statusCode == 200) {
        return true;
      } else {
        throw Exception('Error al agregar publicación: Code ${streamedResponse.statusCode}');
      }
    } catch (e) {
      throw Exception('Error en la petición: $e');
    }
  }
}