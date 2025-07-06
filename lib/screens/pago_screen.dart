import 'package:flutter/material.dart';
import 'package:flutter_zapateria/models/producto_carrito.dart';

class PagoScreen extends StatelessWidget {
  final List<ProductoCarrito> carrito;

  const PagoScreen({Key? key, required this.carrito}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double total = carrito.fold(0, (sum, item) => sum + item.subtotal);

    return Scaffold(
      appBar: AppBar(
        title: Text('Confirmar Compra'),
        backgroundColor: Colors.blue.shade700,
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(12),
        itemCount: carrito.length,
        itemBuilder: (context, index) {
          final item = carrito[index];
          return Card(
            margin: EdgeInsets.only(bottom: 10),
            child: ListTile(
              leading: Image.network(
                item.producto['imagen_url']?.isNotEmpty == true
                    ? item.producto['imagen_url']
                    : 'https://source.unsplash.com/featured/?shoes,sneakers,footwear',
                width: 50,
                height: 50,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Image.network(
                    'https://images.unsplash.com/photo-1517263904808-5dc0d6d3fa5c?auto=format&fit=crop&w=400&q=80',
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  );
                },
              ),
              title: Text(item.producto['nombre'] ?? 'Sin nombre'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('ID: ${item.producto['id'] ?? 'N/A'}'),
                  Text('Precio Unitario: Bs. ${double.tryParse(item.producto['precio']?.toString() ?? '0.0')?.toStringAsFixed(2) ?? '0.00'}'),
                  Text('Cantidad: ${item.cantidad}'),
                ],
              ),
              trailing: Text('Bs. ${item.subtotal.toStringAsFixed(2)}'),
            ),
          );
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total a Pagar:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                Text('Bs. ${total.toStringAsFixed(2)}', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green)),
              ],
            ),
            SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('¡Gracias por tu compra!')),
                );
              },
              child: Text('Finalizar Pedido'),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
                backgroundColor: Colors.green,
                textStyle: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}