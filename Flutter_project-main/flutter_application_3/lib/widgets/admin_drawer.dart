import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/services/user_service.dart';

class AdminDrawer extends StatefulWidget {
  final Map<String, dynamic> usuario;
  final String rutaActual;

  const AdminDrawer({
    super.key,
    required this.usuario,
    required this.rutaActual,
  });

  @override
  State<AdminDrawer> createState() => _AdminDrawerState();
}

class _AdminDrawerState extends State<AdminDrawer> {
  static const Color colorVino = Color(0xFF722F37);
  static const Color colorVinoOscuro = Color(0xFF5A252B);
  static const Color colorDorado = Color(0xFFD4AF37);

  late Map<String, dynamic> _usuarioActual;

  @override
  void initState() {
    super.initState();
    _usuarioActual = Map<String, dynamic>.from(widget.usuario);
    _cargarSesionActualizada();
  }

  Future<void> _cargarSesionActualizada() async {
    final prefs = await SharedPreferences.getInstance();
    final sesion = prefs.getString('usuario_sesion');
    if (sesion != null && mounted) {
      setState(() {
        _usuarioActual = Map<String, dynamic>.from(jsonDecode(sesion));
      });
    }
  }

  String get nombre =>
      _usuarioActual['nom_usr']?.toString() ??
      _usuarioActual['nombre']?.toString() ??
      'Administrador';

  String get correo =>
      _usuarioActual['mail']?.toString() ??
      _usuarioActual['correo']?.toString() ??
      '';

  String? get urlFoto {
    final ruta = _usuarioActual['foto_perfil']?.toString();
    if (ruta == null || ruta.isEmpty) return null;
    if (ruta.startsWith('http')) return ruta;
    return '${UserService.baseUrl}$ruta';
  }

  void _navegar(BuildContext context, String ruta) {
    Navigator.pop(context);
    if (ruta == widget.rutaActual) return;
    Navigator.pushReplacementNamed(
      context,
      ruta,
      arguments: _usuarioActual,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFFFAF7F5),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 45, bottom: 20, left: 20, right: 20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [colorVino, colorVinoOscuro],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border(
                bottom: BorderSide(color: colorDorado, width: 3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(2.5),
                  decoration: const BoxDecoration(
                    color: colorDorado,
                    shape: BoxShape.circle,
                  ),
                  child: CircleAvatar(
                    radius: 34,
                    backgroundColor: const Color(0xFFFAF7F5),
                    backgroundImage:
                        urlFoto != null ? NetworkImage(urlFoto!) : null,
                    child: urlFoto == null
                        ? const Icon(Icons.person, color: colorVino, size: 36)
                        : null,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  nombre,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (correo.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    correo,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: colorDorado,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Administrador',
                    style: TextStyle(
                      color: colorVinoOscuro,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 10),
              children: [
                _opcion(context, Icons.article_outlined, 'Ver Blog', '/blog'),
                _opcion(context, Icons.group_outlined, 'Gestión de usuarios', '/users'),
                _opcion(context, Icons.person_add_alt_1_outlined, 'Registrar usuario', '/register'),
                _opcion(context, Icons.post_add, 'Agregar blog', '/add-blog'),
                _opcion(context, Icons.map_outlined, 'Mapa de lugares', '/mapa'),
                _opcion(context, Icons.account_circle_outlined, 'Mi perfil', '/profile'),
              ],
            ),
          ),
          const Divider(height: 1),
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text(
              'Cerrar sesión',
              style: TextStyle(
                color: Colors.red,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            onTap: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.remove('usuario_sesion');
              if (!context.mounted) return;
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/login',
                (route) => false,
              );
            },
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom + 8),
        ],
      ),
    );
  }

  Widget _opcion(
    BuildContext context,
    IconData icono,
    String titulo,
    String ruta,
  ) {
    final seleccionado = ruta == widget.rutaActual;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 2),
      leading: Icon(
        icono,
        color: seleccionado ? colorVino : Colors.black87,
        size: 25,
      ),
      title: Text(
        titulo,
        style: TextStyle(
          color: seleccionado ? colorVino : Colors.black87,
          fontSize: 15,
          fontWeight: seleccionado ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: seleccionado,
      selectedTileColor: colorVino.withValues(alpha: 0.08),
      onTap: () => _navegar(context, ruta),
    );
  }
}