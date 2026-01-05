// lib/features/adopter/presentation/pages/adopter_home_page.dart
import 'package:flutter/material.dart';

class AdopterHomePage extends StatelessWidget {
  const AdopterHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Inicio - Adoptante')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.pets, size: 80),
            const SizedBox(height: 16),
            const Text(
              'Bienvenido, Adoptante',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Aquí irá la lista de mascotas
              },
              child: const Text('Ver mascotas disponibles'),
            ),
          ],
        ),
      ),
    );
  }
}