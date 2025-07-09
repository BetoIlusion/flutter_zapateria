import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_zapateria/export.dart';

class VehiculoScreen extends StatefulWidget {
  const VehiculoScreen({super.key});

  @override
  State<VehiculoScreen> createState() => _VehiculoScreenState();
}

class _VehiculoScreenState extends State<VehiculoScreen> {
  final _formKey = GlobalKey<FormState>();
  String marca = '';
  String modelo = '';
  String placa = '';
  double? capacidadCarga;
  String anio = '';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarDatosVehiculo();
  }

  void _cargarDatosVehiculo() async {
    try {
      final response = await ApiService.getVehiculo();
      if (response['success'] && response['data'] != null) {
        setState(() {
          marca = response['data']['marca'] ?? '';
          modelo = response['data']['modelo'] ?? '';
          placa = response['data']['placa'] ?? '';
          capacidadCarga = response['data']['capacidad_carga']?.toDouble();
          anio = response['data']['anio'] ?? '';
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['message'] ?? 'Error al cargar datos del vehículo')),
        );
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar vehículo: $e')),
      );
    }
  }

  void _guardarVehiculo() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    try {
      final response = await ApiService.guardarVehiculo(
        marca: marca,
        modelo: modelo,
        placa: placa,
        capacidadCarga: capacidadCarga!,
        anio: anio,
      );

      if (!response['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['message'] ?? 'Error al guardar vehículo')),
        );
        return;
      }

      Navigator.pushReplacementNamed(context, '/dashboard_distribuidor');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar vehículo: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Datos del Vehículo')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    TextFormField(
                      initialValue: marca,
                      decoration: _buildInputDecoration(label: 'Marca', icon: Icons.directions_car),
                      validator: (value) => value!.isEmpty ? 'La marca es requerida' : null,
                      onSaved: (value) => marca = value!,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      initialValue: modelo,
                      decoration: _buildInputDecoration(label: 'Modelo', icon: Icons.model_training),
                      validator: (value) => value!.isEmpty ? 'El modelo es requerido' : null,
                      onSaved: (value) => modelo = value!,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      initialValue: placa,
                      decoration: _buildInputDecoration(label: 'Placa', icon: Icons.numbers),
                      validator: (value) => value!.isEmpty ? 'La placa es requerida' : null,
                      onSaved: (value) => placa = value!,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      initialValue: capacidadCarga?.toString(),
                      decoration: _buildInputDecoration(label: 'Capacidad de Carga (kg)', icon: Icons.line_weight),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value!.isEmpty) return 'La capacidad es requerida';
                        if (double.tryParse(value) == null) return 'Ingrese un número válido';
                        return null;
                      },
                      onSaved: (value) => capacidadCarga = double.parse(value!),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      initialValue: anio,
                      decoration: _buildInputDecoration(label: 'Año', icon: Icons.calendar_today),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value!.isEmpty) return 'El año es requerido';
                        if (int.tryParse(value) == null || value.length != 4) return 'Ingrese un año válido';
                        return null;
                      },
                      onSaved: (value) => anio = value!,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _guardarVehiculo,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(
                        'Guardar Vehículo',
                        style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  InputDecoration _buildInputDecoration({required String label, required IconData icon}) {
    return InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.poppins(color: Colors.grey.shade600),
      prefixIcon: Icon(icon, color: Colors.blue.shade700),
      filled: true,
      fillColor: Colors.grey.shade50,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.blue.shade700, width: 2),
      ),
    );
  }
}