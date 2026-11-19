import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/services/auth_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  static const Color colorVino = Color(0xFF722F37);
  static const Color colorVinoOscuro = Color(0xFF5A252B);
  static const Color colorDorado = Color(0xFFD4AF37);
  static const Color colorFondo = Color(0xFFFAF7F5);

  final TextEditingController usuarioController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final AuthService authService = AuthService();

  bool ocultarPassword = true;
  bool cargando = false;

  @override
  void dispose() {
    usuarioController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> iniciarSesion() async {
    final mensaje = authService.validarLogin(
      usuario: usuarioController.text,
      password: passwordController.text,
    );

    if (mensaje != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(mensaje), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => cargando = true);

    try {
      final usuario = await authService.autenticar(
        correo: usuarioController.text.trim(),
        password: passwordController.text.trim(),
      );

      // GUARDA SIEMPRE LA SESIÓN (tanto para Admin como para Usuario)
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('usuario_sesion', jsonEncode(usuario));

      if (!mounted) return;

      final int tipoUsuario = (usuario['tip_usu'] as num? ?? 2).toInt();

      if (tipoUsuario == 1) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/users',
          (route) => false,
          arguments: usuario,
        );
      } else if (tipoUsuario == 2) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/blog',
          (route) => false,
          arguments: usuario,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('El tipo de usuario no tiene acceso asignado'),
          ),
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
      if (mounted) {
        setState(() => cargando = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorFondo,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 440),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: colorDorado.withValues(alpha: 0.7),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: colorVino.withValues(alpha: 0.10),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Cabecera Vino y Dorado con Logo Duncan
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [colorVino, colorVinoOscuro],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(3),
                        decoration: const BoxDecoration(
                          color: colorDorado,
                          shape: BoxShape.circle,
                        ),
                        child: ClipOval(
                          child: Image.network(
                            'http://127.0.0.1:8000/uploads/logo%20duncan.jpeg',
                            width: 76,
                            height: 76,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const CircleAvatar(
                              radius: 38,
                              backgroundColor: colorFondo,
                              child: Icon(Icons.pets, size: 42, color: colorVino),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Duncan Mascotas',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'INICIAR SESIÓN',
                        style: TextStyle(
                          color: colorDorado,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
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
                        controller: usuarioController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: 'Correo electrónico',
                          prefixIcon: const Icon(Icons.email_outlined, color: colorVino),
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
                            onPressed: () {
                              setState(() => ocultarPassword = !ocultarPassword);
                            },
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
                      const SizedBox(height: 24),
                      cargando
                          ? const CircularProgressIndicator(color: colorVino)
                          : SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: colorVino,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    side: const BorderSide(color: colorDorado, width: 1),
                                  ),
                                ),
                                icon: const Icon(Icons.login, color: colorDorado),
                                label: const Text(
                                  'INGRESAR',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                onPressed: iniciarSesion,
                              ),
                            ),
                      const SizedBox(height: 14),
                      TextButton(
                        onPressed: () => Navigator.pushNamed(context, '/register'),
                        child: const Text(
                          '¿No tienes cuenta? Regístrate aquí',
                          style: TextStyle(
                            color: colorVino,
                            fontWeight: FontWeight.w600,
                          ),
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