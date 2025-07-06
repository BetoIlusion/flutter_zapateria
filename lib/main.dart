import 'package:flutter/material.dart';
import 'package:flutter_zapateria/export.dart';
import 'package:flutter_zapateria/screens/pago_screen.dart';
import 'package:flutter_zapateria/models/producto_carrito.dart';
import 'package:flutter_zapateria/screens/perfil_screen.dart';
import 'package:flutter_zapateria/screens/pagos_screen.dart';

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
        '/dashboard_distribuidor': (_) => const DashboardDistribuidor(),
        '/dashboard_admin': (_) => const DashboardScreen(),
        '/perfil': (_) => PerfilScreen(),
        '/pagos': (_) => PagosScreen(),
        
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/pago') {
          final List<ProductoCarrito> carrito = settings.arguments as List<ProductoCarrito>;
          return MaterialPageRoute(
            builder: (context) {
              return PagoScreen(carrito: carrito);
            },
          );
        }
        return null;
      },
    );
  }
}