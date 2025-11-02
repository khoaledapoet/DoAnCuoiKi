import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// Import BLoCs và Models (đảm bảo đường dẫn chính xác)
import '../../blocs/cart_bloc/cart_bloc.dart';
import '../../blocs/authentication_bloc/authentication_bloc.dart';
import '../order/order_success_screen.dart';

class CartScreen extends StatefulWidget {
  // Chuyển thành StatefulWidget
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  // Thêm State class
  // Controllers cho địa chỉ và SĐT
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>(); // Form key

  // Hàm helper để lấy userId
  String? _getCurrentUserId(BuildContext context) {
    final authState = context.read<AuthenticationBloc>().state;
    if (authState.status == AuthenticationStatus.authenticated) {
      return authState.user?.userId;
    }
    return null;
  }

  @override
  void dispose() {
    _addressController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Giỏ hàng của bạn'),
        actions: [
          // Nút xóa sạch giỏ hàng
          IconButton(
            tooltip: 'Xóa hết',
            icon: const Icon(CupertinoIcons.clear_circled),
            onPressed: () {
              // Lấy userId trực tiếp ở đây
              final userId = _getCurrentUserId(context);
              if (userId != null) {
                // Hiển thị dialog xác nhận
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Xác nhận'),
                    content: const Text('Bạn có chắc muốn xóa sạch giỏ hàng?'),
                    actions: [
                      TextButton(
                        child: const Text('Hủy'),
                        onPressed: () => Navigator.of(ctx).pop(),
                      ),
                      TextButton(
                        child: const Text('Xóa hết'),
                        onPressed: () {
                          // Gọi event ClearCart
                          context.read<CartBloc>().add(ClearCart(userId));
                          Navigator.of(ctx).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Đã xóa giỏ hàng.')),
                          );
                        },
                      ),
                    ],
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: BlocConsumer<CartBloc, CartState>(
        // Dùng BlocConsumer
        listener: (context, state) {
          // Hiển thị lỗi nếu đặt hàng thất bại
          if (state.status == CartStatus.error &&
              state.error != null &&
              state.error!.startsWith("Đặt hàng thất bại")) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error!),
                backgroundColor: Colors.red,
              ),
            );
          }

          // Điều hướng đến màn hình thành công khi đặt hàng thành công
          if (state.status == CartStatus.orderPlaced && state.orderId != null) {
            // Lưu tổng tiền trước khi navigate
            final totalPrice = state.totalPrice;
            final orderId = state.orderId!;

            // Navigate và xóa tất cả routes trước đó
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (_) => OrderSuccessScreen(
                  orderId: orderId,
                  totalPrice: totalPrice,
                ),
              ),
            );
          }
        },
        builder: (context, state) {
          // --- Xử lý các trạng thái BLoC ---
          if (state.status == CartStatus.loading ||
              state.status == CartStatus.initial) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.status == CartStatus.loaded && state.items.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    CupertinoIcons.shopping_cart,
                    size: 60,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Giỏ hàng của bạn đang trống!',
                    style: TextStyle(fontSize: 18),
                  ),
                ],
              ),
            );
          }

          if (state.status == CartStatus.loaded) {
            // --- Hiển thị danh sách Cart Items và Form ---
            return Form(
              // Bọc Column bằng Form
              key: _formKey,
              child: Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: state.items.length,
                      itemBuilder: (context, index) {
                        // ✅ Biến 'item' được sử dụng dưới đây
                        final item = state.items[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            leading: CircleAvatar(
                              radius: 30,
                              backgroundImage: NetworkImage(
                                item.picture,
                              ), // Sử dụng item.picture
                            ),
                            title: Text(
                              item.pizzaName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Size: ${item.size.label}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                Text(
                                  '${item.price} ₫',
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Nút giảm số lượng
                                IconButton(
                                  icon: const Icon(
                                    CupertinoIcons.minus_circle,
                                    color: Colors.redAccent,
                                  ),
                                  constraints: const BoxConstraints(),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                  ),
                                  onPressed: () {
                                    // Lấy userId bên trong onPressed
                                    final userId = _getCurrentUserId(context);
                                    if (userId != null) {
                                      final newQuantity =
                                          item.quantity -
                                          1; // Sử dụng item.quantity
                                      context.read<CartBloc>().add(
                                        UpdateCartQuantity(
                                          item.cartItemId,
                                          newQuantity,
                                          userId,
                                        ), // Sử dụng item.cartItemId
                                      );
                                    }
                                  },
                                ),
                                // Hiển thị số lượng
                                SizedBox(
                                  width: 24,
                                  child: Text(
                                    item.quantity
                                        .toString(), // Sử dụng item.quantity
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                // Nút tăng số lượng
                                IconButton(
                                  icon: const Icon(
                                    CupertinoIcons.plus_circle,
                                    color: Colors.green,
                                  ),
                                  constraints: const BoxConstraints(),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                  ),
                                  onPressed: () {
                                    // Lấy userId bên trong onPressed
                                    final userId = _getCurrentUserId(context);
                                    if (userId != null) {
                                      final newQuantity =
                                          item.quantity +
                                          1; // Sử dụng item.quantity
                                      context.read<CartBloc>().add(
                                        UpdateCartQuantity(
                                          item.cartItemId,
                                          newQuantity,
                                          userId,
                                        ), // Sử dụng item.cartItemId
                                      );
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  // --- Phần Nhập Thông Tin Giao Hàng ---
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8.0,
                    ),
                    child: TextFormField(
                      controller: _addressController,
                      decoration: const InputDecoration(
                        labelText: 'Địa chỉ giao hàng',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.location_on_outlined),
                      ),
                      validator: (value) => (value == null || value.isEmpty)
                          ? 'Vui lòng nhập địa chỉ'
                          : null,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8.0,
                    ),
                    child: TextFormField(
                      controller: _phoneController,
                      decoration: const InputDecoration(
                        labelText: 'Số điện thoại',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.phone_outlined),
                      ),
                      keyboardType: TextInputType.phone,
                      validator: (value) => (value == null || value.isEmpty)
                          ? 'Vui lòng nhập SĐT'
                          : null,
                    ),
                  ),

                  // --- Phần Tổng tiền và Đặt hàng ---
                  Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 5,
                          offset: const Offset(0, -2),
                        ),
                      ],
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
                    ),
                    child: SafeArea(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Tổng cộng (${state.totalQuantity} món):', // Dùng getter từ state
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                              ),
                              Text(
                                '${state.totalPrice} ₫', // Dùng getter từ state
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          ElevatedButton.icon(
                            icon: const Icon(
                              CupertinoIcons.arrow_right_circle_fill,
                            ),
                            label: const Text('Đặt hàng'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                              textStyle: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            onPressed: state.items.isEmpty
                                ? null
                                : () {
                                    // Disable nút nếu giỏ hàng trống
                                    // Kiểm tra Form hợp lệ
                                    if (_formKey.currentState!.validate()) {
                                      // Lấy thông tin user hiện tại
                                      final authState = context
                                          .read<AuthenticationBloc>()
                                          .state;
                                      if (authState.status ==
                                              AuthenticationStatus
                                                  .authenticated &&
                                          authState.user != null) {
                                        final currentUser = authState.user!;
                                        final address = _addressController.text;
                                        final phone = _phoneController.text;

                                        // Gửi event PlaceOrder đến CartBloc
                                        context.read<CartBloc>().add(
                                          PlaceOrder(
                                            userId: currentUser.userId,
                                            userName: currentUser.name,
                                            userEmail: currentUser.email,
                                            address:
                                                address, // Lấy từ controller
                                            phoneNumber:
                                                phone, // Lấy từ controller
                                          ),
                                        );
                                      } else {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Lỗi: Không tìm thấy người dùng!',
                                            ),
                                          ),
                                        );
                                      }
                                    } // Kết thúc if form valid
                                  },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          // Hiển thị lỗi
          if (state.status == CartStatus.error) {
            return Center(child: Text('Lỗi tải giỏ hàng: ${state.error}'));
          }

          // Trường hợp khác
          return const Center(child: Text('Đã có lỗi xảy ra.'));
        },
      ),
    );
  }
}
