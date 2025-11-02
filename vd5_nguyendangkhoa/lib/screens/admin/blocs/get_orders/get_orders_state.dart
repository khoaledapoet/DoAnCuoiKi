part of 'get_orders_bloc.dart'; // Nối với file BLoC

// Định nghĩa các trạng thái
enum GetOrdersStatus { initial, loading, success, failure }

class GetOrdersState extends Equatable {
  final GetOrdersStatus status;
  final List<Order> orders; // Danh sách đơn hàng khi thành công
  final String? error; // Thông báo lỗi khi thất bại

  const GetOrdersState({
    this.status = GetOrdersStatus.initial,
    this.orders = const <Order>[], // Mặc định là list rỗng
    this.error,
  });

  // Hàm copyWith
  GetOrdersState copyWith({
    GetOrdersStatus? status,
    List<Order>? orders,
    String? error,
  }) {
    return GetOrdersState(
      status: status ?? this.status,
      orders: orders ?? this.orders,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [status, orders, error];
}
