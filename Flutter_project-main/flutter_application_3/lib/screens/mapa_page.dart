import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapaPage extends StatefulWidget {
  const MapaPage({super.key});

  @override
  State<MapaPage> createState() => _MapaPageState();
}

class _MapaPageState extends State<MapaPage> {
  final LatLng _centroQro = const LatLng(20.588793, -100.389888);

  final Set<Marker> _misMarcadores = {
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mapa de Querétaro'),
      ),
      body: GoogleMap(
        mapType: MapType.normal,
        initialCameraPosition: CameraPosition(
          target: _centroQro,
          zoom: 13.0, 
        ),
        markers: _misMarcadores,
      ),
    );
  }
}