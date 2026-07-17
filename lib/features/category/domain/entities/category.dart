import 'package:equatable/equatable.dart';

class Category extends Equatable {
  final String id;
  final String name;
  final String? description;
  final DateTime? createdAt;

  const Category({
    required this.id,
    required this.name,
    this.description,
    this.createdAt,
  });

  Category copyWith({
    String? id,
    String? name,
    String? description,
    DateTime? createdAt,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [id, name, description, createdAt];
}
