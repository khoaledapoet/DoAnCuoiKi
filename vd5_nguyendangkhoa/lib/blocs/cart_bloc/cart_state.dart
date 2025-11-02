part of 'cart_bloc.dart'; // Nối với file BLoC

// Trạng thái chung của giỏ hàng
enum CartStatus { initial, loading, loaded, error, orderPlaced }

class CartState extends Equatable {
  final CartStatus status;
  final List<CartItem> items; // Danh sách món hàng hiện tại
  final String? error;
  final String? orderId; // ID của đơn hàng vừa đặt

  const CartState({
    this.status = CartStatus.initial,
    this.items = const <CartItem>[],
    this.error,
    this.orderId,
  });

  // Tính toán phụ trợ (getter)
  int get totalQuantity => items.fold(0, (sum, item) => sum + item.quantity);
  int get totalPrice =>
      items.fold(0, (sum, item) => sum + (item.price * item.quantity));

  CartState copyWith({
    CartStatus? status,
    List<CartItem>? items,
    String? error,
    String? orderId,
  }) {
    return CartState(
      status: status ?? this.status,
      items: items ?? this.items,
      error: error ?? this.error, // Giữ lỗi cũ nếu không có lỗi mới
      orderId: orderId ?? this.orderId,
    );
  }

  @override
  List<Object?> get props => [status, items, error, orderId];
}
