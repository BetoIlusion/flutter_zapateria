import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_zapateria/export.dart';

class AuthScreen extends StatefulWidget {
  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  bool isLogin = true;
  String name = '';
  String email = '';
  String password = '';
  String userType = 'cliente';

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    final response = await ApiService.login(
      email: email,
      password: password,
    );

    switch (response['rol']) {
      case 'cliente':
        Navigator.pushReplacementNamed(context, '/dashboard_cliente');
        break;
      case 'distribuidor':
        Navigator.pushReplacementNamed(context, '/dashboard_distribuidor');
        break;
      case 'admin':
        Navigator.pushReplacementNamed(context, '/dashboard_admin');
        break;
      default:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: Rol no reconocido')),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade50, Colors.white],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        isLogin ? 'Iniciar Sesión' : 'Crear Cuenta',
                        style: GoogleFonts.poppins(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade900,
                        ),
                      ),
                      const SizedBox(height: 16),
                      AnimatedCrossFade(
                        firstChild: const SizedBox.shrink(),
                        secondChild: TextFormField(
                          decoration: _buildInputDecoration(
                            label: 'Nombre',
                            icon: Icons.person,
                          ),
                          onSaved: (value) => name = value!,
                        ),
                        crossFadeState: isLogin
                            ? CrossFadeState.showFirst
                            : CrossFadeState.showSecond,
                        duration: const Duration(milliseconds: 300),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        decoration: _buildInputDecoration(
                          label: 'Email',
                          icon: Icons.email,
                        ),
                        validator: (value) =>
                            value!.contains('@') ? null : 'Email inválido',
                        onSaved: (value) => email = value!,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        decoration: _buildInputDecoration(
                          label: 'Contraseña',
                          icon: Icons.lock,
                        ),
                        obscureText: true,
                        validator: (value) => value!.length >= 6
                            ? null
                            : 'Mínimo 6 caracteres',
                        onSaved: (value) => password = value!,
                      ),
                      const SizedBox(height: 16),
                      AnimatedCrossFade(
                        firstChild: const SizedBox.shrink(),
                        secondChild: DropdownButtonFormField<String>(
                          value: userType,
                          items: ['cliente', 'distribuidor']
                              .map((type) => DropdownMenuItem(
                                    value: type,
                                    child: Text(type.capitalize()),
                                  ))
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              userType = value!;
                            });
                          },
                          decoration: _buildInputDecoration(
                            label: 'Tipo de Usuario',
                            icon: Icons.group,
                          ),
                        ),
                        crossFadeState: isLogin
                            ? CrossFadeState.showFirst
                            : CrossFadeState.showSecond,
                        duration: const Duration(milliseconds: 300),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _submit,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 4,
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.blue.shade600, Colors.blue.shade900],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 12,
                          ),
                          child: Text(
                            isLogin ? 'Iniciar Sesión' : 'Registrarse',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            isLogin = !isLogin;
                          });
                        },
                        child: Text(
                          isLogin
                              ? '¿No tienes cuenta? Regístrate'
                              : '¿Ya tienes cuenta? Inicia sesión',
                          style: GoogleFonts.poppins(
                            color: Colors.blue.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration({required String label, required IconData icon}) {
    return InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.poppins(
        color: Colors.grey.shade600,
      ),
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

extension StringCasingExtension on String {
  String capitalize() =>
      '${this[0].toUpperCase()}${substring(1).toLowerCase()}';
}