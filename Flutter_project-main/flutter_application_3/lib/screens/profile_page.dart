import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../models/services/user_service.dart';
import '../widgets/admin_drawer.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  static const Color colorVino = Color(0xFF722F37);
  static const Color colorVinoOscuro = Color(0xFF5A252B);
  static const Color colorDorado = Color(0xFFD4AF37);
  static const Color colorFondo = Color(0xFFFAF7F5);

  final UserService userService = UserService();
  final ImagePicker _picker = ImagePicker();
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nombreCtrl;
  late TextEditingController _correoCtrl;
  late TextEditingController _dirCtrl;
  late TextEditingController _passCtrl;

  Map<String, dynamic> usuarioActual = {};
  XFile? _fotoSeleccionada;
  Uint8List? _fotoBytes;

  bool _argumentoLeido = false;
  bool _cargando = false;
  bool _cargandoInicial = true;

  @override
  void initState() {
    super.initState();
    _nombreCtrl = TextEditingController();
    _correoCtrl = TextEditingController();
    _dirCtrl = TextEditingController();
    _passCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _correoCtrl.dispose();
    _dirCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_argumentoLeido) {
      _argumentoLeido = true;
      _inicializarYSincronizar();
    }
  }

  Future<void> _inicializarYSincronizar() async {
    final argumento = ModalRoute.of(context)?.settings.arguments;
    final prefs = await SharedPreferences.getInstance();

    // 1. Cargar desde argumentos o desde memoria persistente
    if (argumento is Map<String, dynamic> && argumento.isNotEmpty) {
      usuarioActual = Map<String, dynamic>.from(argumento);
    } else {
      final sesionGuardada = prefs.getString('usuario_sesion');
      if (sesionGuardada != null) {
        usuarioActual = Map<String, dynamic>.from(jsonDecode(sesionGuardada));
      }
    }

    _rellenarControladores();

    // 2. Consultar datos frescos directamente desde MySQL
    try {
      final rawId = usuarioActual['id_usr'] ??
          usuarioActual['id_usuario'] ??
          usuarioActual['id'];
      final int? idParseado = int.tryParse(rawId?.toString() ?? '');
      UserModel? usuarioBd;

      if (idParseado != null && idParseado > 0) {
        try {
          usuarioBd = await userService.obtenerUsuarioPorId(idParseado);
        } catch (_) {}
      }

      if (usuarioBd == null) {
        final correoLocal =
            (usuarioActual['mail'] ?? usuarioActual['correo'] ?? '').toString();
        if (correoLocal.isNotEmpty) {
          usuarioBd = await userService.buscarPorCorreo(correoLocal);
        }
      }

      if (usuarioBd != null && mounted) {
        usuarioActual = usuarioBd.toMap();
        await prefs.setString('usuario_sesion', jsonEncode(usuarioActual));
        _rellenarControladores();
      }
    } catch (_) {
    } finally {
      if (mounted) {
        setState(() => _cargandoInicial = false);
      }
    }
  }

  void _rellenarControladores() {
    _nombreCtrl.text =
        (usuarioActual['nom_usr'] ?? usuarioActual['nombre'] ?? '').toString();
    _correoCtrl.text =
        (usuarioActual['mail'] ?? usuarioActual['correo'] ?? '').toString();
    _dirCtrl.text =
        (usuarioActual['dir_usr'] ?? usuarioActual['direccion'] ?? '').toString();
  }

  void _mostrarOpcionesFoto() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (BuildContext bc) {
        return SafeArea(
          child: Wrap(
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Text(
                  'Cambiar foto de perfil',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: colorVino,
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: colorVino),
                title: const Text('Elegir foto desde el dispositivo'),
                onTap: () {
                  Navigator.of(context).pop();
                  _seleccionarImagen(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera, color: colorVino),
                title: const Text('Tomar fotografía con cámara'),
                onTap: () {
                  Navigator.of(context).pop();
                  _seleccionarImagen(ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _seleccionarImagen(ImageSource origen) async {
    try {
      final imagen = await _picker.pickImage(
        source: origen,
        imageQuality: 80,
      );
      if (imagen != null) {
        final bytes = await imagen.readAsBytes();
        setState(() {
          _fotoSeleccionada = imagen;
          _fotoBytes = bytes;
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No se pudo seleccionar la imagen: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _actualizarPerfil() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _cargando = true);

    try {
      final rawId = usuarioActual['id_usr'] ??
          usuarioActual['id_usuario'] ??
          usuarioActual['id'];
      int? idReal = int.tryParse(rawId?.toString() ?? '');

      if (idReal == null || idReal <= 0) {
        final encontrado =
            await userService.buscarPorCorreo(_correoCtrl.text.trim());
        idReal = encontrado?.id;
      }

      if (idReal == null) {
        throw Exception('No se encontró tu usuario en la base de datos.');
      }

      String? rutaFotoActual = usuarioActual['foto_perfil']?.toString();
      if (_fotoSeleccionada != null) {
        final conFoto =
            await userService.subirFotoPerfil(idReal, _fotoSeleccionada!);
        rutaFotoActual = conFoto.fotoPerfil;
      }

      final usuarioEditado = UserModel(
        id: idReal,
        nombre: _nombreCtrl.text.trim(),
        correo: _correoCtrl.text.trim().toLowerCase(),
        direccion: _dirCtrl.text.trim().isEmpty ? null : _dirCtrl.text.trim(),
        tipoUsuario: (usuarioActual['tip_usu'] as num? ?? 2).toInt(),
        fotoPerfil: rutaFotoActual,
        password: _passCtrl.text.trim().isEmpty ? null : _passCtrl.text.trim(),
      );

      final usuarioActualizado =
          await userService.actualizarUsuario(usuarioEditado);

      final prefs = await SharedPreferences.getInstance();
      final nuevoMapa = usuarioActualizado.toMap();
      await prefs.setString('usuario_sesion', jsonEncode(nuevoMapa));

      if (mounted) {
        setState(() {
          usuarioActual = nuevoMapa;
          _fotoSeleccionada = null;
          _passCtrl.clear();
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Perfil actualizado y guardado en la base de datos!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error al actualizar: ${e.toString().replaceFirst("Exception: ", "")}',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _cargando = false);
      }
    }
  }

  bool get esAdmin {
    final tipUsu = usuarioActual['tip_usu'];
    return tipUsu == 1 || tipUsu.toString() == '1';
  }

  String? get _urlFotoServidor {
    final ruta = usuarioActual['foto_perfil']?.toString();
    if (ruta == null || ruta.isEmpty) return null;
    if (ruta.startsWith('http')) return ruta;
    return '${UserService.baseUrl}$ruta';
  }

  @override
  Widget build(BuildContext context) {
    final String? urlFoto = _urlFotoServidor;

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
                errorBuilder: (_, __, ___) => Image.network(
                  'http://127.0.0.1:8000/uploads/logo%20duncan.png',
                  width: 34,
                  height: 34,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      const Icon(Icons.pets, color: colorDorado, size: 24),
                ),
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'Mi Perfil · Duncan Mascotas',
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
          ? AdminDrawer(usuario: usuarioActual, rutaActual: '/profile')
          : null,
      body: _cargandoInicial
          ? const Center(child: CircularProgressIndicator(color: colorVino))
          : Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 520),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: colorDorado.withValues(alpha: 0.65),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: colorVino.withValues(alpha: 0.08),
                        blurRadius: 18,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          vertical: 24,
                          horizontal: 20,
                        ),
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [colorVino, colorVinoOscuro],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(14),
                          ),
                        ),
                        child: Column(
                          children: [
                            Stack(
                              alignment: Alignment.bottomRight,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(3),
                                  decoration: const BoxDecoration(
                                    color: colorDorado,
                                    shape: BoxShape.circle,
                                  ),
                                  child: CircleAvatar(
                                    radius: 48,
                                    backgroundColor: colorFondo,
                                    backgroundImage: _fotoBytes != null
                                        ? MemoryImage(_fotoBytes!)
                                        : (urlFoto != null
                                            ? NetworkImage(urlFoto)
                                                as ImageProvider
                                            : null),
                                    child: (_fotoBytes == null &&
                                            urlFoto == null)
                                        ? const Icon(
                                            Icons.person,
                                            size: 52,
                                            color: colorVino,
                                          )
                                        : null,
                                  ),
                                ),
                                InkWell(
                                  onTap: _mostrarOpcionesFoto,
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: colorDorado,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 2,
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.camera_alt,
                                      size: 18,
                                      color: colorVinoOscuro,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              _nombreCtrl.text.isEmpty
                                  ? 'Usuario'
                                  : _nombreCtrl.text,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: colorDorado,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                esAdmin ? 'Administrador' : 'Miembro Duncan',
                                style: const TextStyle(
                                  color: colorVinoOscuro,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(24),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              TextFormField(
                                controller: _nombreCtrl,
                                decoration: InputDecoration(
                                  labelText: 'Nombre completo',
                                  prefixIcon: const Icon(
                                    Icons.person_outline,
                                    color: colorVino,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(
                                      color: colorVino,
                                      width: 2,
                                    ),
                                  ),
                                ),
                                validator: (v) => v == null || v.trim().isEmpty
                                    ? 'El nombre es obligatorio'
                                    : null,
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _correoCtrl,
                                keyboardType: TextInputType.emailAddress,
                                decoration: InputDecoration(
                                  labelText: 'Correo electrónico',
                                  prefixIcon: const Icon(
                                    Icons.email_outlined,
                                    color: colorVino,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(
                                      color: colorVino,
                                      width: 2,
                                    ),
                                  ),
                                ),
                                validator: (v) {
                                  if (v == null || v.trim().isEmpty) {
                                    return 'El correo es obligatorio';
                                  }
                                  if (!v.contains('@')) {
                                    return 'Ingresa un correo válido';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _dirCtrl,
                                decoration: InputDecoration(
                                  labelText: 'Dirección (Opcional)',
                                  prefixIcon: const Icon(
                                    Icons.location_on_outlined,
                                    color: colorVino,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(
                                      color: colorVino,
                                      width: 2,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _passCtrl,
                                obscureText: true,
                                decoration: InputDecoration(
                                  labelText: 'Nueva contraseña (Opcional)',
                                  hintText: 'Dejar vacío para conservar actual',
                                  prefixIcon: const Icon(
                                    Icons.lock_outline,
                                    color: colorVino,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(
                                      color: colorVino,
                                      width: 2,
                                    ),
                                  ),
                                ),
                                validator: (v) {
                                  if (v != null &&
                                      v.trim().isNotEmpty &&
                                      v.trim().length < 6) {
                                    return 'Mínimo 6 caracteres';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 24),
                              _cargando
                                  ? const CircularProgressIndicator(
                                      color: colorVino,
                                    )
                                  : SizedBox(
                                      width: double.infinity,
                                      height: 50,
                                      child: ElevatedButton.icon(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: colorVino,
                                          foregroundColor: Colors.white,
                                          elevation: 2,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            side: const BorderSide(
                                              color: colorDorado,
                                              width: 1,
                                            ),
                                          ),
                                        ),
                                        icon: const Icon(
                                          Icons.save,
                                          color: colorDorado,
                                        ),
                                        label: const Text(
                                          'Guardar cambios',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        onPressed: _actualizarPerfil,
                                      ),
                                    ),
                            ],
                          ),
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