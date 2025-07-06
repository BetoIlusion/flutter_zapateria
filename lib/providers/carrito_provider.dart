// lib/carrito_provider.dart
import 'package:flutter/foundation.dart';
import 'package:flutter_zapateria/models/carrito_item.dart';
import 'package:flutter_zapateria/models/producto.dart'; // Asegúrate de importar tu modelo

class CarritoProvider with ChangeNotifier {
  final Map<int, CarritoItem> _items = {};

  Map<int, CarritoItem> get items => {..._items};

  int get numeroDeItems => _items.length;

  double get totalCompra {
    var total = 0.0;
    _items.forEach((key, carritoItem) {
      total += carritoItem.producto.precio * carritoItem.cantidad;
    });
    return total;
  }

  void agregarProducto(Producto producto) {
    if (_items.containsKey(producto.id)) {
      // solo aumenta la cantidad
      _items.update(
        producto.id,
        (itemExistente) => CarritoItem(
          producto: itemExistente.producto,
          cantidad: itemExistente.cantidad + 1,
        ),
      );
    } else {
      // agrega un nuevo producto al carrito
      _items.putIfAbsent(
        producto.id,
        () => CarritoItem(producto: producto),
      );
    }
    notifyListeners(); // Notifica a los widgets que escuchan para que se redibujen
  }
  
  void removerUnidad(int productoId) {
    if (!_items.containsKey(productoId)) return;

    if (_items[productoId]!.cantidad > 1) {
       _items.update(
        productoId,
        (itemExistente) => CarritoItem(
          producto: itemExistente.producto,
          cantidad: itemExistente.cantidad - 1,
        ),
      );
    } else {
      // si solo queda uno, lo elimina
      _items.remove(productoId);
    }
     notifyListeners();
  }

  void eliminarProducto(int productoId) {
    _items.remove(productoId);
    notifyListeners();
  }

  void limpiarCarrito() {
    _items.clear();
    notifyListeners();
  }
}