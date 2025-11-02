import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// Dòng này ĐÚNG, vì nó đã sửa lỗi 'Undefined class Order'
import 'package:pizza_repository/pizza_repository.dart';

class OrderDetailScreen extends StatelessWidget {
  final Order order;
  const OrderDetailScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final DateFormat formatter = DateFormat('dd/MM/yyyy HH:mm');
    final NumberFormat currencyFormatter = NumberFormat.decimalPattern('vi_VN');

    final totalItems = order.items.fold<int>(
      0,
      (sum, item) => sum + item.quantity,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('Chi tiết Đơn hàng'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      backgroundColor: Colors.grey[100],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- 1. THÔNG TIN KHÁCH HÀNG ---
            Text(
              'Thông tin Khách hàng',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 1,
              child: Column(
                children: [
                  _buildDetailRow(
                    context,
                    icon: Icons.person_outline,
                    title: 'Tên khách hàng',
                    value: order.userName,
                  ),
                  _buildDetailRow(
                    context,
                    icon: Icons.email_outlined,
                    title: 'Email',
                    // ĐÃ SỬA: Lỗi 'dead_code' đã hết
                    value: order.userEmail,
                  ),
                  _buildDetailRow(
                    context,
                    icon: Icons.phone_outlined,
                    title: 'Số điện thoại',
                    // 👇 ĐÃ SỬA: Lỗi 'userPhone' đã hết
                    // Tên biến đúng là 'phoneNumber'
                    value: order.phoneNumber,
                  ),
                   _buildDetailRow(
                    context,
                    icon: Icons.home_outlined,
                    title: 'Địa chỉ',
                    // 👇 ĐÃ THÊM: Thêm địa chỉ
                    value: order.address,
                    isLast: true, // Đây là dòng cuối
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // --- 2. THÔNG TIN ĐƠN HÀNG ---
            // (Phần này không có lỗi)
            Text(
              'Thông tin Đơn hàng',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 1,
              child: Column(
                children: [
                  _buildDetailRow(
                    context,
                    icon: Icons.receipt_long_outlined,
                    title: 'Mã đơn hàng',
                    value: order.orderId,
                  ),
                  _buildDetailRow(
                    context,
                    icon: Icons.calendar_today_outlined,
                    title: 'Thời gian đặt',
                    value: formatter.format(order.timestamp.toDate()),
                  ),
                  _buildDetailRow(
                    context,
                    icon: Icons.local_shipping_outlined,
                    title: 'Trạng thái',
                    value: order.status,
                  ),
                  _buildDetailRow(
                    context,
                    icon: Icons.shopping_bag_outlined,
                    title: 'Số lượng món',
                    value: '$totalItems món',
                  ),
                  _buildDetailRow(
                    context,
                    icon: Icons.attach_money_outlined,
                    title: 'Tổng tiền',
                    value: '${currencyFormatter.format(order.totalPrice)} ₫',
                    isLast: true,
                  ),
                ],
              ),
            ),
             const SizedBox(height: 24),

            // --- 3. DANH SÁCH MÓN (ĐÃ SỬA HẾT LỖI) ---
            Text(
              'Danh sách Món',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 1,
              child: ListView.separated(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: order.items.length,
                separatorBuilder: (context, index) => Divider(
                  height: 1,
                  thickness: 1,
                  indent: 16,
                  endIndent: 16,
                  color: Colors.grey[200],
                ),
                itemBuilder: (context, index) {
                  final item = order.items[index];
                  
                  // 👇 ĐÃ SỬA (1):
                  // Tên biến đúng là 'price'
                  final itemTotalPrice = item.price * item.quantity;

                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    // 👇 ĐÃ SỬA (2):
                    // Model 'OrderItem' không có trường 'picture' (ảnh).
                    // Tạm thời thay bằng icon.
                    leading: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.local_pizza_outlined,
                        color: Colors.grey[600],
                      ),
                    ),
                    title: Text(
                      // 👇 ĐÃ SỬA (3):
                      // Tên biến đúng là 'pizzaName'
                      item.pizzaName, 
                      style: TextStyle(fontWeight: FontWeight.bold)
                    ),
                    subtitle: Text('Số lượng: ${item.quantity}'),
                    trailing: Text(
                      '${currencyFormatter.format(itemTotalPrice)} ₫',
                      style: TextStyle(color: Colors.black87, fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget TÁCH RỜI
  Widget _buildDetailRow(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    bool isLast = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(
                bottom: BorderSide(color: Colors.grey[200]!),
              ),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey[700], size: 20),
          const SizedBox(width: 16),
          Text(title, style: TextStyle(color: Colors.grey[700], fontSize: 15)),
          const Spacer(),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }
}

