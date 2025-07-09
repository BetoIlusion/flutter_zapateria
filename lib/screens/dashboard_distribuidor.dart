import 'package:flutter/material.dart';
import 'package:flutter_zapateria/export.dart';
import 'package:intl/intl.dart'; // Asegúrate de agregar 'intl' a tu pubspec.yaml

class DashboardDistribuidor extends StatefulWidget {
  const DashboardDistribuidor({super.key});

  @override
  State<DashboardDistribuidor> createState() => _DashboardDistribuidorState();
}

class _DashboardDistribuidorState extends State<DashboardDistribuidor> {
  int _currentIndex = 0;
  List _asignaciones = [];
  bool isLibre = false;
  bool _cargando = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    cargarEstado();
    cargarAsignaciones();
  }

  Future<void> cargarEstado() async {
    try {
      final res = await ApiService.getDistribuidorEstado();
      setState(() {
        isLibre = res['estado'] == 'libre';
      });
    } catch (_) {}
  }

  Future<void> toggleEstado() async {
    try {
      final res = await ApiService.toggleDistribuidorEstado();
      setState(() {
        isLibre = res['estado'] == 'libre';
      });
    } catch (_) {}
  }

  /// Carga las asignaciones desde la API y actualiza el estado.
  Future<void> cargarAsignaciones() async {
    if (!mounted) return;
    setState(() {
      _cargando = true;
      _error = null;
    });

    try {
      final data = await ApiService.getAsignaciones();
      print('Asignaciones recibidas: $data'); // Depuración
      if (!mounted) return;
      setState(() {
        _asignaciones = data;
        if (_asignaciones.isEmpty) {
          _error = 'No tienes asignaciones';
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'No se pudieron cargar las asignaciones: $e';
        _asignaciones = [];
      });
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red.shade700,
          ),
        );
    } finally {
      if (mounted) {
        setState(() => _cargando = false);
      }
    }
  }

  /// Formatea la fecha para una mejor lectura.
  String _formatDate(String dateString) {
    try {
      final dateTime = DateTime.parse(dateString);
      // Formato: "MMM d, hh:mm a" -> "Jul 20, 10:30 AM"
      return DateFormat('MMM d, hh:mm a', 'es_ES').format(dateTime);
    } catch (e) {
      return dateString.substring(0, 16).replaceFirst('T', ' '); // Fallback
    }
  }

  /// Construye la tarjeta de una asignación con un diseño más intuitivo.
  Widget _buildAsignacionCard(Map<String, dynamic> a) {
    // Usamos los colores y estilos del tema actual para consistencia.
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      shadowColor: Colors.black.withOpacity(0.1),
      child: InkWell(
        onTap: () => _navigateToRuta(a), // Permite tocar toda la tarjeta
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- TÍTULO Y ID DE COMPRA ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Usamos Flexible para evitar overflows si el nombre es muy largo
                  Flexible(
                    child: Text(
                      a['cliente_nombre'] ?? 'Cliente Desconocido',
                      style: textTheme.titleLarge
                          ?.copyWith(fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Chip(
                    label: Text('ID: ${a['id_compra']}'),
                    backgroundColor:
                        colorScheme.secondaryContainer.withOpacity(0.5),
                    labelStyle: textTheme.bodySmall,
                    padding: EdgeInsets.zero,
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // --- FECHA DE ASIGNACIÓN ---
              Text(
                'Asignado: ${_formatDate(a['fecha_asignada'])}',
                style:
                    textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
              ),
              const Divider(height: 24),

              // --- DETALLES CON ICONOS ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildDetailItem(Icons.inventory_2_outlined,
                      '${a['volumen_total']}', 'Volumen'),
                  _buildDetailItem(Icons.pin_drop_outlined,
                      '${a['distancia_km']} km', 'Distancia'),
                  _buildDetailItem(Icons.timer_outlined,
                      '${a['tiempo_min']} min', 'Tiempo est.'),
                ],
              ),
              const SizedBox(height: 20),

              // --- BOTÓN DE ACCIÓN ---
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton.icon(
                  onPressed: () => _navigateToRuta(a),
                  icon: const Icon(Icons.navigation_outlined),
                  label: const Text('Iniciar Ruta'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: colorScheme.onPrimary,
                    backgroundColor: colorScheme.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Widget auxiliar para mostrar un detalle con icono y texto.
  Widget _buildDetailItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.primary, size: 28),
        const SizedBox(height: 4),
        Text(value,
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.bold)),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }

  // En dashboard_distribuidor.dart (esta función ya la tienes y es correcta)
  void _navigateToRuta(Map<String, dynamic> a) {
    if (a['id'] == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ID de asignación no disponible'),
          backgroundColor: Colors.red.shade700,
        ),
      );
      return;
    }
    Navigator.pushNamed(
      context,
      '/seguir_ruta',
      arguments: {
        'id_compra': a['id_compra'],
        'id_distribuidor': a['id_distribuidor'],
        'id_asignacion': a['id'], // Cambiado de 'id_asignacion' a 'id'
      },
    );
  }

  /// Construye la vista principal que muestra el estado de carga, vacío o la lista de asignaciones.
  Widget _buildAsignacionesView() {
    if (_cargando) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_asignaciones.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: cargarAsignaciones,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        itemCount: _asignaciones.length,
        itemBuilder: (context, index) {
          return _buildAsignacionCard(_asignaciones[index]);
        },
      ),
    );
  }

  /// Widget para mostrar cuando no hay asignaciones. Es más amigable que un simple texto.
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 80, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              _error ?? 'No tienes asignaciones',
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Las nuevas entregas aparecerán aquí. ¡Refresca la pantalla para verificar!',
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
                onPressed: cargarAsignaciones,
                icon: const Icon(Icons.refresh),
                label: const Text('Actualizar ahora'))
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Actualiza la lista de pages
    final List<Widget> pages = [
      _buildAsignacionesView(),
      const VehiculoScreen(), // Reemplaza el placeholder por VehiculoScreen
      PerfilScreen(), // Asegúrate de que PerfilScreen esté importado
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Entregas'),
        centerTitle: false,
        actions: [
          IconButton(
            icon: Icon(
              isLibre ? Icons.toggle_on : Icons.toggle_off,
              color: isLibre ? Colors.green : Colors.red,
              size: 32,
            ),
            tooltip: isLibre ? 'Estado: Libre' : 'Estado: No libre',
            onPressed: toggleEstado,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: cargarAsignaciones,
            tooltip: 'Actualizar',
          )
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: pages,
      ),
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton.extended(
              onPressed: () {
                // TODO: Implementar una acción útil, como mostrar un mapa general
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Acción de rutas generales')),
                );
              },
              label: const Text('Rutas'),
              icon: const Icon(Icons.map_outlined),
            )
          : null,
      // Modifica el BottomNavigationBar para manejar la navegación a VehiculoScreen
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          if (index == 1) {
            // Navega a VehiculoScreen cuando se selecciona "Vehículo"
            Navigator.pushNamed(context, '/vehiculo');
          } else {
            setState(() => _currentIndex = index);
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment_turned_in_outlined),
            activeIcon: Icon(Icons.assignment_turned_in),
            label: 'Entregas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_shipping_outlined),
            activeIcon: Icon(Icons.local_shipping),
            label: 'Vehículo',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}
