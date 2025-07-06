import 'package:flutter/material.dart';

class PerfilScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage: NetworkImage('https://via.placeholder.com/150'),
            ),
            SizedBox(height: 16),
            Text(
              'Nombre del Usuario',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'cliente@example.com',
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                // Lógica para editar perfil (puedes conectar con ApiService)
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Funcionalidad de edición en desarrollo')),
                );
              },
              child: Text('Editar Perfil'),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 48),
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
            ),
            SizedBox(height: 16),
            TextButton(
              onPressed: () {
                // Lógica para cerrar sesión
                Navigator.pushReplacementNamed(context, '/');
              },
              child: Text(
                'Cerrar Sesión',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        ),
      ),
    );
  }
}