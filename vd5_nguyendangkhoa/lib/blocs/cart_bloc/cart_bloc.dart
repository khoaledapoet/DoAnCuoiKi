import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart'; // Import Uuid để tạo orderId
import 'package:cloud_firestore/cloud_firestore.dart'
    as fs; // Import Firestore prefix nếu dùng Timestamp
// Import Repo và Models
import 'package:user_repository/user_repository.dart';
import 'package:pizza_repository/pizza_repository.dart';

part 'cart_event.dart';
part 'cart_state.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  final UserRepository _userRepository;
  StreamSubscription? _cartSubscription;

  CartBloc({required UserRepository userRepository})
      : _userRepository = userRepository,
        super(const CartState()) {
    // State ban đầu

    // Đăng ký các hàm xử lý event
    on<StartCartListener>(_onStartCartListener);
    on<_CartUpdated>(_onCartUpdated);
    on<AddCartItem>(_onAddCartItem);
    on<RemoveCartItem>(_onRemoveCartItem);
    on<UpdateCartQuantity>(_onUpdateCartQuantity);
    on<ClearCart>(_onClearCart);
    on<StopCartListener>(_onStopCartListener);
    // 👇 THÊM ĐĂNG KÝ CHO PlaceOrder
    on<PlaceOrder>(_onPlaceOrder);
  }

  // Bắt đầu lắng nghe stream giỏ hàng
  void _onStartCartListener(StartCartListener event, Emitter<CartState> emit) {
    emit(state.copyWith(status: CartStatus.loading));
    _cartSubscription?.cancel();
    _cartSubscription = _userRepository
        .getCartItems(event.userId)
        .listen(
          (cartItems) {
            add(_CartUpdated(cartItems));
          },
          onError: (error) {
            emit(
              state.copyWith(status: CartStatus.error, error: error.toString()),
            );
          },
        );
  }

  // Cập nhật state khi stream có dữ liệu mới
  void _onCartUpdated(_CartUpdated event, Emitter<CartState> emit) {
    emit(state.copyWith(status: CartStatus.loaded, items: event.cartItems));
  }

  // Thêm món vào giỏ
  Future<void> _onAddCartItem(
    AddCartItem event,
    Emitter<CartState> emit,
  ) async {
    try {
      await _userRepository.addToCart(event.userId, event.item);
    } catch (e) {
      emit(state.copyWith(status: CartStatus.error, error: e.toString()));
    }
  }

  // Xóa món khỏi giỏ
  Future<void> _onRemoveCartItem(
    RemoveCartItem event,
    Emitter<CartState> emit,
  ) async {
    try {
      await _userRepository.removeFromCart(event.userId, event.cartItemId);
    } catch (e) {
      emit(state.copyWith(status: CartStatus.error, error: e.toString()));
    }
  }

  // Cập nhật số lượng
  Future<void> _onUpdateCartQuantity(
    UpdateCartQuantity event,
    Emitter<CartState> emit,
  ) async {
    try {
      await _userRepository.updateCartItemQuantity(
        event.userId,
        event.cartItemId,
        event.newQuantity,
      );
    } catch (e) {
      emit(state.copyWith(status: CartStatus.error, error: e.toString()));
    }
  }

  // Xóa sạch giỏ
  Future<void> _onClearCart(ClearCart event, Emitter<CartState> emit) async {
    try {
      await _userRepository.clearCart(event.userId);
    } catch (e) {
      emit(state.copyWith(status: CartStatus.error, error: e.toString()));
    }
  }

  // 👇 THÊM HÀM XỬ LÝ ĐẶT HÀNG
  Future<void> _onPlaceOrder(PlaceOrder event, Emitter<CartState> emit) async {
    // Chỉ xử lý khi giỏ hàng đang ở trạng thái loaded và có hàng
    if (state.status != CartStatus.loaded || state.items.isEmpty) return;

    emit(state.copyWith(status: CartStatus.loading)); // Báo đang xử lý

    try {
      // --------------------- BẮT ĐẦU SỬA LỖI ---------------------
      
      // 1. Chuyển đổi List<CartItem> thành List<OrderItem>
      // Lỗi cũ là do bạn dùng: List<OrderItem>.from(state.items)
      final List<OrderItem> orderItems = state.items.map((cartItem) {
        return OrderItem(
          pizzaId: cartItem.pizzaId,
          pizzaName: cartItem.pizzaName,
          quantity: cartItem.quantity,
          price: cartItem.price,
          size: cartItem.size,
        );
      }).toList();

      // 2. Tạo đối tượng Order với danh sách ĐÃ CHUYỂN ĐỔI
      final newOrder = Order(
        orderId: const Uuid().v4(), // Tạo ID mới cho đơn hàng
        userId: event.userId,
        userName: event.userName,
        userEmail: event.userEmail,
        items: orderItems, // <-- ĐÃ SỬA! Giờ đây là List<OrderItem>
        totalPrice: state.totalPrice, // Lấy tổng tiền từ state
        status: 'pending', // Trạng thái ban đầu: chờ xác nhận
        timestamp: fs.Timestamp.now(), // Thời gian hiện tại
        address: event.address,
        phoneNumber: event.phoneNumber,
      );

      // --------------------- KẾT THÚC SỬA LỖI ---------------------

      // 2. Gọi hàm repo để lưu Order (Đổi thành bước 3)
      await _userRepository.addOrder(newOrder);

      // 3. Emit trạng thái orderPlaced với orderId (Đổi thành bước 4)
      emit(
        state.copyWith(
          status: CartStatus.orderPlaced,
          orderId: newOrder.orderId,
        ),
      );

      // 4. Nếu lưu thành công, xóa giỏ hàng (repo) (Đổi thành bước 5)
      await _userRepository.clearCart(event.userId);
      // Stream sẽ tự động cập nhật giỏ hàng về rỗng -> BLoC sẽ emit state loaded với items rỗng qua _onCartUpdated
    } catch (e) {
      // Nếu có lỗi, quay lại trạng thái loaded và báo lỗi
      emit(
        state.copyWith(
          status: CartStatus.loaded,
          error: "Đặt hàng thất bại: ${e.toString()}",
        ),
      );
    }
  }

  // Dừng lắng nghe stream
  void _onStopCartListener(StopCartListener event, Emitter<CartState> emit) {
    _cartSubscription?.cancel();
    _cartSubscription = null; // Gán lại null
    emit(const CartState()); // Reset về trạng thái ban đầu
  }

  // Override hàm close
  @override
  Future<void> close() {
    _cartSubscription?.cancel();
    return super.close();
  }
}