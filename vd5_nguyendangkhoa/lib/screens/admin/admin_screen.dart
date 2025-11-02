import 'package:flutter/cupertino.dart'; // <-- THÊM IMPORT NÀY cho icon
import 'package:flutter/material.dart';
import 'package:vd5_nguyendangkhoa/screens/admin/blocs/get_orders/get_orders_bloc.dart';
import 'package:vd5_nguyendangkhoa/screens/admin/pizza_management_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vd5_nguyendangkhoa/screens/admin/blocs/pizza_edit/pizza_edit_bloc.dart';
import 'package:pizza_repository/pizza_repository.dart';
import 'order_management_screen.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // --- PHẦN UI ĐÃ NÂNG CẤP ---
      backgroundColor: Theme.of(context).colorScheme.surface, // Màu nền xám nhạt
      appBar: AppBar(
        title: const Text('Bảng Điều Khiển'),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            const Text(
              'Quản lý Cửa hàng',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),

            // --- Card 1: Quản lý Pizza ---
            _buildAdminCard(
              context: context,
              icon: CupertinoIcons.flame_fill,
              color: Colors.orange,
              title: 'Quản lý Pizza',
              subtitle: 'Thêm, sửa, xóa sản phẩm pizza',
              onTap: () {
                // --- GIỮ NGUYÊN LOGIC BLOC CỦA BẠN ---
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return BlocProvider(
                        create: (context) => PizzaEditBloc(
                          pizzaRepo: context.read<PizzaRepo>(),
                        ),
                        child: const PizzaManagementScreen(),
                      );
                    },
                  ),
                );
              },
            ),

            const SizedBox(height: 16),

            // --- Card 2: Quản lý Đơn hàng ---
            _buildAdminCard(
              context: context,
              icon: CupertinoIcons.doc_text_fill

,
              color: Colors.blue,
              title: 'Quản lý Đơn hàng',
              subtitle: 'Xem và cập nhật trạng thái đơn hàng',
              onTap: () {
                // --- GIỮ NGUYÊN LOGIC BLOC CỦA BẠN ---
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return BlocProvider(
                        create: (context) => GetOrdersBloc(
                          pizzaRepo: context.read<PizzaRepo>(),
                        )..add(GetOrders()),
                        child: const OrderManagementScreen(),
                      );
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGET HELPER ĐỂ TẠO CARD ĐẸP ---
  Widget _buildAdminCard({
    required BuildContext context,
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: color,
            size: 28,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey.shade600,
          ),
        ),
        trailing: Icon(
          CupertinoIcons.chevron_right,
          color: Colors.grey.shade400,
          size: 20,
        ),
        onTap: onTap,
      ),
    );
  }
}