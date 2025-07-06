// import 'package:flutter/material.dart';
// import 'package:flutter_map/flutter_map.dart';
// import 'package:latlong2/latlong.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:osrm/osrm.dart';
// import 'package:polyline/polyline.dart' as pl;

// class MapaScreen extends StatefulWidget {
//   @override
//   _MapaScreenState createState() => _MapaScreenState();
// }

// class _MapaScreenState extends State<MapaScreen> {
//   Position? userLocation;
//   List<LatLng> distributors = [
//     LatLng(40.7130, -74.0062),
//     LatLng(40.7126, -74.0058),
//     LatLng(40.7129, -74.0060),
//   ]; // Lista de distribuidores para pruebas
//   int? closestIndex;
//   List<LatLng>? routePoints;
//   final MapController mapController = MapController();
//   bool isLoading = false;

//   @override
//   void initState() {
//     super.initState();
//     // Usamos una ubicación fija para pruebas (puedes reemplazar con Geolocator)
//     userLocation = Position(
//       latitude: 40.7128,
//       longitude: -74.0060,
//       timestamp: DateTime.now(),
//       accuracy: 0,
//       altitude: 0,
//       heading: 0,
//       speed: 0,
//       speedAccuracy: 0,
//     );
//     _findClosestDistributor();
//   }

//   Future<void> _getUserLocation() async {
//     // Descomenta esto para usar la ubicación real del usuario
//     /*
//     bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
//     if (!serviceEnabled) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Los servicios de ubicación están desactivados')),
//       );
//       return;
//     }

//     LocationPermission permission = await Geolocator.checkPermission();
//     if (permission == LocationPermission.denied) {
//       permission = await Geolocator.requestPermission();
//       if (permission == LocationPermission.denied) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Permiso de ubicación denegado')),
//         );
//         return;
//       }
//     }

//     Position position = await Geolocator.getCurrentPosition(
//       desiredAccuracy: LocationAccuracy.high,
//     );
//     setState(() {
//       userLocation = position;
//     });
//     */
//     await _findClosestDistributor();
//   }

//   Future<void> _findClosestDistributor() async {
//     if (userLocation == null || distributors.isEmpty) return;

//     setState(() {
//       isLoading = true;
//     });

//     double minDistance = double.infinity;
//     int minIndex = -1;
//     List<LatLng>? minRoutePoints;

//     final osrm = Osrm();
//     for (int i = 0; i < distributors.length; i++) {
//       final route = await _getRoute(userLocation!, distributors[i]);
//       if (route != null && route.distance < minDistance) {
//         minDistance = route.distance;
//         minIndex = i;
//         minRoutePoints = _decodePolyline(route.geometry);
//       }
//     }

//     setState(() {
//       closestIndex = minIndex;
//       routePoints = minRoutePoints;
//       isLoading = false;
//     });

//     // Centrar el mapa en la ubicación del usuario
//     if (userLocation != null) {
//       mapController.move(
//         LatLng(userLocation!.latitude, userLocation!.longitude),
//         14.0,
//       );
//     }
//   }

//   Future<Route?> _getRoute(Position start, LatLng end) async {
//     try {
//       final response = await Osrm().route(
//         RouteRequest(
//           coordinates: [
//             (start.longitude, start.latitude),
//             (end.longitude, end.latitude),
//           ],
//           overview: OsrmOverview.full,
//         ),
//       );
//       return response.routes.isNotEmpty ? response.routes.first : null;
//     } catch (e) {
//       print('Error al obtener ruta: $e');
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error al calcular la ruta')),
//       );
//       return null;
//     }
//   }

//   List<LatLng> _decodePolyline(String encoded) {
//     final decoded = pl.Polyline.Decode(encoded: encoded);
//     return decoded.decodedCoords
//         .map((coord) => LatLng(coord[0], coord[1]))
//         .toList();
//   }

//   void _removeDistributor(int index) {
//     setState(() {
//       distributors.removeAt(index);
//       closestIndex = null;
//       routePoints = null;
//     });
//     _findClosestDistributor();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Mapa de Distribuidores'),
//         backgroundColor: Colors.blue.shade700,
//       ),
//       body: userLocation == null
//           ? Center(child: CircularProgressIndicator())
//           : Column(
//               children: [
//                 Expanded(
//                   flex: 3,
//                   child: Stack(
//                     children: [
//                       FlutterMap(
//                         mapController: mapController,
//                         options: MapOptions(
//                           center: LatLng(userLocation!.latitude, userLocation!.longitude),
//                           zoom: 14.0,
//                         ),
//                         children: [
//                           TileLayer(
//                             urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
//                             subdomains: ['a', 'b', 'c'],
//                           ),
//                           MarkerLayer(
//                             markers: [
//                               Marker(
//                                 point: LatLng(userLocation!.latitude, userLocation!.longitude),
//                                 builder: (ctx) => Icon(
//                                   Icons.location_on,
//                                   color: Colors.red,
//                                   size: 40,
//                                 ),
//                               ),
//                               ...distributors.asMap().entries.map((entry) {
//                                 int index = entry.key;
//                                 LatLng point = entry.value;
//                                 return Marker(
//                                   point: point,
//                                   builder: (ctx) => Icon(
//                                     index == closestIndex ? Icons.location_on : Icons.location_pin,
//                                     color: index == closestIndex ? Colors.green : Colors.blue,
//                                     size: 30,
//                                   ),
//                                 );
//                               }),
//                             ],
//                           ),
//                           if (routePoints != null)
//                             PolylineLayer(
//                               polylines: [
//                                 Polyline(
//                                   points: routePoints!,
//                                   strokeWidth: 4,
//                                   color: Colors.blue,
//                                 ),
//                               ],
//                             ),
//                         ],
//                       ),
//                       if (isLoading)
//                         Center(child: CircularProgressIndicator()),
//                     ],
//                   ),
//                 ),
//                 Expanded(
//                   flex: 1,
//                   child: distributors.isEmpty
//                       ? Center(child: Text('No hay distribuidores disponibles'))
//                       : ListView.builder(
//                           itemCount: distributors.length,
//                           itemBuilder: (context, index) {
//                             return ListTile(
//                               title: Text('Distribuidor $index (${distributors[index].latitude}, ${distributors[index].longitude})'),
//                               subtitle: closestIndex == index
//                                   ? Text('Más cercano', style: TextStyle(color: Colors.green))
//                                   : null,
//                               trailing: IconButton(
//                                 icon: Icon(Icons.delete, color: Colors.red),
//                                 onPressed: () => _removeDistributor(index),
//                               ),
//                             );
//                           },
//                         ),
//                 ),
//               ],
//             ),
//     );
//   }
// }