import 'package:flutter_zapateria/models/producto.dart';

class CarritoItem {
  final Producto producto;
  int cantidad;

  CarritoItem({required this.producto, this.cantidad = 1});
}