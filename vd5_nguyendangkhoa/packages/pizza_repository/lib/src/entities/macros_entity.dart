// packages/pizza_repository/lib/src/entities/macros_entity.dart

class MacrosEntity {
  final int calories;
  final int proteins;
  final int fat;
  final int carbs;

  const MacrosEntity({
    required this.calories,
    required this.proteins,
    required this.fat,
    required this.carbs,
  });

  // Chuyển thành Map để lưu Firestore
  Map<String, Object?> toDocument() {
    return {
      'calories': calories,
      'proteins': proteins,
      'fat': fat,
      'carbs': carbs,
    };
  }

  // Đọc từ Map Firestore
  static MacrosEntity fromDocument(Map<String, dynamic> doc) {
    return MacrosEntity(
      calories: (doc['calories'] as num?)?.toInt() ?? 0,
      proteins: (doc['proteins'] as num?)?.toInt() ?? 0,
      fat: (doc['fat'] as num?)?.toInt() ?? 0,
      carbs: (doc['carbs'] as num?)?.toInt() ?? 0,
    );
  }

  // Entity rỗng
  static const empty = MacrosEntity(calories: 0, proteins: 0, fat: 0, carbs: 0);
}
