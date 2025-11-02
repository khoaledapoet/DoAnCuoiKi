part of 'cart_bloc.dart'; // Nối với file BLoC

abstract class CartEvent extends Equatable {
  const CartEvent();

  @override
  List<Object?> get props => [];
}

// Event để bắt đầu lắng nghe giỏ hàng (khi user đăng nhập)
class StartCartListener extends CartEvent {
  final String userId;
  const StartCartListener(this.userId);
  @override
  List<Object> get props => [userId];
}

// Event khi có cập nhật từ Stream (dùng nội bộ trong BLoC)
class _CartUpdated extends CartEvent {
  final List<CartItem> cartItems;
  const _CartUpdated(this.cartItems);
  @override
  List<Object> get props => [cartItems];
}

// Event khi người dùng thêm món vào giỏ
class AddCartItem extends CartEvent {
  final CartItem item;
  // Chúng ta cần userId ở đây để gọi repo
  final String userId;
  const AddCartItem(this.item, this.userId);
  @override
  List<Object> get props => [item, userId];
}

// Event khi người dùng xóa món khỏi giỏ
class RemoveCartItem extends CartEvent {
  final String cartItemId; // Đổi từ pizzaId sang cartItemId
  final String userId;
  const RemoveCartItem(this.cartItemId, this.userId);
  @override
  List<Object> get props => [cartItemId, userId];
}

// Event khi người dùng cập nhật số lượng
class UpdateCartQuantity extends CartEvent {
  final String cartItemId; // Đổi từ pizzaId sang cartItemId
  final int newQuantity;
  final String userId;
  const UpdateCartQuantity(this.cartItemId, this.newQuantity, this.userId);
  @override
  List<Object> get props => [cartItemId, newQuantity, userId];
}

// Event để xóa sạch giỏ hàng
class ClearCart extends CartEvent {
  final String userId;
  const ClearCart(this.userId);
  @override
  List<Object> get props => [userId];
}

// Event để dừng lắng nghe giỏ hàng (khi user đăng xuất)
class StopCartListener extends CartEvent {}

// 👇 THÊM CLASS NÀY VÀO CUỐI FILE
class PlaceOrder extends CartEvent {
  final String userId;
  final String userName; // Cần thông tin user để lưu vào Order
  final String userEmail; // Cần thông tin user
  final String address; // Cần địa chỉ giao hàng
  final String phoneNumber; // Cần số điện thoại

  const PlaceOrder({
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.address,
    required this.phoneNumber,
  });

  @override
  List<Object> get props => [userId, userName, userEmail, address, phoneNumber];
}
