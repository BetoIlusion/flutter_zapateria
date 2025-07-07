import 'package:flutter/material.dart';
import 'package:flutter_zapateria/models/producto_carrito.dart';
import 'package:flutter_zapateria/export.dart';

class PagoScreen extends StatelessWidget {
  final List<ProductoCarrito> carrito;

  const PagoScreen({Key? key, required this.carrito}) : super(key: key);

  void finalizarPedido(BuildContext context) async {
    try {
      final idCompra = await ApiService.crearCompra();

      for (var item in carrito) {
        await ApiService.agregarDetalleCompra(
          idCompra: idCompra,
          idProducto: item.producto['id'],
          cantidad: item.cantidad,
          subtotal: item.subtotal, // ✅ agregado
        );
      }

      // Simular método de pago 1 hasta que lo implementes
      await ApiService.calcularTotalCompra(
        idCompra: idCompra,
        idMetodoPago:
            1, // ⚠️ Aquí debes colocar el método de pago seleccionado por el usuario
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Pedido realizado con éxito')),
      );
      Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al realizar el pedido: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    double total = carrito.fold(0, (sum, item) => sum + item.subtotal);

    return Scaffold(
      appBar: AppBar(title: Text("Resumen de Pedido")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: carrito.length,
                itemBuilder: (context, index) {
                  final item = carrito[index];
                  return ListTile(
                    title: Text(item.producto['nombre']),
                    subtitle: Text('Cantidad: ${item.cantidad}'),
                    trailing: Text('Bs. ${item.subtotal.toStringAsFixed(2)}'),
                  );
                },
              ),
            ),
            Divider(),
            ListTile(
              title:
                  Text('Total', style: TextStyle(fontWeight: FontWeight.bold)),
              trailing: Text('Bs. ${total.toStringAsFixed(2)}'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => finalizarPedido(context),
              child: Text('Finalizar Pedido'),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 48),
              ),
            )
          ],
        ),
      ),
    );
  }
}
