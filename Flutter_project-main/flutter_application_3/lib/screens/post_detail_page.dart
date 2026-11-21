import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/comentario_model.dart';
import '../models/post_model.dart';
import '../models/services/comentario_service.dart';

class PostDetailPage extends StatefulWidget {
  final PostModel post;
  final Map<String, dynamic>? usuarioActual;

  const PostDetailPage({
    super.key,
    required this.post,
    this.usuarioActual,
  });

  @override
  State<PostDetailPage> createState() => _PostDetailPageState();
}

class _PostDetailPageState extends State<PostDetailPage> {
  static const Color colorVino = Color(0xFF722F37);
  static const Color colorVinoOscuro = Color(0xFF5A252B);
  static const Color colorDorado = Color(0xFFD4AF37);
  static const Color colorFondo = Color(0xFFFAF7F5);

  final ComentarioService _comentarioService = ComentarioService();
  final TextEditingController _comentarioController = TextEditingController();

  late Future<List<ComentarioModel>> _futureComentarios;
  Map<String, dynamic> _usuario = {};
  bool _enviandoComentario = false;

  @override
  void initState() {
    super.initState();
    _futureComentarios = _comentarioService.obtenerComentariosPorBlog(widget.post.id);
    _cargarUsuario();
  }

  @override
  void dispose() {
    _comentarioController.dispose();
    super.dispose();
  }

  Future<void> _cargarUsuario() async {
    if (widget.usuarioActual != null && widget.usuarioActual!.isNotEmpty) {
      setState(() {
        _usuario = Map<String, dynamic>.from(widget.usuarioActual!);
      });
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final sesion = prefs.getString('usuario_sesion');
    if (sesion != null) {
      setState(() {
        _usuario = Map<String, dynamic>.from(jsonDecode(sesion));
      });
    }
  }

  void _recargarComentarios() {
    setState(() {
      _futureComentarios = _comentarioService.obtenerComentariosPorBlog(widget.post.id);
    });
  }

  Future<void> _enviarComentario() async {
    final texto = _comentarioController.text.trim();
    if (texto.isEmpty) return;

    final idUsrRaw = _usuario['id_usr'] ?? _usuario['id'];
    final int idUsr = idUsrRaw != null ? int.tryParse(idUsrRaw.toString()) ?? 1 : 1;

    setState(() => _enviandoComentario = true);

    try {
      final nuevoComentario = ComentarioModel(
        id: 0,
        comentario: texto,
        fecha: DateTime.now().toIso8601String(),
        estatus: 1,
        usuarioId: idUsr,
        blogId: widget.post.id,
        autor: _usuario['nom_usr']?.toString() ?? 'Usuario',
      );

      await _comentarioService.agregarComentario(nuevoComentario);
      _comentarioController.clear();
      _recargarComentarios();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Comentario publicado correctamente'),
            backgroundColor: colorVino,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al publicar comentario: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _enviandoComentario = false);
      }
    }
  }

  Widget _construirImagen(String? ruta) {
    if (ruta == null || ruta.isEmpty) {
      return Container(
        height: 220,
        color: Colors.grey.shade200,
        child: const Center(
          child: Icon(Icons.pets, size: 60, color: colorDorado),
        ),
      );
    }

    final urlFinal = ruta.startsWith('http')
        ? ruta
        : 'http://127.0.0.1:8000$ruta';

    return Image.network(
      urlFinal,
      height: 240,
      width: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          height: 200,
          color: Colors.grey.shade200,
          child: const Center(
            child: Icon(Icons.pets, size: 50, color: colorVino),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorFondo,
      appBar: AppBar(
        title: const Text('Publicación'),
        backgroundColor: colorVino,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Actualizar comentarios',
            onPressed: _recargarComentarios,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _construirImagen(widget.post.imagen),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (widget.post.tags.isNotEmpty) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: colorDorado.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: colorDorado, width: 1),
                            ),
                            child: Text(
                              widget.post.tags,
                              style: const TextStyle(
                                color: colorVinoOscuro,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],

                        Text(
                          widget.post.titulo,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: colorVinoOscuro,
                            height: 1.25,
                          ),
                        ),
                        const SizedBox(height: 16),

                        Text(
                          widget.post.descripcion.isNotEmpty
                              ? widget.post.descripcion
                              : 'Esta publicación no contiene descripción adicional.',
                          style: const TextStyle(
                            fontSize: 16,
                            height: 1.6,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 28),

                        const Divider(thickness: 1.2),
                        const SizedBox(height: 12),

                        // Sección de comentarios
                        Row(
                          children: const [
                            Icon(Icons.comment_outlined, color: colorVino, size: 22),
                            SizedBox(width: 8),
                            Text(
                              'Comentarios de la Comunidad',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: colorVino,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        FutureBuilder<List<ComentarioModel>>(
                          future: _futureComentarios,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(20),
                                  child: CircularProgressIndicator(color: colorVino),
                                ),
                              );
                            }

                            if (snapshot.hasError) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                child: Text(
                                  'No se pudieron cargar los comentarios: ${snapshot.error}',
                                  style: const TextStyle(color: Colors.red),
                                ),
                              );
                            }

                            final comentarios = snapshot.data ?? [];
                            if (comentarios.isEmpty) {
                              return Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: Colors.grey.shade300),
                                ),
                                child: const Text(
                                  'Aún no hay comentarios en esta publicación. ¡Sé el primero en compartir tu opinión!',
                                  style: TextStyle(color: Colors.black54, fontStyle: FontStyle.italic),
                                ),
                              );
                            }

                            return ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: comentarios.length,
                              separatorBuilder: (_, __) => const SizedBox(height: 10),
                              itemBuilder: (context, index) {
                                final com = comentarios[index];
                                return Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.04),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                    border: Border.all(color: Colors.grey.shade200),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          CircleAvatar(
                                            radius: 14,
                                            backgroundColor: colorVino.withValues(alpha: 0.15),
                                            child: const Icon(Icons.person, size: 16, color: colorVino),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              com.autor,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                                color: colorVinoOscuro,
                                              ),
                                            ),
                                          ),
                                          if (com.fecha.isNotEmpty)
                                            Text(
                                              com.fecha.length >= 10 ? com.fecha.substring(0, 10) : com.fecha,
                                              style: const TextStyle(fontSize: 11, color: Colors.black45),
                                            ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        com.comentario,
                                        style: const TextStyle(fontSize: 14, color: Colors.black87),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Barra inferior para redactar un comentario
          Container(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 10,
              bottom: MediaQuery.of(context).padding.bottom + 10,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 6,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _comentarioController,
                    decoration: InputDecoration(
                      hintText: 'Escribe un comentario...',
                      hintStyle: const TextStyle(fontSize: 14, color: Colors.black45),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: const BorderSide(color: colorVino, width: 1.5),
                      ),
                      filled: true,
                      fillColor: colorFondo,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: colorVino,
                  radius: 22,
                  child: _enviandoComentario
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : IconButton(
                          icon: const Icon(Icons.send, color: Colors.white, size: 18),
                          onPressed: _enviarComentario,
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
