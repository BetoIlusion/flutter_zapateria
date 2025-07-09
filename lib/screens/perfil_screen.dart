import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_zapateria/export.dart';

class PerfilScreen extends StatefulWidget {
  const PerfilScreen({super.key});

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  Map<String, dynamic>? userData;
  Map<String, dynamic>? vehiculoData;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    try {
      final userResponse = await ApiService.getUser();
      if (userResponse['success']) {
        setState(() {
          userData = userResponse['data'];
        });

        if (userData?['rol'] == 'distribuidor') {
          final vehiculoResponse = await ApiService.getVehiculo();
          if (vehiculoResponse['success'] && vehiculoResponse['data'] != null) {
            setState(() {
              vehiculoData = vehiculoResponse['data'];
            });
          }
        }
      } else {
        setState(() {
          errorMessage =
              userResponse['message'] ?? 'Error al cargar datos del usuario';
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error al cargar datos: $e';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _cerrarSesion() async {
    await ApiService.logout();
    Navigator.pushReplacementNamed(context, '/');
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Perfil'),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
              ? Center(
                  child: Text(
                    errorMessage!,
                    style: textTheme.bodyLarge?.copyWith(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Información del usuario
                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Información del Usuario',
                                style: GoogleFonts.poppins(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  color: colorScheme.primary,
                                ),
                              ),
                              const SizedBox(height: 16),
                              _buildInfoRow(
                                  'Nombre',
                                  userData?['name'] ?? 'Sin nombre',
                                  Icons.person),
                              const SizedBox(height: 12),
                              _buildInfoRow(
                                  'Email',
                                  userData?['email'] ?? 'Sin email',
                                  Icons.email),
                              const SizedBox(height: 12),
                              _buildInfoRow(
                                  'Teléfono',
                                  userData?['telefono'] ?? 'Sin teléfono',
                                  Icons.phone),
                              const SizedBox(height: 12),
                              _buildInfoRow('Rol',
                                  userData?['rol'] ?? 'Sin rol', Icons.badge),
                            ],
                          ),
                        ),
                      ),
                      // Información del vehículo (solo para distribuidores)
                      if (userData?['rol'] == 'distribuidor' &&
                          vehiculoData != null) ...[
                        const SizedBox(height: 16),
                        Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Información del Vehículo',
                                  style: GoogleFonts.poppins(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                    color: colorScheme.primary,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                _buildInfoRow(
                                    'Marca',
                                    vehiculoData?['marca'] ?? 'Sin marca',
                                    Icons.directions_car),
                                const SizedBox(height: 12),
                                _buildInfoRow(
                                    'Modelo',
                                    vehiculoData?['modelo'] ?? 'Sin modelo',
                                    Icons.model_training),
                                const SizedBox(height: 12),
                                _buildInfoRow(
                                    'Placa',
                                    vehiculoData?['placa'] ?? 'Sin placa',
                                    Icons.numbers),
                                const SizedBox(height: 12),
                                _buildInfoRow(
                                    'Capacidad de Carga',
                                    '${vehiculoData?['capacidad_carga'] ?? '0'} kg',
                                    Icons.line_weight),
                                const SizedBox(height: 12),
                                _buildInfoRow(
                                    'Año',
                                    vehiculoData?['anio'] ?? 'Sin año',
                                    Icons.calendar_today),
                              ],
                            ),
                          ),
                        ),
                      ],
                      // Reemplaza la sección del botón de cerrar sesión
                      const SizedBox(height: 24),
                      Center(
                        child: Column(
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                Navigator.pushNamed(context, '/ubicacion_mapa',
                                    arguments: userData?['rol']);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue.shade700,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 32, vertical: 12),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                              ),
                              child: Text(
                                'Actualizar Ubicación',
                                style: GoogleFonts.poppins(
                                    fontSize: 16, fontWeight: FontWeight.w500),
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextButton(
                              onPressed: _cerrarSesion,
                              child: Text(
                                'Cerrar Sesión',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  color: Colors.red,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.blue.shade700, size: 24),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
