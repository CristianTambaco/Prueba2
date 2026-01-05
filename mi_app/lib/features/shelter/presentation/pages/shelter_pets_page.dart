import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../injection_container.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../pet/domain/entities/pet_entity.dart';
import '../../../pet/domain/repositories/pet_repository.dart';
import '../pages/add_edit_pet_page.dart';

class ShelterPetsPage extends StatefulWidget {
  const ShelterPetsPage({super.key});

  @override
  State<ShelterPetsPage> createState() => _ShelterPetsPageState();
}

class _ShelterPetsPageState extends State<ShelterPetsPage> {
  List<PetEntity> _pets = [];

  @override
  void initState() {
    super.initState();
    _loadPets();
  }

  Future<void> _loadPets() async {
    final user = context.read<AuthBloc>().state is AuthAuthenticated
        ? (context.read<AuthBloc>().state as AuthAuthenticated).user
        : null;

    if (user == null) return;

    final result = await getIt<PetRepository>().getPetsByShelter(user.id);
    setState(() {
      _pets = result.fold((l) => [], (r) => r);
    });
  }

  Future<void> _deletePet(String petId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Eliminar mascota?'),
        content: const Text('¿Estás seguro de eliminar esta mascota?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final result = await getIt<PetRepository>().deletePet(petId);
      if (result.isRight()) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Mascota eliminada')),
        );
        _loadPets(); // 👈 Refresca la lista
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${result.fold((l) => l.message, (_) => '')}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthBloc>().state is AuthAuthenticated
        ? (context.read<AuthBloc>().state as AuthAuthenticated).user
        : null;

    if (user == null) return const Center(child: Text('Error: No autenticado'));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Mascotas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AddEditPetPage(shelterId: user.id),
                ),
              ).then((_) => _loadPets()); // 👈 Recarga después de agregar/editar
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
              const Text(
                'Lista de mascotas',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: _pets.length,
                  itemBuilder: (context, index) {
                    final pet = _pets[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: pet.imageUrl != null
                            ? CircleAvatar(
                                backgroundImage: NetworkImage(pet.imageUrl!),
                              )
                            : const CircleAvatar(
                                child: Icon(Icons.pets),
                              ),
                        title: Text(pet.name),
                        subtitle: Text('${pet.type} • ${pet.age} años'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => AddEditPetPage(
                                      shelterId: user.id,
                                      pet: pet,
                                    ),
                                  ),
                                ).then((_) => _loadPets()); // 👈 Recarga después de editar
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline),
                              onPressed: () => _deletePet(pet.id),
                            ),
                          ],
                        ),
                      ),
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
}