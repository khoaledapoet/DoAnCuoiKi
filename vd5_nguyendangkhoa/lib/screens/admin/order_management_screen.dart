import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
// Import BLoC và Model
import 'blocs/get_orders/get_orders_bloc.dart';
// 👇 THAY ĐỔI 1: Import màn hình chi tiết mới
import 'order_detail_screen.dart';

class OrderManagementScreen extends StatelessWidget {
  const OrderManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Định dạng ngày giờ
    final DateFormat formatter = DateFormat('dd/MM/yyyy HH:mm');

    return Scaffold(
      // 👇 THAY ĐỔI 2: Chỉnh lại AppBar và nền cho đẹp hơn
      backgroundColor: Colors.grey[100], // Nền xám nhạt
      appBar: AppBar(
        title: const Text(
          'Quản lý Đơn hàng',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: BlocBuilder<GetOrdersBloc, GetOrdersState>(
        builder: (context, state) {
          // Hiển thị loading
          if (state.status == GetOrdersStatus.loading ||
              state.status == GetOrdersStatus.initial) {
            return const Center(child: CircularProgressIndicator());
          }
          // Hiển thị danh sách khi thành công
          if (state.status == GetOrdersStatus.success) {
            // Kiểm tra nếu không có đơn hàng
            if (state.orders.isEmpty) {
              return const Center(child: Text('Chưa có đơn hàng nào.'));
            }
            // Hiển thị ListView
            return ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
              itemCount: state.orders.length,
              itemBuilder: (context, index) {
                final order = state.orders[index];
                final totalItems = order.items.fold<int>(
                  0,
                  (sum, item) => sum + item.quantity,
                );

                return Card(
                  // 👇 THAY ĐỔI 3: Thêm bo góc và margin
                  margin:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2, // Thêm bóng mờ nhẹ
                  child: ListTile(
                    // Icon dựa trên trạng thái đơn hàng
                    leading: CircleAvatar(
                      backgroundColor: (order.status == 'completed'
                              ? Colors.green
                              : order.status == 'cancelled'
                                  ? Colors.red
                                  : Colors.orange)
                          .withOpacity(0.15), // Nền màu nhạt
                      child: Icon(
                        order.status == 'completed'
                            ? Icons.check_circle
                            : order.status == 'delivering'
                                ? Icons.local_shipping
                                : order.status == 'cancelled'
                                    ? Icons.cancel
                                    : Icons.pending_actions,
                        color: order.status == 'completed'
                            ? Colors.green
                            : order.status == 'cancelled'
                                ? Colors.red
                                : Colors.orange,
                        size: 26,
                      ),
                    ),
                    title: Text(
                      'Đơn hàng #${order.orderId.substring(0, 6)}... (${order.userName})',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Trạng thái: ${order.status}'),
                        Text(
                          'Thời gian: ${formatter.format(order.timestamp.toDate())}',
                        ),
                        Text(
                          'Tổng tiền: ${order.totalPrice} ₫ ($totalItems món)',
                        ),
                      ],
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                    isThreeLine: true,
                    // 👇 THAY ĐỔI 4: Thêm sự kiện onTap vào ListTile
                    onTap: () {
                      // Điều hướng đến màn hình Chi tiết đơn hàng
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => OrderDetailScreen(order: order),
                        ),
                      );
                    },
                  ),
                );
              },
            );
          }
          // Hiển thị lỗi
          if (state.status == GetOrdersStatus.failure) {
            return Center(child: Text('Lỗi tải đơn hàng: ${state.error}'));
          }
          // Trường hợp khác
          return const Center(child: Text('Trạng thái không xác định.'));
        },
      ),
    );
  }
}
