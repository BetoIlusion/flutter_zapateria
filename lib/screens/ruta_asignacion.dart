import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
      final data = await ApiService.getRutaOptimaDistribuidorDetallada();

      final coords = List.from(data['geometry']);
      routePoints = coords.map((e) => LatLng(e[1], e[0])).toList();

      final orig = data['origen'];
      origen = LatLng(double.parse(orig['latitud']), double.parse(orig['longitud']));

      clientes = data['clientes_completos'];
      setState(() => loading = false);
    } catch (e) {
      setState(() {
        error = e.toString();
        loading = false;
      });
    }
  }

  void _mostrarDetallesCliente(Map<String, dynamic> cliente) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: contentBox(context, cliente),
      ),
    );
  }

  Widget contentBox(BuildContext context, Map<String, dynamic> cliente) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [BoxShadow(color: Colors.black26, offset: Offset(0, 10), blurRadius: 10)],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            cliente['cliente_nombre'] ?? 'Detalles del Cliente',
            style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 10),
          const Divider(thickness: 1),
          const SizedBox(height: 15),
          _buildInfoRow(Icons.receipt_long, 'ID Compra:', '${cliente['id_compra']}'),
          _buildInfoRow(Icons.inventory_2_outlined, 'Volumen:', '${cliente['volumen_total']}'),
          _buildInfoRow(Icons.directions, 'Distancia:', '${cliente['distancia_km']} km'),
          _buildInfoRow(Icons.timer_outlined, 'Tiempo Est.:', '${cliente['tiempo_min']} min'),
          const SizedBox(height: 25),
          Align(
            alignment: Alignment.bottomRight,
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              child: Text(
                "Cerrar",
                style: GoogleFonts.poppins(fontSize: 16, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.blueAccent, size: 20),
          const SizedBox(width: 10),
          Text(label, style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 15)),
          const SizedBox(width: 5),
          Expanded(
            child: Text(value, style: GoogleFonts.poppins(fontSize: 15), textAlign: TextAlign.right),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (error != null) {
      return Scaffold(body: Center(child: Text(error!)));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Ruta Óptima de Asignación')),
      body: FlutterMap(
        options: MapOptions(
          initialCenter: origen!,
          initialZoom: 13,
        ),
        children: [
          TileLayer(
            urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
            userAgentPackageName: 'com.flutter.zapateria',
          ),
          PolylineLayer(
            polylines: [Polyline(points: routePoints, color: Colors.blue, strokeWidth: 5)],
          ),
          MarkerLayer(
            markers: [
              Marker(
                point: origen!,
                width: 50,
                height: 50,
                child: const Icon(Icons.directions_car, color: Colors.green, size: 36),
              ),
              ...clientes.map((c) {
                return Marker(
                  point: LatLng(double.parse(c['latitud']), double.parse(c['longitud'])),
                  width: 45,
                  height: 45,
                  child: GestureDetector(
                    onTap: () => _mostrarDetallesCliente(c),
                    child: const Icon(Icons.location_on, color: Colors.red, size: 34),
                  ),
                );
              }).toList(),
            ],
          ),
        ],
      ),
    );
  }
}
