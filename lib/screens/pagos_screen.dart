import 'package:flutter/material.dart';
import 'package:flutter_zapateria/models/producto_carrito.dart';

class PagosScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Historial de Pagos',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: [
                  // Ejemplo de historial de pagos (puedes conectar con ApiService)
                  ListTile(
                    title: Text('Compra #001'),
                    subtitle: Text('Fecha: 05/07/2025 - Bs. 150.00'),
                    trailing: Icon(Icons.check_circle, color: Colors.green),
                  ),
                  ListTile(
                    title: Text('Compra #002'),
                    subtitle: Text('Fecha: 04/07/2025 - Bs. 200.00'),
                    trailing: Icon(Icons.check_circle, color: Colors.green),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Lógica para ver más detalles o iniciar un nuevo pago
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Funcionalidad de pagos en desarrollo')),
                );
              },
              child: Text('Ver Más'),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 48),
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}