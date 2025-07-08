import 'package:flutter/material.dart';
import 'package:flutter_zapateria/export.dart';
import 'package:flutter_zapateria/models/producto_carrito.dart';
import 'package:flutter_zapateria/screens/perfil_screen.dart';
import 'package:flutter_zapateria/screens/pagos_screen.dart';

class DashboardCliente extends StatefulWidget {
  @override
  _DashboardClienteState createState() => _DashboardClienteState();
}

class _DashboardClienteState extends State<DashboardCliente> {
  List productos = [];
  bool cargando = true;
  List<ProductoCarrito> carrito = [];
  Map<int, int> cantidades = {};
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    cargarProductos();
  }

  Future<void> cargarProductos() async {
    try {
      final datos = await ApiService.getProductos();
      setState(() {
        productos = datos;
        for (var i = 0; i < productos.length; i++) {
          cantidades[i] = 1;
        }
        cargando = false;
      });
    } catch (e) {
      print('Error al cargar productos: $e');
      setState(() => cargando = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar productos')),
      );
    }
  }

  void agregarAlCarrito(Map<String, dynamic> producto, int index) {
    int cantidadSeleccionada = cantidades[index] ?? 1;

    setState(() {
      int indiceEnCarrito =
          carrito.indexWhere((item) => item.producto['id'] == producto['id']);
      if (indiceEnCarrito != -1) {
        carrito[indiceEnCarrito].cantidad += cantidadSeleccionada;
      } else {
        carrito.add(ProductoCarrito(
          producto: {
            'id':
                producto['id'] ?? 'unknown', // Valor por defecto si id es nulo
            'nombre': producto['nombre'] ?? 'Sin nombre',
            'precio': producto['precio']
                .toString(), // Aseguramos que sea string para conversión posterior
            'imagen_url': producto['imagen_url'] ?? '',
          },
          cantidad: cantidadSeleccionada,
        ));
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            '${producto['nombre']} x$cantidadSeleccionada agregado al carrito.'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void eliminarDelCarrito(int index) {
    setState(() {
      final productoEliminado = carrito[index].producto['nombre'];
      carrito.removeAt(index);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$productoEliminado eliminado del carrito.'),
          duration: Duration(seconds: 2),
        ),
      );
    });
  }

  void mostrarCarrito() {
    double total = carrito.fold(0, (sum, item) => sum + item.subtotal);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) {
          double total = carrito.fold(0, (sum, item) => sum + item.subtotal);
          return AlertDialog(
            title: Text('Carrito de Compras'),
            content: Container(
              width: double.maxFinite,
              child: carrito.isEmpty
                  ? Text('Tu carrito está vacío.')
                  : ListView(
                      shrinkWrap: true,
                      children: [
                        ...carrito.asMap().entries.map((entry) {
                          final index = entry.key;
                          final item = entry.value;
                          return ListTile(
                            leading:
                                Icon(Icons.shopping_bag, color: Colors.blue),
                            title: Text(item.producto['nombre']),
                            subtitle: Text(
                                'Cantidad: ${item.cantidad} | ID: ${item.producto['id']}'),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('Bs. ${item.subtotal.toStringAsFixed(2)}'),
                                IconButton(
                                  icon: Icon(Icons.delete,
                                      color: Colors.red, size: 20),
                                  onPressed: () {
                                    setState(() {
                                      final nombre =
                                          carrito[index].producto['nombre'];
                                      carrito.removeAt(index);
                                      // Actualiza solo el diálogo
                                      setStateDialog(() {});
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(
                                              '$nombre eliminado del carrito.'),
                                          duration: Duration(seconds: 2),
                                        ),
                                      );
                                    });
                                  },
                                ),
                              ],
                            ),
                          );
                        }),
                        Divider(),
                        ListTile(
                          title: Text('Total',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          trailing: Text('Bs. ${total.toStringAsFixed(2)}',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('Cerrar'),
              ),
              if (carrito.isNotEmpty)
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.pushNamed(context, '/pago', arguments: carrito);
                  },
                  child: Text('Ir al Pago'),
                ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Zapatos Shop'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 15.0, top: 8.0),
            child: Badge(
              label: Text(carrito.length.toString()),
              isLabelVisible: carrito.isNotEmpty,
              child: IconButton(
                icon: Icon(Icons.shopping_cart),
                onPressed: mostrarCarrito,
              ),
            ),
          ),
        ],
      ),
      body: _currentIndex == 0
          ? cargando
              ? Center(child: CircularProgressIndicator())
              : GridView.builder(
                  padding: EdgeInsets.all(10),
                  itemCount: productos.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.60,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemBuilder: (context, index) {
                    final p = productos[index];
                    return Card(
                      elevation: 2,
                      clipBehavior: Clip.antiAlias,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            child: FadeInImage.assetNetwork(
                              placeholder:
                                  'assets/loading_placeholder.gif', // usa un gif pequeño o imagen de carga local
                              image: p['imagen_url'] ?? '',
                              fit: BoxFit.cover,
                              imageErrorBuilder: (context, error, stackTrace) {
                                return Image.network(
                                  'https://images.unsplash.com/photo-1517263904808-5dc0d6d3fa5c?auto=format&fit=crop&w=400&q=80',
                                  fit: BoxFit.cover,
                                );
                              },
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  p['nombre'] ?? 'Sin nombre',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Bs. ${double.tryParse(p['precio']?.toString() ?? '0.0')?.toStringAsFixed(2) ?? '0.00'}',
                                  style: TextStyle(
                                      color: Colors.green.shade700,
                                      fontWeight: FontWeight.bold),
                                ),
                                SizedBox(height: 4),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.remove, size: 16),
                                      onPressed: () {
                                        setState(() {
                                          if (cantidades[index]! > 1) {
                                            cantidades[index] =
                                                cantidades[index]! - 1;
                                          }
                                        });
                                      },
                                    ),
                                    Text(
                                      cantidades[index]?.toString() ?? '1',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.add, size: 16),
                                      onPressed: () {
                                        setState(() {
                                          cantidades[index] =
                                              (cantidades[index] ?? 1) + 1;
                                        });
                                      },
                                    ),
                                  ],
                                ),
                                SizedBox(height: 6),
                                ElevatedButton(
                                  onPressed: () => agregarAlCarrito(p, index),
                                  child: Text('Agregar'),
                                  style: ElevatedButton.styleFrom(
                                    minimumSize: Size(double.infinity, 30),
                                    backgroundColor: Colors.blue,
                                    foregroundColor: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                )
          : _currentIndex == 1
              ? PerfilScreen()
              : PagosScreen(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        selectedItemColor: Colors.blue.shade700,
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
          BottomNavigationBarItem(
              icon: Icon(Icons.shopping_bag), label: 'Compras'),
        ],
      ),
    );
  }
}
