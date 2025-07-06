// lib/models.dart
import 'package:flutter/foundation.dart';

class Producto {
  final int id;
  final String nombre;
  final String descripcion;
  final double precio;
  final String? imagenUrl;
  // Puedes añadir más campos como color, talla, etc.

  Producto({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.precio,
    this.imagenUrl,
  });

  // Factory para crear un Producto desde un mapa (como el que viene de la API)
  factory Producto.fromMap(Map<String, dynamic> map) {
    return Producto(
      id: map['id'], // Asegúrate que tu API devuelva un 'id' único
      nombre: map['nombre'],
      descripcion: map['descripcion'],
      precio: (map['precio'] as num).toDouble(),
      imagenUrl: map['imagen_url'],
    );
  }
}