import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/services/post_service.dart';
import '../widgets/admin_drawer.dart';

class AddBlogPage extends StatefulWidget {
  const AddBlogPage({super.key});

  @override
  State<AddBlogPage> createState() => _AddBlogPageState();
}

class _AddBlogPageState extends State<AddBlogPage> {
  static const Color colorVino = Color(0xFF722F37);
  static const Color colorVinoOscuro = Color(0xFF5A252B);
  static const Color colorDorado = Color(0xFFD4AF37);
  static const Color colorFondo = Color(0xFFFAF7F5);

  final TextEditingController tituloController = TextEditingController();
  final TextEditingController descripcionController = TextEditingController();
  final TextEditingController tagsController = TextEditingController();
  final PostService postService = PostService();
  final ImagePicker _picker = ImagePicker();

  Uint8List? _imagenBytes;
  String? _imagenBase64;
  bool cargando = false;

  Map<String, dynamic> usuarioActual = {
    'nom_usr': 'Usuario',
    'mail': '',
    'tip_usu': 2,
  };
  bool _sesionCargada = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_sesionCargada) {
      _sesionCargada = true;
      _cargarSesion();
    }
  }

  Future<void> _cargarSesion() async {
    final argumento = ModalRoute.of(context)?.settings.arguments;
    final prefs = await SharedPreferences.getInstance();

    if (argumento is Map<String, dynamic> && argumento.isNotEmpty) {
      usuarioActual = Map<String, dynamic>.from(argumento);
    } else {
      final sesion = prefs.getString('usuario_sesion');
      if (sesion != null) {
        usuarioActual = Map<String, dynamic>.from(jsonDecode(sesion));
      }
    }
    if (mounted) setState(() {});
  }

  bool get esAdmin {
    final tipUsu = usuarioActual['tip_usu'];
    return tipUsu == 1 || tipUsu.toString() == '1';
  }

  @override
  void dispose() {
    tituloController.dispose();
    descripcionController.dispose();
    tagsController.dispose();
    super.dispose();
  }

  Future<void> _seleccionarImagen(ImageSource source) async {
    try {
      final XFile? archivo = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        imageQuality: 80,
      );
      if (archivo != null) {
        final bytes = await archivo.readAsBytes();
        final ext = archivo.name.split('.').last.toLowerCase();
        final mime = ext == 'png' ? 'image/png' : 'image/jpeg';
        setState(() {
          _imagenBytes = bytes;
          _imagenBase64 = 'data:$mime;base64,${base64Encode(bytes)}';
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No se pudo cargar la imagen: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _mostrarOpcionesImagen() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library, color: colorVino),
                title: const Text('Seleccionar del dispositivo / galería'),
                onTap: () {
                  Navigator.pop(context);
                  _seleccionarImagen(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: colorVino),
                title: const Text('Tomar foto con la cámara'),
                onTap: () {
                  Navigator.pop(context);
                  _seleccionarImagen(ImageSource.camera);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _publicar() async {
    final titulo = tituloController.text.trim();
    final descripcion = descripcionController.text.trim();
    final tags = tagsController.text.trim();

    if (titulo.isEmpty || descripcion.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor completa el título y la descripción'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => cargando = true);

    try {
      await postService.agregarPost(
        titulo: titulo,
        descripcion: descripcion,
        imagen: _imagenBase64,
        tags: tags.isNotEmpty ? tags : null,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('¡Publicación creada correctamente!'),
          backgroundColor: Colors.green,
        ),
      );

      if (Navigator.canPop(context)) {
        Navigator.pop(context, true);
      } else {
        Navigator.pushReplacementNamed(
          context,
          '/blog',
          arguments: usuarioActual,
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorFondo,
      appBar: AppBar(
        backgroundColor: colorVino,
        foregroundColor: Colors.white,
        elevation: 2,
        title: Row(
          children: [
            ClipOval(
              child: Image.network(
                'http://127.0.0.1:8000/uploads/logo%20duncan.jpeg',
                width: 34,
                height: 34,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    const Icon(Icons.pets, color: colorDorado, size: 24),
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'Nueva Publicación',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(3),
          child: Container(color: colorDorado, height: 3),
        ),
      ),
      drawer: esAdmin
          ? AdminDrawer(usuario: usuarioActual, rutaActual: '/add-blog')
          : null,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 540),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: colorDorado.withValues(alpha: 0.7),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: colorVino.withValues(alpha: 0.08),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Cabecera Vino
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [colorVino, colorVinoOscuro],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.post_add, color: colorDorado, size: 28),
                      SizedBox(width: 12),
                      Text(
                        'Crear artículo en el Blog',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextField(
                        controller: tituloController,
                        decoration: InputDecoration(
                          labelText: 'Título del Blog',
                          prefixIcon: const Icon(Icons.title, color: colorVino),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: colorVino, width: 2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: descripcionController,
                        maxLines: 4,
                        decoration: InputDecoration(
                          labelText: 'Descripción',
                          alignLabelWithHint: true,
                          prefixIcon: const Padding(
                            padding: EdgeInsets.only(bottom: 58),
                            child: Icon(Icons.description_outlined, color: colorVino),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: colorVino, width: 2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: tagsController,
                        decoration: InputDecoration(
                          labelText: 'Etiquetas (opcional, ej: perros, cuidados)',
                          prefixIcon: const Icon(Icons.tag, color: colorVino),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: colorVino, width: 2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Vista previa de la imagen
                      if (_imagenBytes != null) ...[
                        Stack(
                          alignment: Alignment.topRight,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.memory(
                                _imagenBytes!,
                                height: 210,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: CircleAvatar(
                                radius: 16,
                                backgroundColor: colorVino,
                                child: IconButton(
                                  padding: EdgeInsets.zero,
                                  icon: const Icon(Icons.close,
                                      size: 18, color: Colors.white),
                                  onPressed: () {
                                    setState(() {
                                      _imagenBytes = null;
                                      _imagenBase64 = null;
                                    });
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                      ],

                      // Botón Elegir Imagen en estilo Vino y Dorado
                      Center(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: colorVino,
                            side: const BorderSide(color: colorDorado, width: 1.5),
                            backgroundColor: colorFondo,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          icon: const Icon(Icons.add_photo_alternate, color: colorVino),
                          label: Text(
                            _imagenBytes == null ? 'Elegir Imagen' : 'Cambiar Imagen',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          onPressed: _mostrarOpcionesImagen,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Botón PUBLICAR en color Vino con borde Dorado
                      cargando
                          ? const Center(
                              child: CircularProgressIndicator(color: colorVino),
                            )
                          : SizedBox(
                              height: 50,
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: colorVino,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    side: const BorderSide(
                                        color: colorDorado, width: 1.2),
                                  ),
                                ),
                                icon: const Icon(Icons.publish, color: colorDorado),
                                label: const Text(
                                  'PUBLICAR',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1,
                                  ),
                                ),
                                onPressed: _publicar,
                              ),
                            ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}