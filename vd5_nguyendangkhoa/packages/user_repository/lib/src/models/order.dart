import 'package:cloud_firestore/cloud_firestore.dart' as fs;
import 'order_item.dart';

class Order {
  final String orderId;
  final String userId;
  final List<OrderItem> items;
  final int totalPrice;
  final String status;
  final DateTime createdAt;
  final String? address;
  final String? phone;

  Order({
    required this.orderId,
    required this.userId,
    required this.items,
    required this.totalPrice,
    required this.status,
    required this.createdAt,
    this.address,
    this.phone,
  });

  OrderEntity toEntity() => OrderEntity(this);
}

class OrderEntity {
  final Order order;
  OrderEntity(this.order);

  Map<String, dynamic> toDocument() {
    return {
      'orderId': order.orderId,
      'userId': order.userId,
      'items': order.items.map((i) => i.toDocument()).toList(),
      'totalPrice': order.totalPrice,
      'status': order.status,
      'createdAt': fs.Timestamp.fromDate(order.createdAt),
      'address': order.address,
      'phone': order.phone,
    }..removeWhere((key, value) => value == null);
  }
}