// lib/features/adopter/presentation/pages/adopter_home_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../injection_container.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';

class AdopterHomePage extends StatelessWidget {
  const AdopterHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthBloc>().state is AuthAuthenticated
        ? (context.read<AuthBloc>().state as AuthAuthenticated).user
        : null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inicio - Adoptante'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('¿Cerrar sesión?'),
                  content: const Text('¿Estás seguro de que deseas cerrar sesión?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancelar'),
                    ),
                    TextButton(
                      onPressed: () {
                        context.read<AuthBloc>().add(const SignOutRequested());
                        Navigator.pop(context); // Cierra el diálogo
                        Navigator.pushReplacementNamed(context, '/login'); // Redirige a login
                      },
                      child: const Text('Cerrar sesión', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Saludo personalizado
              Row(
                children: [
                  Text(
                    'Hola, ${user?.displayName ?? user?.email.split('@').first}',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 8),
                  const Text('👋', style: TextStyle(fontSize: 20)),
                ],
              ),
              const SizedBox(height: 16),

              // Título principal
              const Text(
                'Encuentra tu mascota',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              // Campo de búsqueda
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search, color: Color(0xFF636E72)),
                    hintText: 'Buscar mascota...',
                    hintStyle: const TextStyle(color: Color(0xFFB2BEC3)),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Botones de filtro
              Row(
                children: [
                  _buildFilterButton('Todos', true),
                  const SizedBox(width: 8),
                  _buildFilterButton('Perros', false),
                  const SizedBox(width: 8),
                  _buildFilterButton('Gatos', false),
                ],
              ),
              const SizedBox(height: 16),

              // Cuadrícula de mascotas (ejemplo estático)
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.0,
                  children: [
                    _buildPetCard(
                      name: 'Luna',
                      type: 'Labrador',
                      age: '2 años',
                      distance: '2.5 km',
                      image: 'assets/images/dog.png',
                      isLiked: true,
                    ),
                    _buildPetCard(
                      name: 'Michi',
                      type: 'Persa',
                      age: '1 año',
                      distance: '2.5 km',
                      image: 'assets/images/cat.png',
                      isLiked: false,
                    ),
                    _buildPetCard(
                      name: 'Max',
                      type: 'Golden Retriever',
                      age: '3 años',
                      distance: '3.0 km',
                      image: 'assets/images/dog2.png',
                      isLiked: false,
                    ),
                    _buildPetCard(
                      name: 'Mimi',
                      type: 'Siamés',
                      age: '6 meses',
                      distance: '1.8 km',
                      image: 'assets/images/cat2.png',
                      isLiked: true,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        selectedItemColor: const Color(0xFFFF8C42),
        unselectedItemColor: const Color(0xFF636E72),
        showSelectedLabels: true,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.location_on_outlined),
            label: 'Mapa',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            label: 'Chat IA',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_border),
            label: 'Solicitudes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }

  Widget _buildFilterButton(String text, bool isSelected) {
    return ElevatedButton(
      onPressed: () {},
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? const Color(0xFFFF8C42) : Colors.white,
        foregroundColor: isSelected ? Colors.white : const Color(0xFF2D3436),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: isSelected ? Colors.transparent : const Color(0xFFE0E0E0),
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
      ),
      child: Text(text),
    );
  }

  Widget _buildPetCard({
    required String name,
    required String type,
    required String age,
    required String distance,
    required String image,
    required bool isLiked,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Imagen de la mascota
          Container(
            height: 80,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              color: isLiked ? const Color(0xFFFFE0E0) : const Color(0xFFF0F8FF),
            ),
            child: Center(
              child: Image.asset(
                image,
                width: 50,
                height: 50,
                fit: BoxFit.contain,
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Nombre y tipo
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  '$type • $age',
                  style: const TextStyle(fontSize: 14, color: Color(0xFF636E72)),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 16, color: Color(0xFF636E72)),
                    const SizedBox(width: 4),
                    Text(
                      distance,
                      style: const TextStyle(fontSize: 12, color: Color(0xFF636E72)),
                    ),
                    const Spacer(),
                    Icon(
                      isLiked ? Icons.favorite : Icons.favorite_border,
                      color: isLiked ? const Color(0xFFFF6B6B) : const Color(0xFF636E72),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}