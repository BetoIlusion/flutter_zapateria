import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_zapateria/export.dart';

class UbicacionMapaScreen extends StatefulWidget {
  final String rol;

  const UbicacionMapaScreen({super.key, required this.rol});

  @override
  State<UbicacionMapaScreen> createState() => _UbicacionMapaScreenState();
}

class _UbicacionMapaScreenState extends State<UbicacionMapaScreen> {
  LatLng? _ubicacionSeleccionada;

  void _guardarUbicacion() async {
    if (_ubicacionSeleccionada == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona una ubicación primero')),
      );
      return;
    }

    try {
      await ApiService.guardarUbicacion(
        latitud: _ubicacionSeleccionada!.latitude,
        longitud: _ubicacionSeleccionada!.longitude,
      );

      // Redirige según rol
      if (widget.rol == 'cliente') {
        Navigator.pushReplacementNamed(context, '/dashboard_cliente');
      } else {
        Navigator.pushReplacementNamed(context, '/dashboard_distribuidor');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar ubicación: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Selecciona tu ubicación')),
      body: FlutterMap(
        options: MapOptions(
          initialCenter:
              LatLng(-17.783327, -63.182140), // Plaza 24 de Septiembre
          initialZoom: 14,
          onTap: (tapPosition, point) {
            setState(() {
              _ubicacionSeleccionada = point;
            });
          },
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.flutter.zapateria',
          ),
          if (_ubicacionSeleccionada != null)
            MarkerLayer(markers: [
              Marker(
                point: _ubicacionSeleccionada!,
                width: 40,
                height: 40,
                child:
                    const Icon(Icons.location_pin, color: Colors.red, size: 40),
              )
            ])
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _guardarUbicacion,
        label: const Text('Guardar ubicación'),
        icon: const Icon(Icons.save),
      ),
    );
  }
}
