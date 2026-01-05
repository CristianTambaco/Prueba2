import 'package:equatable/equatable.dart';

class PetEntity extends Equatable {
  final String id;
  final String name;
  final String? description;
  final String? imageUrl;
  final DateTime createdAt;
  final String shelterId; // ID del refugio propietario

  const PetEntity({
    required this.id,
    required this.name,
    this.description,
    this.imageUrl,
    required this.createdAt,
    required this.shelterId,
  });

  @override
  List<Object?> get props => [id, name, description, imageUrl, createdAt, shelterId];
}