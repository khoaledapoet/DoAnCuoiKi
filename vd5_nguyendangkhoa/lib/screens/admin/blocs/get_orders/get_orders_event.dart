part of 'get_orders_bloc.dart'; // Nối với file BLoC

abstract class GetOrdersEvent extends Equatable {
  const GetOrdersEvent();

  @override
  List<Object> get props => [];
}

// Event duy nhất để yêu cầu tải danh sách đơn hàng
class GetOrders extends GetOrdersEvent {}
