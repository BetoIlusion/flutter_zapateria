import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_zapateria/export.dart';

class RutasAsignacionScreen extends StatefulWidget {
  const RutasAsignacionScreen({super.key});

  @override
  State<RutasAsignacionScreen> createState() => _RutasAsignacionScreenState();
}

class _RutasAsignacionScreenState extends State<RutasAsignacionScreen> {
  bool loading = true;
  String? error;
  List<LatLng> routePoints = [];
  List<dynamic> clientes = [];
  LatLng? origen;

  @override
  void initState() {
    super.initState();
    cargarRuta();
  }

  Future<void> cargarRuta() async {
    try {
      final data = await ApiService.getRutaOptimaDistribuidor();
      final coords = List.from(data['geometry']);
      routePoints = coords.map((e) => LatLng(e[1], e[0])).toList();

      final orig = data['origen'];
      origen =
          LatLng(double.parse(orig['latitud']), double.parse(orig['longitud']));

      clientes = data['clientes_completos'];
      setState(() => loading = false);
    } catch (e) {
      setState(() {
        error = e.toString();
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (error != null) {
      return Scaffold(
        body: Center(child: Text(error!)),
      );
    }

    // ✨ INICIO DE LA CORRECCIÓN ✨
    // Envolvemos todo en un Scaffold y ponemos FlutterMap en el body.
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ruta Óptima de Asignación'),
      ),
      body: FlutterMap(
        options: MapOptions(
          initialCenter: origen!,
          initialZoom: 13,
        ),
        children: [
          TileLayer(
            // Es buena práctica añadir el userAgentPackageName
            urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
            userAgentPackageName: 'com.flutter.zapateria', // O el nombre de tu paquete
          ),
          PolylineLayer(polylines: [
            Polyline(points: routePoints, color: Colors.blue, strokeWidth: 4),
          ]),
          MarkerLayer(markers: [
            Marker(
                point: origen!,
                width: 50,
                height: 50,
                child: const Icon(Icons.store, color: Colors.green, size: 35)),
            ...clientes.map((c) {
              return Marker(
                point: LatLng(
                    double.parse(c['latitud']), double.parse(c['longitud'])),
                width: 45,
                height: 45,
                child: const Icon(Icons.person_pin, color: Colors.red, size: 30),
              );
            })
          ])
        ],
      ),
    );
    // ✨ FIN DE LA CORRECCIÓN ✨
  }
}