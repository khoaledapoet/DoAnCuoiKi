import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'order_item.dart'; // Import OrderItem model
import '../entities/order_entity.dart'; // Sẽ tạo entity ở bước sau

class Order extends Equatable {
  final String orderId;
  final String userId;
  final String userName;
  final String userEmail;
  final List<OrderItem> items;
  final int totalPrice;
  final String status;
  final Timestamp timestamp;
  final String address;
  final String phoneNumber;

  const Order({
    required this.orderId,
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.items,
    required this.totalPrice,
    required this.status,
    required this.timestamp,
    required this.address,
    required this.phoneNumber,
  });

  // Tạo Order rỗng (nếu cần)
  static final empty = Order(
    orderId: '',
    userId: '',
    userName: '',
    userEmail: '',
    items: const [],
    totalPrice: 0,
    status: 'unknown',
    timestamp: Timestamp.now(),
    address: '',
    phoneNumber: '',
  );

  // Chuyển thành OrderEntity để tương tác với repo/Firestore
  OrderEntity toEntity() {
    return OrderEntity(
      orderId: orderId,
      userId: userId,
      userName: userName,
      userEmail: userEmail,
      // Chuyển List<OrderItem> thành List<Map>
      items: items.map((item) => item.toMap()).toList(),
      totalPrice: totalPrice,
      status: status,
      timestamp: timestamp,
      address: address,
      phoneNumber: phoneNumber,
    );
  }

  // Tạo Order từ OrderEntity
  static Order fromEntity(OrderEntity entity) {
    return Order(
      orderId: entity.orderId,
      userId: entity.userId,
      userName: entity.userName,
      userEmail: entity.userEmail,
      // Chuyển List<Map> thành List<OrderItem>
      items: entity.items.map((itemMap) => OrderItem.fromMap(itemMap)).toList(),
      totalPrice: entity.totalPrice,
      status: entity.status,
      timestamp: entity.timestamp,
      address: entity.address,
      phoneNumber: entity.phoneNumber,
    );
  }

  @override
  List<Object> get props => [
    orderId,
    userId,
    userName,
    userEmail,
    items,
    totalPrice,
    status,
    timestamp,
    address,
    phoneNumber,
  ];
}
