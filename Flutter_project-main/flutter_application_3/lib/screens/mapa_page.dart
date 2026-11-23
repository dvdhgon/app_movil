import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/admin_drawer.dart';

class MapaPage extends StatefulWidget {
  const MapaPage({super.key});

  @override
  State<MapaPage> createState() => _MapaPageState();
}

class _MapaPageState extends State<MapaPage> {
  static const Color colorVino = Color(0xFF722F37);

  final LatLng _centroQro = const LatLng(20.588793, -100.389888);

  Map<String, dynamic> usuarioActual = {
    'nom_usr': 'Administrador',
    'mail': '',
    'tip_usu': 1,
  };
  bool _sesionCargada = false;

  final Set<Marker> _misMarcadores = {
    const Marker(
      markerId: MarkerId('infantes'),
      position: LatLng(20.6498, -100.4045),
      infoWindow: InfoWindow(
        title: 'Calle de los Infantes',
        snippet: 'Punto de interés y ruta canina - Duncan Mascotas',
      ),
    ),
    const Marker(
      markerId: MarkerId('centro'),
      position: LatLng(20.588793, -100.389888),
      infoWindow: InfoWindow(title: 'Centro Histórico', snippet: 'Plaza de Armas'),
    ),
    const Marker(
      markerId: MarkerId('arcos'),
      position: LatLng(20.593649, -100.370395),
      infoWindow: InfoWindow(title: 'Los Arcos', snippet: 'Acueducto de Querétaro'),
    ),
    const Marker(
      markerId: MarkerId('alameda'),
      position: LatLng(20.587836, -100.387063),
      infoWindow: InfoWindow(title: 'Alameda Hidalgo', snippet: 'Parque central'),
    ),
    const Marker(
      markerId: MarkerId('cerro'),
      position: LatLng(20.592582, -100.409395),
      infoWindow: InfoWindow(title: 'Cerro de las Campanas', snippet: 'Monumento histórico'),
    ),
  };

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mapa de Querétaro'),
        backgroundColor: colorVino,
        foregroundColor: Colors.white,
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            tooltip: 'Volver',
            onPressed: () {
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              } else {
                Navigator.pushReplacementNamed(
                  context,
                  '/users',
                  arguments: usuarioActual,
                );
              }
            },
          ),
        ],
      ),
      drawer: AdminDrawer(
        usuario: usuarioActual,
        rutaActual: '/mapa',
      ),
      body: GoogleMap(
        mapType: MapType.normal,
        initialCameraPosition: CameraPosition(
          target: _centroQro,
          zoom: 12.5,
        ),
        markers: _misMarcadores,
      ),
    );
  }
}
