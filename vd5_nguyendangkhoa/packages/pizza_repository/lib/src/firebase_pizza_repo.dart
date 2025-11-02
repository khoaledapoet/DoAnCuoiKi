import 'dart:developer';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart'
    hide Order; // ⚠️ ẨN Order của Firestore
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:pizza_repository/pizza_repository.dart';

class FirebasePizzaRepo implements PizzaRepo {
  // 🔹 Khai báo collection Firestore
  final pizzaCollection = FirebaseFirestore.instance.collection('pizzas');
  final orderCollection = FirebaseFirestore.instance.collection('orders');

  // 🔸 Lấy danh sách pizza
  @override
  Future<List<Pizza>> getPizzas() async {
    try {
      final querySnapshot = await pizzaCollection.get();

      return querySnapshot.docs.map((docSnapshot) {
        final data = docSnapshot.data();
        final id = docSnapshot.id;
        return Pizza.fromEntity(PizzaEntity.fromDocument(data, id));
      }).toList();
    } catch (e, stack) {
      log("🔥 Lỗi lấy pizzas: $e");
      log(stack.toString());
      rethrow;
    }
  }

  // 🔸 Xóa pizza
  @override
  Future<void> deletePizza(String pizzaId) async {
    try {
      await pizzaCollection.doc(pizzaId).delete();
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  // 🔸 Thêm pizza
  @override
  Future<void> addPizza(Pizza pizza) async {
    try {
      await pizzaCollection
          .doc(pizza.pizzaId)
          .set(pizza.toEntity().toDocument());
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  // 🔸 Cập nhật pizza
  @override
  Future<void> updatePizza(Pizza pizza) async {
    try {
      await pizzaCollection
          .doc(pizza.pizzaId)
          .update(pizza.toEntity().toDocument());
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  // 🔸 Upload ảnh lên Cloudinary
  @override
  Future<String> uploadImageBytes(Uint8List fileBytes, String fileName) async {
    final cloudinary = CloudinaryPublic(
      'dguved0x3', // Cloud name của em
      'flutter_uploads', // Upload preset
      cache: false,
    );

    try {
      print('☁️ [Repo] Uploading to Cloudinary: $fileName');

      final response = await cloudinary.uploadFile(
        CloudinaryFile.fromBytesData(fileBytes, identifier: fileName),
      );

      if (response.secureUrl.isNotEmpty) {
        print('✅ [Repo] Cloudinary Upload Success: ${response.secureUrl}');
        return response.secureUrl;
      } else {
        throw Exception('❌ Cloudinary upload failed: no URL returned');
      }
    } catch (e) {
      log('❌ [Repo] Cloudinary Upload Exception: ${e.toString()}');
      rethrow;
    }
  }

  // 🔸 Lấy danh sách đơn hàng (Order)
  @override
  Future<List<Order>> getOrders() async {
    try {
      final querySnapshot = await orderCollection
          .orderBy('timestamp', descending: true)
          .get();

      return querySnapshot.docs.map((docSnapshot) {
        final data = docSnapshot.data();
        final id = docSnapshot.id;
        return Order.fromEntity(OrderEntity.fromDocument(data, id));
      }).toList();
    } catch (e, stack) {
      log("🔥 Lỗi lấy orders: $e");
      log(stack.toString());
      rethrow;
    }
  }
}
