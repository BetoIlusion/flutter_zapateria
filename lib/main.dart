import 'package:flutter/material.dart';
import 'package:flutter_zapateria/export.dart';
import 'package:flutter_zapateria/screens/pago_screen.dart';
import 'package:flutter_zapateria/models/producto_carrito.dart';
import 'package:flutter_zapateria/screens/perfil_screen.dart';
import 'package:flutter_zapateria/screens/pagos_screen.dart';
import 'package:flutter_zapateria/screens/ruta_mapa_screen.dart'; // ✅ AJUSTA según tu estructura

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AuthScreen(),
      routes: {
        '/dashboard_cliente': (_) => DashboardCliente(),
        '/dashboard_distribuidor': (_) => DashboardDistribuidor(),
        '/dashboard_admin': (_) => const DashboardScreen(),
        '/perfil': (_) => PerfilScreen(),
        '/pagos': (_) => PagosScreen(),
        '/vehiculo': (_) => VehiculoScreen(), // Nueva ruta
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/pago') {
          final carrito = settings.arguments as List<ProductoCarrito>;
          return MaterialPageRoute(
            builder: (context) => PagoScreen(carrito: carrito),
          );
        }
        if (settings.name == '/ubicacion_mapa') {
          final rol = settings.arguments as String;
          return MaterialPageRoute(
            builder: (context) => UbicacionMapaScreen(rol: rol),
          );
        }

        if (settings.name == '/seguir_ruta') {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (context) => RutaMapaScreen(
              idCompra: args['id_compra'],
              idDistribuidor: args['id_distribuidor'],
              idAsignacion: args['id_asignacion'] ??
                  0, // Fallback a 0 si no está presente
            ),
          );
        }

        // Ruta no implementada
        assert(false, 'Ruta no implementada: ${settings.name}');
        return null;
      },
    );
  }
}
