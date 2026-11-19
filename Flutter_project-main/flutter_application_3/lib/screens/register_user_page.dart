import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../models/services/user_service.dart';
import '../widgets/admin_drawer.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  static const Color colorVino = Color(0xFF722F37);
  static const Color colorVinoOscuro = Color(0xFF5A252B);
  static const Color colorDorado = Color(0xFFD4AF37);
  static const Color colorFondo = Color(0xFFFAF7F5);

  final TextEditingController nombreController = TextEditingController();
  final TextEditingController correoController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController direccionController = TextEditingController();
  final UserService userService = UserService();

  int tipoUsuario = 2;
  bool ocultarPassword = true;
  bool cargando = false;

  Map<String, dynamic> usuarioActual = {'tip_usu': 2};
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
    nombreController.dispose();
    correoController.dispose();
    passwordController.dispose();
    direccionController.dispose();
    super.dispose();
  }

  Future<void> registrar() async {
    if (nombreController.text.trim().isEmpty ||
        correoController.text.trim().isEmpty ||
        passwordController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Completa nombre, correo y contraseña'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => cargando = true);

    try {
      final nuevo = UserModel(
        nombre: nombreController.text.trim(),
        correo: correoController.text.trim(),
        password: passwordController.text.trim(),
        direccion: direccionController.text.trim(),
        tipoUsuario: esAdmin ? tipoUsuario : 2,
      );

      await userService.agregarUsuario(nuevo);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Usuario registrado correctamente'),
          backgroundColor: Colors.green,
        ),
      );

      if (esAdmin) {
        if (Navigator.canPop(context)) {
          Navigator.pop(context, true);
        } else {
          Navigator.pushReplacementNamed(context, '/users', arguments: usuarioActual);
        }
      } else {
        Navigator.pushReplacementNamed(context, '/login');
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
        title: const Text(
          'Registro de Usuario',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(3),
          child: Container(color: colorDorado, height: 3),
        ),
      ),
      drawer: esAdmin
          ? AdminDrawer(usuario: usuarioActual, rutaActual: '/register')
          : null,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 460),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: colorDorado.withValues(alpha: 0.7), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: colorVino.withValues(alpha: 0.08),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [colorVino, colorVinoOscuro],
                    ),
                    borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.person_add, color: colorDorado, size: 28),
                      SizedBox(width: 12),
                      Text(
                        'Crear nueva cuenta',
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
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      TextField(
                        controller: nombreController,
                        decoration: InputDecoration(
                          labelText: 'Nombre completo',
                          prefixIcon: const Icon(Icons.person_outline, color: colorVino),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: correoController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: 'Correo electrónico',
                          prefixIcon: const Icon(Icons.email_outlined, color: colorVino),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: direccionController,
                        decoration: InputDecoration(
                          labelText: 'Dirección (opcional)',
                          prefixIcon: const Icon(Icons.location_on_outlined, color: colorVino),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: passwordController,
                        obscureText: ocultarPassword,
                        decoration: InputDecoration(
                          labelText: 'Contraseña',
                          prefixIcon: const Icon(Icons.lock_outline, color: colorVino),
                          suffixIcon: IconButton(
                            icon: Icon(
                              ocultarPassword
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: colorVino,
                            ),
                            onPressed: () =>
                                setState(() => ocultarPassword = !ocultarPassword),
                          ),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                      if (esAdmin) ...[
                        const SizedBox(height: 14),
                        DropdownButtonFormField<int>(
                          initialValue: tipoUsuario,
                          decoration: InputDecoration(
                            labelText: 'Tipo de Usuario',
                            prefixIcon: const Icon(Icons.admin_panel_settings,
                                color: colorVino),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                          items: const [
                            DropdownMenuItem(value: 1, child: Text('Administrador')),
                            DropdownMenuItem(value: 2, child: Text('Usuario Normal')),
                          ],
                          onChanged: (v) {
                            if (v != null) setState(() => tipoUsuario = v);
                          },
                        ),
                      ],
                      const SizedBox(height: 24),
                      cargando
                          ? const CircularProgressIndicator(color: colorVino)
                          : SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: colorVino,
                                  foregroundColor: Colors.white,
                                  side: const BorderSide(color: colorDorado),
                                ),
                                icon: const Icon(Icons.check, color: colorDorado),
                                label: const Text(
                                  'REGISTRAR',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                onPressed: registrar,
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