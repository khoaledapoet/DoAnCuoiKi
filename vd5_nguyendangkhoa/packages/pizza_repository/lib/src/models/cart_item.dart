import 'package:equatable/equatable.dart';
import 'pizza_size.dart';

// Model này đại diện cho 1 món hàng trong giỏ (lưu trong subcollection 'cart')
class CartItem extends Equatable {
  final String pizzaId; // ID của pizza
  final String pizzaName;
  final String picture;
  final int price; // Giá của 1 cái (tại thời điểm thêm vào)
  final int quantity;
  final PizzaSize size; // Thêm size

  const CartItem({
    required this.pizzaId,
    required this.pizzaName,
    required this.picture,
    required this.price,
    required this.quantity,
    this.size = PizzaSize.medium, // Mặc định là size vừa
  });

  // Tạo ID duy nhất cho cart item (kết hợp pizzaId và size)
  String get cartItemId => '${pizzaId}_${size.toFirestore()}';

  // Hàm rỗng
  static final empty = CartItem(
    pizzaId: '',
    pizzaName: '',
    picture: '',
    price: 0,
    quantity: 0,
    size: PizzaSize.medium,
  );

  // Chuyển thành Map để lưu vào Firestore
  Map<String, dynamic> toMap() {
    return {
      'pizzaId': pizzaId, // Lưu pizzaId để có thể đọc lại
      'pizzaName': pizzaName,
      'picture': picture,
      'price': price,
      'quantity': quantity,
      'size': size.toFirestore(), // Lưu size dưới dạng string
    };
  }

  // Đọc từ Map (từ Firestore)
  factory CartItem.fromMap(Map<String, dynamic> map, String cartItemId) {
    return CartItem(
      pizzaId: map['pizzaId'] ?? '', // Đọc pizzaId từ data
      pizzaName: map['pizzaName'] ?? '',
      picture: map['picture'] ?? '',
      price: (map['price'] as num?)?.toInt() ?? 0,
      quantity: (map['quantity'] as num?)?.toInt() ?? 0,
      size: PizzaSize.fromString(map['size'] ?? 'medium'),
    );
  }

  // Hàm copyWith để dễ dàng cập nhật (ví dụ: tăng số lượng)
  CartItem copyWith({
    String? pizzaId,
    String? pizzaName,
    String? picture,
    int? price,
    int? quantity,
    PizzaSize? size,
  }) {
    return CartItem(
      pizzaId: pizzaId ?? this.pizzaId,
      pizzaName: pizzaName ?? this.pizzaName,
      picture: picture ?? this.picture,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      size: size ?? this.size,
    );
  }

  @override
  List<Object?> get props => [pizzaId, pizzaName, picture, price, quantity, size];
}
