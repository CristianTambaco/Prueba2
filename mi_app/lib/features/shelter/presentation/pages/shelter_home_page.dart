// lib/features/shelter/presentation/pages/shelter_home_page.dart
import 'package:flutter/material.dart';

class ShelterHomePage extends StatelessWidget {
  const ShelterHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Inicio - Refugio')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.home, size: 80),
            const SizedBox(height: 16),
            const Text(
              'Bienvenido, Refugio',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Aquí irá la gestión de mascotas
              },
              child: const Text('Gestionar mascotas'),
            ),
          ],
        ),
      ),
    );
  }
}