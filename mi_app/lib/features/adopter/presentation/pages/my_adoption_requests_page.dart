// lib/features/adopter/presentation/pages/my_adoption_requests_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../injection_container.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../adoption_request/domain/entities/adoption_request_entity.dart';
import '../../../adoption_request/domain/repositories/adoption_request_repository.dart';

class MyAdoptionRequestsPage extends StatefulWidget {
  const MyAdoptionRequestsPage({super.key});

  @override
  State<MyAdoptionRequestsPage> createState() => _MyAdoptionRequestsPageState();
}

class _MyAdoptionRequestsPageState extends State<MyAdoptionRequestsPage> {
  late Future<List<AdoptionRequestEntity>> _requestsFuture;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthBloc>().state is AuthAuthenticated
        ? (context.read<AuthBloc>().state as AuthAuthenticated).user
        : null;
    if (user != null) {
      _requestsFuture = getIt<AdoptionRequestRepository>()
          .getRequestsByAdopter(user.id)
          .then((r) => r.fold((l) => [], (r) => r));
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthBloc>().state is AuthAuthenticated
        ? (context.read<AuthBloc>().state as AuthAuthenticated).user
        : null;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Usuario no autenticado')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Mis Solicitudes')),
      body: FutureBuilder<List<AdoptionRequestEntity>>(
        future: _requestsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final requests = snapshot.data ?? [];
          if (requests.isEmpty) {
            return const Center(
              child: Text('No has enviado solicitudes aún.'),
            );
          }
          return ListView.builder(
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final req = requests[index];
              return _buildRequestCard(req);
            },
          );
        },
      ),
    );
  }

  Widget _buildRequestCard(AdoptionRequestEntity req) {
    String statusText;
    Color statusColor;
    switch (req.status) {
      case AdoptionStatus.pending:
        statusText = 'Pendiente';
        statusColor = Colors.orange;
        break;
      case AdoptionStatus.approved:
        statusText = 'Aprobada ✅';
        statusColor = Colors.green;
        break;
      case AdoptionStatus.rejected:
        statusText = 'Rechazada ❌';
        statusColor = Colors.red;
        break;
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: const Icon(Icons.pets, color: Colors.grey),
        title: Text('Solicitud para: ${req.petName}'),
        subtitle: Text('Refugio ID: ${req.shelterId}'),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Chip(
              label: Text(statusText),
              backgroundColor: statusColor.withOpacity(0.2),
              labelStyle: TextStyle(color: statusColor),
            ),
            if (req.status == AdoptionStatus.pending)
              TextButton(
                onPressed: () => _cancelRequest(req.id),
                child: const Text(
                  'Cancelar',
                  style: TextStyle(color: Colors.red),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _cancelRequest(String requestId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Cancelar solicitud?'),
        content: const Text('¿Estás seguro de que deseas cancelar esta solicitud?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('No')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Sí')),
        ],
      ),
    );

    if (confirmed == true) {
      final result = await getIt<AdoptionRequestRepository>()
          .updateStatus(requestId, AdoptionStatus.rejected);
      if (result.isRight()) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Solicitud cancelada')));
        final user = context.read<AuthBloc>().state is AuthAuthenticated
            ? (context.read<AuthBloc>().state as AuthAuthenticated).user
            : null;
        if (user != null) {
          setState(() {
            _requestsFuture = getIt<AdoptionRequestRepository>()
                .getRequestsByAdopter(user.id)
                .then((r) => r.fold((l) => [], (r) => r));
          });
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${result.fold((l) => l.message, (_) => "")}')),
        );
      }
    }
  }
}