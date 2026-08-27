import '../../domain/entities/category.dart';

class CategoryModel extends Category {
  const CategoryModel({
    required super.id,
    required super.name,
    super.description,
    super.createdAt,
    super.iconCodePoint,
    super.colorValue,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      iconCodePoint: json['icon_code_point'] as int? ?? 0xe559,
      // Postgres `color_value` is `integer` (max 2,147,483,647). Dart stores
      // opaque ARGB (up to 4,294,967,295) which overflows that column and makes
      // add/update fail. We persist only the 24-bit RGB and restore alpha here
      // so the UI never sees a transparent color.
      colorValue: ((json['color_value'] as int? ?? 0xFF6750A4)) | 0xFF000000,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'created_at': createdAt?.toIso8601String(),
      'icon_code_point': iconCodePoint,
      'color_value': colorValue,
    };
  }

  factory CategoryModel.fromEntity(Category category) {
    return CategoryModel(
      id: category.id,
      name: category.name,
      description: category.description,
      createdAt: category.createdAt,
      iconCodePoint: category.iconCodePoint,
      colorValue: category.colorValue,
    );
  }

  Category toEntity() {
    return Category(
      id: id,
      name: name,
      description: description,
      createdAt: createdAt,
      iconCodePoint: iconCodePoint,
      colorValue: colorValue,
    );
  }
}
