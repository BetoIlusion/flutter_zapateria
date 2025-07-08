import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart'; // Paquete moderno para coordenadas (LatLng)
import 'package:flutter_zapateria/export.dart';

class RutaMapaScreen extends StatefulWidget {
  final int idCompra;
  final int idDistribuidor;

  const RutaMapaScreen({
    super.key,
    required this.idCompra,
    required this.idDistribuidor,
  });

  @override
  State<RutaMapaScreen> createState() => _RutaMapaScreenState();
}

class _RutaMapaScreenState extends State<RutaMapaScreen> {
  bool _cargando = true;
  String? _error;

  LatLng? _puntoInicio; // Ubicación del distribuidor
  LatLng? _puntoFin; // Ubicación del cliente
  List<LatLng> _puntosRuta = []; // Lista de coordenadas para dibujar la línea

  @override
  void initState() {
    super.initState();
    _cargarDatosRuta();
  }

  Future<void> _cargarDatosRuta() async {
    try {
      // 1. Obtener ubicaciones desde tu backend
      final ubicaciones = await ApiService.getUbicacionesRuta(
        idCompra: widget.idCompra,
        idDistribuidor: widget.idDistribuidor,
      );

      // Extraer y parsear las coordenadas (vienen como String)
      final distribuidor = ubicaciones['distribuidor'];
      final cliente = ubicaciones['cliente'];

      _puntoInicio = LatLng(
        double.parse(distribuidor['latitud']),
        double.parse(distribuidor['longitud']),
      );
      _puntoFin = LatLng(
        double.parse(cliente['latitud']),
        double.parse(cliente['longitud']),
      );

      // 2. Obtener la geometría de la ruta desde OSRM (API gratuita)
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

  /// Llama a la API de OSRM para obtener la ruta entre dos puntos.
  Future<List<LatLng>> _obtenerGeometriaRutaOSRM(
      LatLng inicio, LatLng fin) async {
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
                    // --- MAPA ---
                    Expanded(
                      child: FlutterMap(
                        options: MapOptions(
                          initialCenter: _puntoInicio ??
                              LatLng(-17.78, -63.18), // Centro inicial
                          initialZoom: 15.0,
                        ),
                        children: [
                          // Capa de mapa base de OpenStreetMap
                          TileLayer(
                            urlTemplate:
                                'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                            userAgentPackageName:
                                'com.tu.app', // Cambia por tu package name
                          ),
                          // Capa para dibujar la ruta
                          PolylineLayer(
                            polylines: [
                              Polyline(
                                points: _puntosRuta,
                                color: Colors.blue,
                                strokeWidth: 5,
                              ),
                            ],
                          ),
                          // Capa para los marcadores
                          MarkerLayer(
                            markers: [
                              // Marcador del Distribuidor (Inicio)
                              if (_puntoInicio != null)
                                Marker(
                                  point: _puntoInicio!,
                                  width: 80,
                                  height: 80,
                                  child: const Column(
                                    children: [
                                      Icon(Icons.store,
                                          color: Colors.green, size: 40),
                                      Text('Inicio',
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold))
                                    ],
                                  ),
                                ),
                              // Marcador del Cliente (Fin)
                              if (_puntoFin != null)
                                Marker(
                                  point: _puntoFin!,
                                  width: 80,
                                  height: 80,
                                  child: const Column(
                                    children: [
                                      Icon(Icons.person_pin_circle,
                                          color: Colors.red, size: 40),
                                      Text('Cliente',
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold))
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // --- BOTONES DE ACCIÓN ---
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 12.0, horizontal: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              /* TODO: Lógica para marcar como entregado */
                            },
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green),
                            child: const Text('Entregado'),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              /* TODO: Lógica para no entregado */
                            },
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange),
                            child: const Text('No Entregado'),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              /* TODO: Lógica para producto incorrecto */
                            },
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red),
                            child: const Text('P. Incorrecto'),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
    );
  }
}
