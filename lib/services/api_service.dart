import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String _baseUrl = 'http://192.168.0.12:8000/api';

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

  static Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String rol,
  }) async {
    final url = Uri.parse('$_baseUrl/user/register');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
          'password_confirmation': password,
          'rol': rol,
        }),
      );

      // Añade este print para ver qué trae la respuesta
      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');
      Map<String, dynamic> data = {};
      try {
        data = json.decode(response.body);
      } catch (_) {
        return {
          'success': false,
          'message': 'Respuesta no válida del servidor',
        };
      }

      if (response.statusCode == 201) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', data['access_token']);
        await prefs.setString('auth_rol', data['user']['rol']);

        return {
          'success': true,
          'message': data['message'],
          'token': data['access_token'],
          'rol': data['user']['rol'],
          'user': data['user'],
        };
      } else if (response.statusCode == 422) {
        return {
          'success': false,
          'errors': data['errors'],
        };
      } else {
        return {
          'success': false,
          'message':
              data['message'] ?? 'Error desconocido: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Excepción al conectar: $e',
      };
    }
  }

  static Future<Map<String, dynamic>> getUser() async {
    final url = Uri.parse('$_baseUrl/user');
    final token = await getToken();

    if (token == null) {
      return {
        'success': false,
        'message': 'No autorizado: Token no encontrado',
      };
    }

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      print('Código de estado (getUser): ${response.statusCode}');
      print('Cuerpo de la respuesta (getUser): ${response.body}');

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': data,
        };
      } else if (response.statusCode == 403) {
        return {
          'success': false,
          'message': data['message'] ?? 'No autorizado',
        };
      } else {
        return {
          'success': false,
          'message':
              data['message'] ?? 'Error desconocido: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Excepción al conectar: $e',
      };
    }
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

  static Future<List<dynamic>> getComprasPorEstado(int filtro) async {
    final token = await getToken();
    final url = Uri.parse('$_baseUrl/compra/$filtro'); // ✅ corregido

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['data'];
    } else if (response.statusCode == 404) {
      return []; // Vacío si no hay resultados
    } else {
      throw Exception('Error al obtener compras: ${response.statusCode}');
    }
  }

  // ------------------ ASIGNACIONES ------------------
  static Future<List<dynamic>> getAsignaciones() async {
    final url = Uri.parse('$_baseUrl/asignacion');
    final token = await getToken();

    if (token == null) {
      throw Exception('No autorizado: Token no encontrado');
    }

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('Código de estado (getAsignaciones): ${response.statusCode}');
      print('Cuerpo de la respuesta (getAsignaciones): ${response.body}');

      final data = json.decode(response.body);

      if (response.statusCode == 200 && data['status'] == 'success') {
        return data['data'];
      } else if (response.statusCode == 403) {
        throw Exception(data['message'] ?? 'No autorizado');
      } else if (response.statusCode == 404) {
        throw Exception(data['message'] ?? 'Distribuidor no encontrado');
      } else {
        throw Exception(
            data['message'] ?? 'Error desconocido: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Excepción al conectar: $e');
    }
  }

  static Future<Map<String, dynamic>> cambiarEstadoAsignacion({
    required int idAsignacion,
    required String estado,
  }) async {
    final url = Uri.parse('$_baseUrl/asignacion/$idAsignacion/estado/$estado');
    final token = await getToken();

    if (token == null) {
      return {
        'success': false,
        'message': 'No autorizado: Token no encontrado',
      };
    }

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print(
          'Código de estado (cambiarEstadoAsignacion): ${response.statusCode}');
      print(
          'Cuerpo de la respuesta (cambiarEstadoAsignacion): ${response.body}');

      final data = json.decode(response.body);

      if (response.statusCode == 200 && data['status'] == 'success') {
        return {
          'success': true,
          'message': data['message'] ?? 'Estado actualizado exitosamente',
          'data': data['data'],
        };
      } else if (response.statusCode == 403) {
        return {
          'success': false,
          'message': data['message'] ?? 'No autorizado',
        };
      } else if (response.statusCode == 404) {
        return {
          'success': false,
          'message': data['message'] ?? 'Asignación no encontrada',
        };
      } else if (response.statusCode == 422) {
        return {
          'success': false,
          'message': data['message'] ?? 'Estado inválido',
        };
      } else {
        return {
          'success': false,
          'message':
              data['message'] ?? 'Error desconocido: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Excepción al conectar: $e',
      };
    }
  }

  // ------------------ UBICACIONES Y RUTAS ------------------

  /// Obtiene las ubicaciones del cliente y distribuidor para una compra específica.
  static Future<Map<String, dynamic>> getUbicacionesRuta({
    required int idCompra,
    required int idDistribuidor,
  }) async {
    final url = Uri.parse('$_baseUrl/ubicacion/ruta');
    final token = await getToken();

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: json.encode({
        'id_compra': idCompra,
        'id_distribuidor': idDistribuidor,
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['status'] == 'success') {
        return data['data']; // Retorna el objeto con 'cliente' y 'distribuidor'
      } else {
        throw Exception(
            'El API retornó un estado no exitoso: ${data['status']}');
      }
    } else {
      throw Exception('Error al obtener la ruta: ${response.statusCode}');
    }
  }

  static Future<Map<String, dynamic>> guardarUbicacion({
    required double latitud,
    required double longitud,
  }) async {
    final url = Uri.parse('$_baseUrl/ubicacion');
    final token = await getToken();

    if (token == null) {
      return {
        'success': false,
        'message': 'No autorizado: Token no encontrado',
      };
    }

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'latitud': latitud,
          'longitud': longitud,
        }),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': data['message'],
          'ubicacion': data['ubicacion'],
        };
      } else if (response.statusCode == 400) {
        return {
          'success': false,
          'errors': data,
        };
      } else if (response.statusCode == 403) {
        return {
          'success': false,
          'message': data['message'] ?? 'No autorizado',
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

  static Future<Map<String, dynamic>> getRutaOptimaDistribuidor() async {
    final uri = Uri.parse('$_baseUrl/distribuidor-ruta-optima');
    final token = await getToken(); // tu token sanctum
    final resp = await http.get(uri, headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
      'Accept': 'application/json'
    });
    final body = jsonDecode(resp.body);
    if (resp.statusCode == 200 && body['status'] == 'success') {
      return body['data'];
    }
    throw Exception('Error al obtener ruta óptima: ${body['message']}');
  }

  // ------------------ DISTRIBUIDOR ESTADO ------------------

  static Future<Map<String, dynamic>> getDistribuidorEstado() async {
    final token = await getToken();
    final url = Uri.parse('$_baseUrl/distribuidor/estado');

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Error al obtener el estado del distribuidor');
    }
  }

  static Future<Map<String, dynamic>> toggleDistribuidorEstado() async {
    final token = await getToken();
    final url = Uri.parse('$_baseUrl/distribuidor/estado');

    final response = await http.patch(
      url,
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Error al cambiar el estado del distribuidor');
    }
  }

  // ---------- VEHICULO -------------
  static Future<Map<String, dynamic>> getVehiculo() async {
    final url = Uri.parse('$_baseUrl/vehiculo');
    final token = await getToken();

    if (token == null) {
      return {
        'success': false,
        'message': 'No autorizado: Token no encontrado',
      };
    }

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      print('Código de estado (getVehiculo): ${response.statusCode}');
      print('Cuerpo de la respuesta (getVehiculo): ${response.body}');

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': data['data'],
        };
      } else if (response.statusCode == 403) {
        return {
          'success': false,
          'message': data['message'] ?? 'No autorizado',
        };
      } else {
        return {
          'success': false,
          'message':
              data['message'] ?? 'Error desconocido: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Excepción al conectar: $e',
      };
    }
  }

  static Future<Map<String, dynamic>> guardarVehiculo({
    required String marca,
    required String modelo,
    required String placa,
    required double capacidadCarga,
    required String anio,
  }) async {
    final url = Uri.parse('$_baseUrl/vehiculo');
    final token = await getToken();

    if (token == null) {
      return {
        'success': false,
        'message': 'No autorizado: Token no encontrado',
      };
    }

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'marca': marca,
          'modelo': modelo,
          'placa': placa,
          'capacidad_carga': capacidadCarga,
          'anio': anio,
        }),
      );

      print('Código de estado (guardarVehiculo): ${response.statusCode}');
      print('Cuerpo de la respuesta (guardarVehiculo): ${response.body}');

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': data['message'] ?? 'Vehículo guardado exitosamente',
          'vehiculo': data['vehiculo'],
        };
      } else if (response.statusCode == 400) {
        return {
          'success': false,
          'errors': data['errors'],
        };
      } else if (response.statusCode == 403) {
        return {
          'success': false,
          'message': data['message'] ?? 'No autorizado',
        };
      } else {
        return {
          'success': false,
          'message':
              data['message'] ?? 'Error desconocido: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Excepción al conectar: $e',
      };
    }
  }
}
