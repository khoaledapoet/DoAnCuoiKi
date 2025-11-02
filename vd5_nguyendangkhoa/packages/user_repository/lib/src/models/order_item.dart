import 'package:pizza_repository/pizza_repository.dart';

class OrderItem {
  final String pizzaId;
  final String name;
  final String picture;
  final int price;
  final int quantity;
  final String size;

  OrderItem({
    required this.pizzaId,
    required this.name,
    required this.picture,
    required this.price,
    required this.quantity,
    required this.size,
  });

  // Factory chuyển từ CartItem
  factory OrderItem.fromCartItem(CartItem c) {
    return OrderItem(
      pizzaId: c.pizzaId,
      name: c.pizzaName,
      picture: c.picture,
      price: c.price,
      quantity: c.quantity,
      // Lưu size dưới dạng string (ví dụ 'small'/'medium'/'large')
      size: c.size.toString().split('.').last,
    );
  }

  Map<String, dynamic> toDocument() {
    return {
      'pizzaId': pizzaId,
      'name': name,
      'picture': picture,
      'price': price,
      'quantity': quantity,
      'size': size,
    };
  }
}