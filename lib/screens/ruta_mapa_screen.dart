import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:flutter_zapateria/export.dart';
import 'package:google_fonts/google_fonts.dart';

class RutaMapaScreen extends StatefulWidget {
  final int idCompra;
  final int idDistribuidor;
  final int idAsignacion;

  const RutaMapaScreen({
    super.key,
    required this.idCompra,
    required this.idDistribuidor,
    required this.idAsignacion,
  });

  @override
  State<RutaMapaScreen> createState() => _RutaMapaScreenState();
}

class _RutaMapaScreenState extends State<RutaMapaScreen> {
  bool _cargando = true;
  String? _error;
  LatLng? _puntoInicio;
  LatLng? _puntoFin;
  List<LatLng> _puntosRuta = [];

  @override
  void initState() {
    super.initState();
    _cargarDatosRuta();
  }

  Future<void> _cargarDatosRuta() async {
    try {
      final ubicaciones = await ApiService.getUbicacionesRuta(
        idCompra: widget.idCompra,
        idDistribuidor: widget.idDistribuidor,
      );

      final distribuidor = ubicaciones['distribuidor'];
      final cliente = ubicaciones['cliente'];

      if (distribuidor['latitud'] == null || distribuidor['longitud'] == null) {
        throw Exception('Ubicación del distribuidor no disponible');
      }
      if (cliente['latitud'] == null || cliente['longitud'] == null) {
        throw Exception('Ubicación del cliente no disponible');
      }

      _puntoInicio = LatLng(
        double.parse(distribuidor['latitud'].toString()),
        double.parse(distribuidor['longitud'].toString()),
      );
      _puntoFin = LatLng(
        double.parse(cliente['latitud'].toString()),
        double.parse(cliente['longitud'].toString()),
      );

      final ruta = await _obtenerGeometriaRutaOSRM(_puntoInicio!, _puntoFin!);
      setState(() {
        _puntosRuta = ruta;
        _cargando = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Error al cargar la ruta: $e';
        _cargando = false;
      });
    }
  }

  Future<List<LatLng>> _obtenerGeometriaRutaOSRM(LatLng inicio, LatLng fin) async {
    final url = 'https://router.project-osrm.org/route/v1/driving/'
        '${inicio.longitude},${inicio.latitude};${fin.longitude},${fin.latitude}'
        '?overview=full&geometries=geojson';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> coords = data['routes'][0]['geometry']['coordinates'];
      return coords.map((c) => LatLng(c[1], c[0])).toList();
    } else {
      throw Exception('No se pudo obtener la ruta de OSRM');
    }
  }

  Future<void> _cambiarEstado(String estado) async {
    try {
      final response = await ApiService.cambiarEstadoAsignacion(
        idAsignacion: widget.idAsignacion,
        estado: estado,
      );

      if (response['success']) {
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Text(
              'Éxito',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.green.shade700,
              ),
            ),
            content: Text(
              'Asignación #${response['data']['id']} marcada como "$estado".',
              style: GoogleFonts.poppins(fontSize: 16),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Cierra el diálogo
                  Navigator.pushReplacementNamed(context, '/dashboard_distribuidor');
                },
                child: Text(
                  'Aceptar',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: Colors.blue.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message'] ?? 'Error al actualizar el estado'),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red.shade700,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ruta de Entrega'),
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!, textAlign: TextAlign.center))
              : Column(
                  children: [
                    Expanded(
                      child: FlutterMap(
                        options: MapOptions(
                          initialCenter: _puntoInicio ?? LatLng(-17.78, -63.18),
                          initialZoom: 15.0,
                        ),
                        children: [
                          TileLayer(
                            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                            userAgentPackageName: 'com.flutter.zapateria',
                          ),
                          PolylineLayer(
                            polylines: [
                              Polyline(
                                points: _puntosRuta,
                                color: Colors.blue,
                                strokeWidth: 5,
                              ),
                            ],
                          ),
                          MarkerLayer(
                            markers: [
                              if (_puntoInicio != null)
                                Marker(
                                  point: _puntoInicio!,
                                  width: 80,
                                  height: 80,
                                  child: const Column(
                                    children: [
                                      Icon(Icons.store, color: Colors.green, size: 40),
                                      Text('Inicio',
                                          style: TextStyle(
                                              color: Colors.black, fontWeight: FontWeight.bold))
                                    ],
                                  ),
                                ),
                              if (_puntoFin != null)
                                Marker(
                                  point: _puntoFin!,
                                  width: 80,
                                  height: 80,
                                  child: const Column(
                                    children: [
                                      Icon(Icons.person_pin_circle, color: Colors.red, size: 40),
                                      Text('Cliente',
                                          style: TextStyle(
                                              color: Colors.black, fontWeight: FontWeight.bold))
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            onPressed: () => _cambiarEstado('entregado'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: Text(
                              'Entregado',
                              style: GoogleFonts.poppins(fontSize: 14, color: Colors.white),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () => _cambiarEstado('no entregado'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: Text(
                              'No Entregado',
                              style: GoogleFonts.poppins(fontSize: 14, color: Colors.white),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () => _cambiarEstado('producto incorrecto'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: Text(
                              'P. Incorrecto',
                              style: GoogleFonts.poppins(fontSize: 14, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
    );
  }
}