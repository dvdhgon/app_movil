import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../models/services/user_service.dart';
import '../widgets/admin_drawer.dart';

class UsersPage extends StatefulWidget {
  const UsersPage({super.key});

  @override
  State<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  static const Color colorVino = Color(0xFF722F37);
  static const Color colorVinoOscuro = Color(0xFF5A252B);
  static const Color colorDorado = Color(0xFFD4AF37);
  static const Color colorFondo = Color(0xFFFAF7F5);

  final UserService userService = UserService();
  late Future<List<UserModel>> futureUsers;

  Map<String, dynamic> usuarioActual = {
    'nom_usr': 'Administrador',
    'mail': '',
    'tip_usu': 1,
  };
  bool _sesionCargada = false;

  @override
  void initState() {
    super.initState();
    futureUsers = userService.obtenerUsuarios();
  }

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

  void _recargar() {
    setState(() {
      futureUsers = userService.obtenerUsuarios();
    });
  }

  bool get esAdmin {
    final tipUsu = usuarioActual['tip_usu'];
    return tipUsu == 1 || tipUsu.toString() == '1';
  }

  // Modal para editar la información de un usuario registrado
  void _mostrarModalEditar(UserModel usuario) {
    final nombreCtrl = TextEditingController(text: usuario.nombre);
    final correoCtrl = TextEditingController(text: usuario.correo);
    final direccionCtrl = TextEditingController(text: usuario.direccion ?? '');
    int tipoSeleccionado = usuario.tipoUsuario;
    bool guardando = false;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (modalContext, setModalState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: colorDorado, width: 1.5),
              ),
              title: Row(
                children: [
                  const Icon(Icons.edit, color: colorVino),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Editar Usuario #${usuario.id}',
                      style: const TextStyle(
                        color: colorVino,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nombreCtrl,
                      decoration: InputDecoration(
                        labelText: 'Nombre completo',
                        prefixIcon: const Icon(Icons.person_outline, color: colorVino),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: correoCtrl,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: 'Correo electrónico',
                        prefixIcon: const Icon(Icons.email_outlined, color: colorVino),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: direccionCtrl,
                      decoration: InputDecoration(
                        labelText: 'Dirección',
                        prefixIcon: const Icon(Icons.location_on_outlined, color: colorVino),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    DropdownButtonFormField<int>(
                      initialValue: tipoSeleccionado,
                      decoration: InputDecoration(
                        labelText: 'Rol del usuario',
                        prefixIcon: const Icon(
                          Icons.admin_panel_settings_outlined,
                          color: colorVino,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      items: const [
                        DropdownMenuItem(value: 1, child: Text('Administrador (1)')),
                        DropdownMenuItem(value: 2, child: Text('Usuario Normal (2)')),
                      ],
                      onChanged: (valor) {
                        if (valor != null) {
                          setModalState(() => tipoSeleccionado = valor);
                        }
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: guardando ? null : () => Navigator.pop(dialogContext),
                  child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorVino,
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: colorDorado),
                  ),
                  icon: guardando
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.save, color: colorDorado, size: 18),
                  label: Text(guardando ? 'Guardando...' : 'Guardar'),
                  onPressed: guardando
                      ? null
                      : () async {
                          final scaffoldMessenger = ScaffoldMessenger.of(context);
                          final navigator = Navigator.of(dialogContext);

                          if (nombreCtrl.text.trim().isEmpty ||
                              correoCtrl.text.trim().isEmpty) {
                            scaffoldMessenger.showSnackBar(
                              const SnackBar(
                                content: Text('El nombre y correo son obligatorios'),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }

                          setModalState(() => guardando = true);

                          try {
                            final usuarioEditado = UserModel(
                              id: usuario.id,
                              nombre: nombreCtrl.text.trim(),
                              correo: correoCtrl.text.trim(),
                              direccion: direccionCtrl.text.trim(),
                              tipoUsuario: tipoSeleccionado,
                            );

                            await userService.actualizarUsuario(usuarioEditado);

                            if (!mounted) return;
                            navigator.pop();
                            _recargar();
                            scaffoldMessenger.showSnackBar(
                              const SnackBar(
                                content: Text('Usuario actualizado correctamente'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          } catch (e) {
                            if (modalContext.mounted) {
                              setModalState(() => guardando = false);
                            }
                            if (!mounted) return;
                            scaffoldMessenger.showSnackBar(
                              SnackBar(
                                content: Text(
                                  e.toString().replaceFirst('Exception: ', ''),
                                ),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Confirmación para eliminar usuario
  void _confirmarEliminar(UserModel usuario) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Eliminar usuario', style: TextStyle(color: colorVino)),
        content: Text('¿Seguro que deseas eliminar a "${usuario.nombre}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              final scaffoldMessenger = ScaffoldMessenger.of(context);
              Navigator.pop(dialogContext);

              try {
                await userService.eliminarUsuario(usuario.id!);
                if (!mounted) return;
                _recargar();
                scaffoldMessenger.showSnackBar(
                  const SnackBar(
                    content: Text('Usuario eliminado'),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                if (!mounted) return;
                scaffoldMessenger.showSnackBar(
                  SnackBar(
                    content: Text(e.toString().replaceFirst('Exception: ', '')),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Eliminar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
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
              'Usuarios · Duncan Mascotas',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Registrar nuevo usuario',
            icon: const Icon(Icons.person_add, color: colorDorado),
            onPressed: () async {
              await Navigator.pushNamed(
                context,
                '/register',
                arguments: usuarioActual,
              );
              _recargar();
            },
          ),
          IconButton(
            tooltip: 'Actualizar',
            icon: const Icon(Icons.refresh),
            onPressed: _recargar,
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(3),
          child: Container(color: colorDorado, height: 3),
        ),
      ),
      drawer: esAdmin
          ? AdminDrawer(usuario: usuarioActual, rutaActual: '/users')
          : null,
      body: FutureBuilder<List<UserModel>>(
        future: futureUsers,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: colorVino),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: colorVino),
                  const SizedBox(height: 12),
                  Text('Error: ${snapshot.error}'),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: _recargar,
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          final usuarios = snapshot.data ?? [];
          if (usuarios.isEmpty) {
            return const Center(child: Text('No hay usuarios registrados.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: usuarios.length,
            itemBuilder: (context, index) {
              final usr = usuarios[index];
              final isAdmin = usr.tipoUsuario == 1;

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: colorDorado.withValues(alpha: 0.65),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: colorVino.withValues(alpha: 0.06),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  leading: CircleAvatar(
                    backgroundColor: colorVino,
                    child: Icon(
                      isAdmin ? Icons.admin_panel_settings : Icons.person,
                      color: colorDorado,
                    ),
                  ),
                  title: Row(
                    children: [
                      Flexible(
                        child: Text(
                          usr.nombre,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: colorVinoOscuro,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: isAdmin ? colorDorado : colorFondo,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: colorDorado),
                        ),
                        child: Text(
                          isAdmin ? 'Admin' : 'Usuario',
                          style: TextStyle(
                            color: isAdmin ? colorVinoOscuro : colorVino,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 3),
                      Text(usr.correo),
                      if (usr.direccion != null && usr.direccion!.isNotEmpty)
                        Text(
                          'Dir: ${usr.direccion}',
                          style: const TextStyle(fontSize: 12, color: Colors.black54),
                        ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        tooltip: 'Editar usuario',
                        icon: const Icon(Icons.edit, color: colorVino),
                        onPressed: () => _mostrarModalEditar(usr),
                      ),
                      IconButton(
                        tooltip: 'Eliminar usuario',
                        icon: const Icon(Icons.delete_outline, color: Colors.red),
                        onPressed: () => _confirmarEliminar(usr),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}