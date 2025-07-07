import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String _baseUrl = 'http://192.168.0.9:8000/api';

  // ------------------ AUTENTICACIÓN ------------------

  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final url = Uri.parse('$_baseUrl/user/');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', data['token']);
        await prefs.setString('auth_rol', data['user']['rol']);

        return {
          'success': true,
          'token': data['token'],
          'rol': data['user']['rol'],
          'user': data['user'],
        };
      } else if (response.statusCode == 422) {
        return {
          'success': false,
          'errors': json.decode(response.body)['errors'],
        };
      } else {
        return {
          'success': false,
          'message': 'Error desconocido: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Excepción al conectar: $e',
      };
    }
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('auth_rol');
  }

  // ------------------ PRODUCTOS ------------------

  static Future<List<dynamic>> getProductos() async {
    final url = Uri.parse('$_baseUrl/producto');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final body = json.decode(response.body);
      return body['data'];
    } else {
      throw Exception('Error al cargar productos');
    }
  }
// ------------------ COMPRA Y DETALLE ------------------

  /// Crea una nueva compra y devuelve el ID
  static Future<int> crearCompra() async {
    final url = Uri.parse('$_baseUrl/compra');
    final token = await getToken();

    final response = await http.patch(
      url,
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 201) {
      final data = json.decode(response.body);
      return data['compra']['id']; // ⚠️ ← ajustado
    } else {
      throw Exception('No se pudo crear la compra');
    }
  }

  /// Inserta detalle_compra con cantidad y subtotal
  static Future<void> agregarDetalleCompra({
    required int idCompra,
    required int idProducto,
    required int cantidad,
    required double subtotal,
  }) async {
    final url = Uri.parse('$_baseUrl/compra/detalle');
    final token = await getToken();

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: json.encode({
        'id_compra': idCompra,
        'id_producto': idProducto,
        'cantidad': cantidad,
        'subtotal': subtotal, // ✅ requerido por backend
      }),
    );

    if (response.statusCode != 201) {
      throw Exception('Error al agregar detalle del producto $idProducto');
    }
  }

  /// PUT /compra/{id}/total → requiere `id_metodo_pago`
  static Future<void> calcularTotalCompra({
    required int idCompra,
    required int idMetodoPago,
  }) async {
    final url = Uri.parse('$_baseUrl/compra/$idCompra/total');
    final token = await getToken();

    final response = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: json.encode({
        'id_metodo_pago': idMetodoPago, // ✅ obligatorio según backend
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Error al calcular el total de la compra');
    }
  }
}
