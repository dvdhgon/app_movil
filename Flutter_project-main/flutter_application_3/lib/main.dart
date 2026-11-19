import 'package:flutter/material.dart';
import 'screens/add_blog_page.dart';
import 'screens/blog_page.dart';
import 'screens/login_user_page.dart';
import 'screens/mapa_page.dart';
import 'screens/profile_page.dart';
import 'screens/register_user_page.dart';
import 'screens/users_page.dart';

void main() {
  runApp(const LoginApp());
}

class LoginApp extends StatelessWidget {
  const LoginApp({super.key});

  static const Color colorVino = Color(0xFF722F37);
  static const Color colorDorado = Color(0xFFD4AF37);
  static const Color colorFondo = Color(0xFFFAF7F5);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Duncan Mascotas',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: colorFondo,
        colorScheme: ColorScheme.fromSeed(
          seedColor: colorVino,
          primary: colorVino,
          secondary: colorDorado,
          surface: Colors.white,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: colorVino,
          foregroundColor: Colors.white,
          elevation: 2,
          iconTheme: IconThemeData(color: Colors.white),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: colorVino,
          foregroundColor: Colors.white,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: colorVino,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: colorDorado, width: 1),
            ),
          ),
        ),
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/users': (context) => const UsersPage(),
        '/blog': (context) => const BlogPage(),
        '/add-blog': (context) => const AddBlogPage(),
        '/add_blog': (context) => const AddBlogPage(),
        '/profile': (context) => const ProfilePage(),
        '/mapa': (context) => const MapaPage(),
      },
    );
  }
}