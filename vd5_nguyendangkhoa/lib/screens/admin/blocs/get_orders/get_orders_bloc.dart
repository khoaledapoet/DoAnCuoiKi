import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
// Import Order model và PizzaRepo
import 'package:pizza_repository/pizza_repository.dart';

part 'get_orders_event.dart';
part 'get_orders_state.dart';

class GetOrdersBloc extends Bloc<GetOrdersEvent, GetOrdersState> {
  final PizzaRepo _pizzaRepo; // Sử dụng PizzaRepo

  GetOrdersBloc({required PizzaRepo pizzaRepo})
    : _pizzaRepo = pizzaRepo,
      super(const GetOrdersState()) {
    // Đăng ký xử lý sự kiện GetOrders
    on<GetOrders>(_onGetOrders);
  }

  // Hàm xử lý khi sự kiện GetOrders được gọi
  Future<void> _onGetOrders(
    GetOrders event,
    Emitter<GetOrdersState> emit,
  ) async {
    // 1. Phát ra state Loading
    emit(state.copyWith(status: GetOrdersStatus.loading));
    try {
      // 2. Gọi hàm getOrders từ repository
      final orders = await _pizzaRepo.getOrders();

      // 3. Phát ra state Success với danh sách đơn hàng
      emit(state.copyWith(status: GetOrdersStatus.success, orders: orders));
    } catch (e) {
      // 4. Nếu lỗi, phát ra state Failure
      emit(
        state.copyWith(status: GetOrdersStatus.failure, error: e.toString()),
      );
    }
  }
}
