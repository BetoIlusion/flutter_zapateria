import 'package:flutter/material.dart';
import 'package:flutter_zapateria/models/producto_carrito.dart';
import 'package:flutter_zapateria/export.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_flutter/qr_flutter.dart';

class PagoScreen extends StatefulWidget {
  final List<ProductoCarrito> carrito;

  const PagoScreen({Key? key, required this.carrito}) : super(key: key);

  @override
  State<PagoScreen> createState() => _PagoScreenState();
}

class _PagoScreenState extends State<PagoScreen> {
  // Opciones de métodos de pago
  final List<Map<String, dynamic>> _metodosPago = [
    {'id': 1, 'nombre': 'Efectivo'},
    {'id': 2, 'nombre': 'Cuenta Bancaria'},
    {'id': 3, 'nombre': 'QR'},
  ];

  // Método de pago seleccionado
  int _idMetodoPago = 1; // Valor inicial: Efectivo

  Future<void> finalizarPedido(BuildContext context) async {
    try {
      final idCompra = await ApiService.crearCompra();

      for (var item in widget.carrito) {
        await ApiService.agregarDetalleCompra(
          idCompra: idCompra,
          idProducto: item.producto['id'],
          cantidad: item.cantidad,
          subtotal: item.subtotal,
        );
      }

      await ApiService.calcularTotalCompra(
        idCompra: idCompra,
        idMetodoPago: _idMetodoPago,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Pedido realizado con éxito',
            style: GoogleFonts.poppins(fontSize: 14, color: Colors.white),
          ),
          backgroundColor: Colors.green.shade700,
          duration: Duration(seconds: 2),
        ),
      );

      Navigator.pushReplacementNamed(context, '/dashboard_cliente');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error al realizar el pedido: $e',
            style: GoogleFonts.poppins(fontSize: 14, color: Colors.white),
          ),
          backgroundColor: Colors.red.shade700,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    double total = widget.carrito.fold(0, (sum, item) => sum + item.subtotal);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Resumen de Pedido',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: widget.carrito.length,
                itemBuilder: (context, index) {
                  final item = widget.carrito[index];
                  return ListTile(
                    title: Text(
                      item.producto['nombre'],
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                    ),
                    subtitle: Text(
                      'Cantidad: ${item.cantidad}',
                      style: GoogleFonts.poppins(fontSize: 14),
                    ),
                    trailing: Text(
                      'Bs. ${item.subtotal.toStringAsFixed(2)}',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                    ),
                  );
                },
              ),
            ),
            Divider(),
            ListTile(
              title: Text(
                'Total',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              trailing: Text(
                'Bs. ${total.toStringAsFixed(2)}',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            SizedBox(height: 16),
            // Selector de método de pago
            ListTile(
              title: Text(
                'Método de Pago',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              trailing: DropdownButton<int>(
                value: _idMetodoPago,
                onChanged: (int? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _idMetodoPago = newValue;
                    });
                  }
                },
                items: _metodosPago.map((metodo) {
                  return DropdownMenuItem<int>(
                    value: metodo['id'],
                    child: Text(
                      metodo['nombre'],
                      style: GoogleFonts.poppins(fontSize: 14),
                    ),
                  );
                }).toList(),
                underline: Container(), // Quitar la línea inferior
                icon: Icon(Icons.arrow_drop_down, color: Colors.blue.shade700),
              ),
            ),
            // Mostrar código QR si se selecciona QR
            if (_idMetodoPago == 3)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Column(
                  children: [
                    Text(
                      'Escanea este código QR',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 8),
                    QrImageView(
                      data: 'Compra_${DateTime.now().millisecondsSinceEpoch}', // Datos ficticios
                      version: QrVersions.auto,
                      size: 200.0,
                      gapless: false,
                      backgroundColor: Colors.white,
                      padding: EdgeInsets.all(8.0),
                    ),
                  ],
                ),
              ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => finalizarPedido(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade700,
                minimumSize: Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Finalizar Pedido',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}