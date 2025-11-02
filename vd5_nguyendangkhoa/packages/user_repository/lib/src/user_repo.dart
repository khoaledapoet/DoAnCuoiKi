import 'models/models.dart';
import 'package:pizza_repository/pizza_repository.dart';

abstract class UserRepository {
  Stream<MyUser?> get user;

  Future<MyUser> signUp(MyUser myUser, String password);

  Future<void> setUserData(MyUser user);
  Future<void> signIn(String email, String password);
  Future<void> logOut();
  Stream<List<CartItem>> getCartItems(String userId);
  Future<void> addToCart(String userId, CartItem item);
  Future<void> updateCartItemQuantity(
    String userId,
    String cartItemId,
    int newQuantity,
  );
  Future<void> removeFromCart(String userId, String cartItemId);
  Future<void> clearCart(String userId);
  Future<void> addOrder(Order order);
  
  // Favorite methods
  Stream<List<String>> getFavoritePizzaIds(String userId);
  Future<void> addFavorite(String userId, String pizzaId);
  Future<void> removeFavorite(String userId, String pizzaId);
}
