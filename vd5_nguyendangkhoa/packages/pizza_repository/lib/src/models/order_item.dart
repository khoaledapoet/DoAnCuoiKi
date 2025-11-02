import 'package:equatable/equatable.dart';
import 'pizza_size.dart';

class OrderItem extends Equatable {
  final String pizzaId;
  final String pizzaName;
  final int quantity;
  final int price; // Giá tại thời điểm đặt
  final PizzaSize size;

  const OrderItem({
    required this.pizzaId,
    required this.pizzaName,
    required this.quantity,
    required this.price,
    this.size = PizzaSize.medium,
  });

  // Chuyển thành Map để lưu vào Firestore (trong list 'items' của Order)
  Map<String, dynamic> toMap() {
    return {
      'pizzaId': pizzaId,
      'pizzaName': pizzaName,
      'quantity': quantity,
      'price': price,
      'size': size.toFirestore(),
    };
  }

  // Đọc từ Map lấy từ Firestore
  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      pizzaId: map['pizzaId'] ?? '',
      pizzaName: map['pizzaName'] ?? '',
      quantity: (map['quantity'] as num?)?.toInt() ?? 0,
      price: (map['price'] as num?)?.toInt() ?? 0,
      size: PizzaSize.fromString(map['size'] ?? 'medium'),
    );
  }

  @override
  List<Object> get props => [pizzaId, pizzaName, quantity, price, size];
}
