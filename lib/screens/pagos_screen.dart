import 'package:flutter/material.dart';
import 'package:flutter_zapateria/export.dart'; // Asegúrate que ApiService esté aquí
import 'package:intl/intl.dart';

class PagosScreen extends StatefulWidget {
  @override
  _PagosScreenState createState() => _PagosScreenState();
}

class _PagosScreenState extends State<PagosScreen> {
  int filtroSeleccionado = 1;
  bool cargando = false;
  List compras = [];

  final Map<int, String> filtros = {
    1: 'En curso',
    2: 'Entregado',
    3: 'No entregado',
    4: 'Producto incorrecto',
  };

  @override
  void initState() {
    super.initState();
    cargarCompras(filtroSeleccionado);
  }

  Future<void> cargarCompras(int filtro) async {
    setState(() {
      cargando = true;
      filtroSeleccionado = filtro;
    });

    try {
      final data = await ApiService.getComprasPorEstado(filtro);
      setState(() {
        compras = data;
      });
    } catch (e) {
      setState(() {
        compras = [];
      });
      debugPrint('Error al cargar compras: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar compras')),
      );
    } finally {
      setState(() => cargando = false);
    }
  }

  String formatearFecha(String isoDate) {
    final fecha = DateTime.parse(isoDate);
    return DateFormat('dd/MM/yyyy HH:mm').format(fecha);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Historial de Compras')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Botones de filtro
            Wrap(
              spacing: 8,
              children: filtros.entries.map((entry) {
                final isSelected = filtroSeleccionado == entry.key;
                return ChoiceChip(
                  label: Text(entry.value),
                  selected: isSelected,
                  onSelected: (_) => cargarCompras(entry.key),
                  selectedColor: Colors.blue.shade100,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.blue.shade800 : Colors.black,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // Lista de compras
            Expanded(
              child: cargando
                  ? Center(child: CircularProgressIndicator())
                  : compras.isEmpty
                      ? Center(child: Text('No hay compras para este estado'))
                      : ListView.builder(
                          itemCount: compras.length,
                          itemBuilder: (context, index) {
                            final compra = compras[index];
                            return Card(
                              margin: EdgeInsets.symmetric(vertical: 6),
                              child: ListTile(
                                leading: Icon(Icons.shopping_bag,
                                    color: Colors.blue),
                                title: Text(
                                    'Compra #${compra['id']} - Bs. ${compra['total']}'),
                                subtitle: Text(
                                    'Volumen: ${compra['volumen_total']} | Fecha: ${formatearFecha(compra['created_at'])}'),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
