class ProductoCarrito {
  final Map<String, dynamic> producto;
  int cantidad;

  ProductoCarrito({
    required this.producto,
    required this.cantidad,
  });

  double get subtotal {
    // Convertir precio a double, manejando posibles valores no válidos
    final precio = double.tryParse(producto['precio'].toString()) ?? 0.0;
    return precio * cantidad;
  }

  Map<String, dynamic> toJson() {
    return {
      'id_producto': producto['id'],
      'cantidad': cantidad,
    };
  }
}
