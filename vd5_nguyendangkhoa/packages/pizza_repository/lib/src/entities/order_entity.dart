import 'package:cloud_firestore/cloud_firestore.dart';

class OrderEntity {
  final String orderId;
  final String userId;
  final String userName;
  final String userEmail;
  final List<Map<String, dynamic>> items; // Lưu dạng List<Map>
  final int totalPrice;
  final String status;
  final Timestamp timestamp;
  final String address;
  final String phoneNumber;

  OrderEntity({
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

  // Chuyển thành Map để lưu vào Firestore
  Map<String, Object?> toDocument() {
    return {
      // Không cần lưu orderId vì nó là ID document
      'userId': userId,
      'userName': userName,
      'userEmail': userEmail,
      'items': items, // Lưu trực tiếp List<Map>
      'totalPrice': totalPrice,
      'status': status,
      'timestamp': timestamp,
      'address': address,
      'phoneNumber': phoneNumber,
    };
  }

  // Đọc từ Map lấy từ Firestore (DocumentSnapshot.data()) và ID
  static OrderEntity fromDocument(Map<String, dynamic> doc, String id) {
    // Chuyển đổi List<dynamic> (từ Firestore) thành List<Map<String, dynamic>>
    List<Map<String, dynamic>> itemsList = [];
    if (doc['items'] is List) {
      itemsList = List<Map<String, dynamic>>.from(
        (doc['items'] as List).map((item) => Map<String, dynamic>.from(item)),
      );
    }

    return OrderEntity(
      orderId: id, // Lấy ID từ document ID
      userId: doc['userId'] ?? '',
      userName: doc['userName'] ?? '',
      userEmail: doc['userEmail'] ?? '',
      items: itemsList, // Dùng list đã chuyển đổi
      totalPrice: (doc['totalPrice'] as num?)?.toInt() ?? 0,
      status: doc['status'] ?? 'unknown',
      // Lấy Timestamp, mặc định là now nếu null
      timestamp: doc['timestamp'] ?? Timestamp.now(),
      address: doc['address'] ?? '',
      phoneNumber: doc['phoneNumber'] ?? '',
    );
  }
}
