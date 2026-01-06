// lib/features/shelter/presentation/pages/shelter_home_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../injection_container.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../adoption_request/domain/entities/adoption_request_entity.dart';
import '../../../adoption_request/domain/repositories/adoption_request_repository.dart';
import '../pages/shelter_pets_page.dart';

import '../pages/all_adoption_requests_page.dart';

class ShelterHomePage extends StatelessWidget {
  const ShelterHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthBloc>().state is AuthAuthenticated
        ? (context.read<AuthBloc>().state as AuthAuthenticated).user
        : null;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inicio - Refugio'),
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
                        Navigator.pop(context);
                        Navigator.pushReplacementNamed(context, '/login');
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
                    'Bienvenido, ${user?.displayName ?? user?.email.split('@').first}',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 8),
                  const Text('👋', style: TextStyle(fontSize: 20)),
                ],
              ),
              const SizedBox(height: 16),
              // Título principal
              const Text(
                'Refugio Patitas Felices',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const Text(
                'Panel de administración',
                style: TextStyle(fontSize: 16, color: Color(0xFF636E72)),
              ),
              const SizedBox(height: 16),
              // Estadísticas
              Row(
                children: [
                  _buildStatCard('15', 'Mascotas'),
                  const SizedBox(width: 8),
                  _buildStatCard('8', 'Pendientes'),
                  const SizedBox(width: 8),
                  _buildStatCard('23', 'Adoptadas'),
                ],
              ),
              const SizedBox(height: 24),
              // Solicitudes Recientes
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Solicitudes Recientes',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: () {
                      // Navegar a la nueva pantalla de todas las solicitudes
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const AllAdoptionRequestsPage()),
                      );
                    },
                    child: const Text(
                      'Ver todas',
                      style: TextStyle(color: Color(0xFFFF6B6B)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: FutureBuilder<List<AdoptionRequestEntity>>(
                  future: getIt<AdoptionRequestRepository>()
                      .getRequestsByShelter(user?.id ?? '')
                      .then((r) => r.fold((l) => [], (r) => r)),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final requests = snapshot.data ?? [];
                    return ListView.builder(
                      itemCount: requests.length,
                      itemBuilder: (context, index) {
                        final req = requests[index];
                        return _buildRequestCard(
                          petName: req.petName,
                          requester: req.adopterName,
                          status: req.status,
                          onApprove: () async {
                            await getIt<AdoptionRequestRepository>().updateStatus(req.id, AdoptionStatus.approved);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Aprobada')));
                            }
                          },
                          onReject: () async {
                            await getIt<AdoptionRequestRepository>().updateStatus(req.id, AdoptionStatus.rejected);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Rechazada')));
                            }
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        selectedItemColor: const Color(0xFF6C5CE7),
        unselectedItemColor: const Color(0xFF636E72),
        showSelectedLabels: true,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.pets_outlined),
            label: 'Mascotas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications_outlined),
            label: 'Solicitudes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Perfil',
          ),
        ],
        onTap: (index) {
          if (index == 1) { // Navegar a la página de mascotas
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ShelterPetsPage()),
            );
          } else if (index == 2) { // Navegar a la página de solicitudes
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AllAdoptionRequestsPage()),
            );
          }
        },
      ),
    );
  }

  Widget _buildStatCard(String count, String label) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFA29BFE),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              count,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRequestCard({
    required String petName,
    required String requester,
    required AdoptionStatus status,
    required VoidCallback onApprove,
    required VoidCallback onReject,
  }) {
    Color cardColor = Colors.white;
    Color statusIconColor = Colors.grey;

    switch (status) {
      case AdoptionStatus.pending:
        cardColor = Colors.yellow[50]!;
        statusIconColor = Colors.yellow[700]!;
        break;
      case AdoptionStatus.approved:
        cardColor = Colors.green[50]!;
        statusIconColor = Colors.green[700]!;
        break;
      case AdoptionStatus.rejected:
        cardColor = Colors.red[50]!;
        statusIconColor = Colors.red[700]!;
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: statusIconColor.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: const Color(0xFFF0F8FF),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Icon(Icons.pets, size: 20, color: Colors.grey[600]),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Solicitud para $petName',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  'De: $requester',
                  style: const TextStyle(fontSize: 14, color: Color(0xFF636E72)),
                ),
                const SizedBox(height: 4),
                Chip(
                  label: Text(
                    status.name.toUpperCase(),
                    style: TextStyle(
                      color: statusIconColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  backgroundColor: statusIconColor.withOpacity(0.1),
                ),
              ],
            ),
          ),
          Row(
            children: [
              if (status == AdoptionStatus.pending)
                IconButton(
                  icon: const Icon(Icons.check_circle_outline, color: Color(0xFF00D2A1)),
                  onPressed: onApprove,
                  tooltip: 'Aprobar',
                ),
              if (status == AdoptionStatus.pending)
                IconButton(
                  icon: const Icon(Icons.cancel_outlined, color: Color(0xFFFF6B6B)),
                  onPressed: onReject,
                  tooltip: 'Rechazar',
                ),
              if (status != AdoptionStatus.pending)
                Icon(
                  status == AdoptionStatus.approved
                      ? Icons.check_circle
                      : Icons.cancel,
                  color: statusIconColor,
                  size: 24,
                ),
            ],
          ),
        ],
      ),
    );
  }
}