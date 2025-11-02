import 'dart:async';
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart' as fs; // Đã thêm as fs
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pizza_repository/pizza_repository.dart'; // Import CartItem qua đây
import 'package:user_repository/src/entities/entities.dart';
import 'package:user_repository/src/models/user.dart';
import 'package:user_repository/src/user_repo.dart';

class FirebaseUserRepo implements UserRepository {
  final FirebaseAuth _firebaseAuth;
  final fs.CollectionReference usersCollection = fs.FirebaseFirestore.instance
      .collection('users');
  final fs.CollectionReference orderCollection = fs.FirebaseFirestore.instance
      .collection('orders');
  FirebaseUserRepo({FirebaseAuth? firebaseAuth})
    : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  @override
  Stream<MyUser?> get user {
    return _firebaseAuth.authStateChanges().asyncMap((firebaseUser) async {
      if (firebaseUser == null) {
        return MyUser.empty;
      } else {
        final snapshot = await usersCollection.doc(firebaseUser.uid).get();
        final data =
            snapshot.data() as Map<String, dynamic>?; // ép kiểu an toàn
        if (data == null) {
          return MyUser.empty;
        }
        // Tạo một Map mới với userId
        final userData = Map<String, dynamic>.from(data);
        userData['userId'] = firebaseUser.uid;
        
        // Debug log
        log('FirebaseUser UID: ${firebaseUser.uid}');
        log('UserData: $userData');
        
        return MyUser.fromEntity(MyUserEntity.fromDocument(userData));
      }
    });
  }

  @override
  Future<void> signIn(String email, String password) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  @override
  Future<MyUser> signUp(MyUser myUser, String password) async {
    try {
      UserCredential user = await _firebaseAuth.createUserWithEmailAndPassword(
        email: myUser.email,
        password: password,
      );
      myUser.userId = user.user!.uid;
      return myUser;
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  @override
  Future<void> logOut() async {
    await _firebaseAuth.signOut();
  }

  @override
  Future<void> setUserData(MyUser myUser) async {
    try {
      await usersCollection
          .doc(myUser.userId)
          .set(myUser.toEntity().toDocument());
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  @override
  Stream<List<CartItem>> getCartItems(String userId) {
    // Trỏ đến subcollection 'cart' của user
    return usersCollection.doc(userId).collection('cart').snapshots().map((
      snapshot,
    ) {
      // Map từng document thành CartItem
      return snapshot.docs.map((doc) {
        return CartItem.fromMap(doc.data(), doc.id); // Truyền ID document vào
      }).toList();
    });
  }

  // Thêm món vào giỏ (hoặc cập nhật số lượng nếu đã có)
  @override
  Future<void> addToCart(String userId, CartItem item) async {
    try {
      final cartItemRef = usersCollection
          .doc(userId)
          .collection('cart')
          .doc(item.cartItemId); // Sử dụng cartItemId thay vì pizzaId
      final doc = await cartItemRef.get();

      if (doc.exists) {
        // Nếu cart item đã có trong giỏ -> tăng số lượng
        await cartItemRef.update({
          'quantity': fs.FieldValue.increment(
            item.quantity,
          ), // Tăng thêm số lượng mới
        });
      } else {
        // Nếu cart item chưa có -> tạo document mới
        await cartItemRef.set(item.toMap());
      }
    } catch (e) {
      log('Lỗi addToCart: ${e.toString()}');
      rethrow;
    }
  }

  // Cập nhật số lượng món hàng
  @override
  Future<void> updateCartItemQuantity(
    String userId,
    String cartItemId,
    int newQuantity,
  ) async {
    try {
      final cartItemRef = usersCollection
          .doc(userId)
          .collection('cart')
          .doc(cartItemId);
      if (newQuantity > 0) {
        // Cập nhật số lượng mới
        await cartItemRef.update({'quantity': newQuantity});
      } else {
        // Nếu số lượng <= 0 -> Xóa món hàng
        await cartItemRef.delete();
      }
    } catch (e) {
      log('Lỗi updateCartItemQuantity: ${e.toString()}');
      rethrow;
    }
  }

  // Xóa món hàng khỏi giỏ
  @override
  Future<void> removeFromCart(String userId, String cartItemId) async {
    try {
      await usersCollection
          .doc(userId)
          .collection('cart')
          .doc(cartItemId)
          .delete();
    } catch (e) {
      log('Lỗi removeFromCart: ${e.toString()}');
      rethrow;
    }
  }

  // Xóa sạch giỏ hàng (cần đọc tất cả rồi xóa từng cái hoặc dùng Cloud Function)
  @override
  Future<void> clearCart(String userId) async {
    try {
      final cartSnapshot = await usersCollection
          .doc(userId)
          .collection('cart')
          .get();
      // Dùng BatchedWrite để xóa hiệu quả hơn
      final batch = fs.FirebaseFirestore.instance.batch();
      for (final doc in cartSnapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    } catch (e) {
      log('Lỗi clearCart: ${e.toString()}');
      rethrow;
    }
  }

  @override
  Future<void> addOrder(Order order) async {
    try {
      // Dùng Order ID đã tạo để làm ID document
      await orderCollection
          .doc(order.orderId)
          .set(order.toEntity().toDocument());
    } catch (e) {
      log('Lỗi addOrder: ${e.toString()}');
      rethrow;
    }
  }

  // Lấy danh sách ID pizza yêu thích
  @override
  Stream<List<String>> getFavoritePizzaIds(String userId) {
    return usersCollection
        .doc(userId)
        .collection('favorites')
        .snapshots()
        .map((snapshot) {
      // Mỗi document là một pizzaId
      return snapshot.docs.map((doc) => doc.id).toList();
    });
  }

  // Thêm pizza vào danh sách yêu thích
  @override
  Future<void> addFavorite(String userId, String pizzaId) async {
    try {
      await usersCollection
          .doc(userId)
          .collection('favorites')
          .doc(pizzaId)
          .set({'timestamp': fs.FieldValue.serverTimestamp()});
    } catch (e) {
      log('Lỗi addFavorite: ${e.toString()}');
      rethrow;
    }
  }

  // Xóa pizza khỏi danh sách yêu thích
  @override
  Future<void> removeFavorite(String userId, String pizzaId) async {
    try {
      await usersCollection
          .doc(userId)
          .collection('favorites')
          .doc(pizzaId)
          .delete();
    } catch (e) {
      log('Lỗi removeFavorite: ${e.toString()}');
      rethrow;
    }
  }
}
