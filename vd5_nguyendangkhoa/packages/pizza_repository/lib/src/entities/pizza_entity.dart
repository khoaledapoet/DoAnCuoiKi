import '../models/models.dart';
import 'macros_entity.dart';

class PizzaEntity {
  final String pizzaId;
  final String picture;
  final bool isVeg;
  final int spicy;
  final String name;
  final String description;
  final int price;
  final int discount;
  final Macros macros;

  const PizzaEntity({
    required this.pizzaId,
    required this.picture,
    required this.isVeg,
    required this.spicy,
    required this.name,
    required this.description,
    required this.price,
    required this.discount,
    required this.macros,
  });

  Map<String, Object?> toDocument() {
    return {
      'picture': picture,
      'isVeg': isVeg,
      'spicy': spicy,
      'name': name,
      'description': description,
      'price': price,
      'discount': discount,
      'macros': macros.toEntity().toDocument(),
    };
  }

  static PizzaEntity fromDocument(Map<String, dynamic> doc, String id) {
    final macrosRaw = doc['macros'];
    final Map<String, dynamic> macrosMap = (macrosRaw is Map<String, dynamic>)
        ? macrosRaw
        : {'calories': 0, 'proteins': 0, 'fat': 0, 'carbs': 0};

    return PizzaEntity(
      pizzaId: id,
      picture: doc['picture'] ?? '',
      isVeg: doc['isVeg'] ?? false,
      spicy: (doc['spicy'] is num) ? (doc['spicy'] as num).toInt() : 1,
      name: doc['name'] ?? '',
      description: doc['description'] ?? '',
      price: (doc['price'] is num) ? (doc['price'] as num).toInt() : 0,
      discount: (doc['discount'] is num) ? (doc['discount'] as num).toInt() : 0,
      macros: Macros.fromEntity(MacrosEntity.fromDocument(macrosMap)),
    );
  }
}
