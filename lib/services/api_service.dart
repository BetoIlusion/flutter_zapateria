import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String _baseUrl = 'http://192.168.0.9:8000/api';

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

  // 🔜 Aquí puedes agregar otras funciones como fetchDistribuidores(), getUbicacion(), etc.

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
}
