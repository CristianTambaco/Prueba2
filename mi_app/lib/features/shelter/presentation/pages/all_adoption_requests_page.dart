// lib/features/shelter/presentation/pages/all_adoption_requests_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../injection_container.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../adoption_request/domain/entities/adoption_request_entity.dart';
import '../../../adoption_request/domain/repositories/adoption_request_repository.dart';

class AllAdoptionRequestsPage extends StatefulWidget {
  const AllAdoptionRequestsPage({super.key});

  @override
  State<AllAdoptionRequestsPage> createState() => _AllAdoptionRequestsPageState();
}

class _AllAdoptionRequestsPageState extends State<AllAdoptionRequestsPage> {
  AdoptionStatus? _filterStatus;
  List<AdoptionRequestEntity> _allRequests = [];

  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

  Future<void> _loadRequests() async {
    final user = context.read<AuthBloc>().state is AuthAuthenticated
        ? (context.read<AuthBloc>().state as AuthAuthenticated).user
        : null;
    if (user == null) return;

    final result = await getIt<AdoptionRequestRepository>().getRequestsByShelter(user.id);
    setState(() {
      _allRequests = result.fold((l) => [], (r) => r);
    });
  }

  List<AdoptionRequestEntity> get _filteredRequests {
    if (_filterStatus == null) return _allRequests;
    return _allRequests.where((req) => req.status == _filterStatus).toList();
  }

  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthBloc>().state is AuthAuthenticated
        ? (context.read<AuthBloc>().state as AuthAuthenticated).user
        : null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Todas las Solicitudes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadRequests,
            tooltip: 'Recargar',
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Filtros
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildFilterChip('Todas', null),
                  _buildFilterChip('Pendientes', AdoptionStatus.pending),
                  _buildFilterChip('Aprobadas', AdoptionStatus.approved),
                  _buildFilterChip('Rechazadas', AdoptionStatus.rejected),
                ],
              ),

              const SizedBox(height: 16),
              // Lista de solicitudes
              Expanded(
                child: ListView.builder(
                  itemCount: _filteredRequests.length,
                  itemBuilder: (context, index) {
                    final req = _filteredRequests[index];
                    return _buildRequestCard(
                      petName: req.petName,
                      requester: req.adopterName,
                      status: req.status,
                      onApprove: () async {
                        await getIt<AdoptionRequestRepository>().updateStatus(req.id, AdoptionStatus.approved);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Solicitud aprobada')));
                          _loadRequests(); // Recargar la lista
                        }
                      },
                      onReject: () async {
                        await getIt<AdoptionRequestRepository>().updateStatus(req.id, AdoptionStatus.rejected);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Solicitud rechazada')));
                          _loadRequests(); // Recargar la lista
                        }
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, AdoptionStatus? status) {
    return FilterChip(
      label: Text(label),
      selected: _filterStatus == status,
      onSelected: (selected) {
        setState(() {
          _filterStatus = selected ? status : null;
        });
      },
      selectedColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
      checkmarkColor: Theme.of(context).colorScheme.primary,
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

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: cardColor,
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFFF0F8FF),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Icon(Icons.pets, size: 20, color: Colors.grey[600]),
          ),
        ),
        title: Text(
          'Solicitud para $petName',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('De: $requester'),
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
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
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
      ),
    );
  }
}