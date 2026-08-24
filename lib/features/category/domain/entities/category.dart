import 'package:equatable/equatable.dart';

class Category extends Equatable {
  final String id;
  final String name;
  final String? description;
  final DateTime? createdAt;
  final int iconCodePoint; // Material icon codePoint
  final int colorValue; // Color value (ARGB)

  const Category({
    required this.id,
    required this.name,
    this.description,
    this.createdAt,
    this.iconCodePoint = 0xe559, // Icons.category_outlined default
    this.colorValue = 0xFF6750A4, // Material purple default
  });

  Category copyWith({
    String? id,
    String? name,
    String? description,
    DateTime? createdAt,
    int? iconCodePoint,
    int? colorValue,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      iconCodePoint: iconCodePoint ?? this.iconCodePoint,
      colorValue: colorValue ?? this.colorValue,
    );
  }

  @override
  List<Object?> get props => [id, name, description, createdAt, iconCodePoint, colorValue];
}
