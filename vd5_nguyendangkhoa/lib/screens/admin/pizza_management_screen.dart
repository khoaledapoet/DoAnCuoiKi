import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// Import các BLoC và màn hình cần thiết
import 'package:vd5_nguyendangkhoa/screens/home/blocs/get_pizza_bloc.dart';
import 'package:vd5_nguyendangkhoa/screens/admin/blocs/pizza_edit/pizza_edit_bloc.dart';
import 'package:vd5_nguyendangkhoa/screens/admin/blocs/upload_picture/upload_picture_bloc.dart';
import 'package:vd5_nguyendangkhoa/screens/admin/add_edit_pizza_screen.dart';
// Import model Pizza và interface Repo
import 'package:pizza_repository/pizza_repository.dart';

class PizzaManagementScreen extends StatelessWidget {
  const PizzaManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Listener cho PizzaEditBloc (xử lý kết quả Xóa/Thêm/Sửa)
    return BlocListener<PizzaEditBloc, PizzaEditState>(
      listener: (context, state) {
        if (state.status == PizzaEditStatus.success) {
          // Hiển thị thông báo thành công
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Thao tác thành công!'),
              backgroundColor: Colors.green,
            ),
          );
          // Tải lại danh sách pizza
          context.read<GetPizzaBloc>().add(GetPizza());
        } else if (state.status == PizzaEditStatus.failure) {
          // Hiển thị thông báo lỗi
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Thao tác thất bại: ${state.error}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Scaffold(
        // 👇 THAY ĐỔI 1: Thêm màu nền cho Scaffold
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          // 👇 THAY ĐỔI 2: Tùy chỉnh AppBar
          backgroundColor: Colors.white, // Nền trắng
          foregroundColor: Colors.black, // Chữ và icon màu đen
          elevation: 0, // Bỏ bóng mờ
          title: const Text(
            'Quản lý Pizza',
            style: TextStyle(fontWeight: FontWeight.bold), // In đậm tiêu đề
          ),
          actions: [
            // Nút Thêm (Add)
            IconButton(
              // 👇 THAY ĐỔI 3: Dùng icon to, rõ ràng hơn
              icon: const Icon(Icons.add_circle, size: 28),
              onPressed: () {
                // Giữ nguyên logic điều hướng
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => MultiBlocProvider(
                      providers: [
                        BlocProvider.value(
                          value: context.read<PizzaEditBloc>(),
                        ),
                        BlocProvider(
                          create: (blocContext) => UploadPictureBloc(
                            pizzaRepo: blocContext.read<PizzaRepo>(),
                          ),
                        ),
                      ],
                      child: const AddEditPizzaScreen(),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(width: 8), // Thêm chút đệm
          ],
        ),
        // BlocBuilder cho PizzaEditBloc để hiển thị loading khi đang thao tác
        body: BlocBuilder<PizzaEditBloc, PizzaEditState>(
          builder: (context, editState) {
            // Nếu đang loading (Xóa/Thêm/Sửa) thì hiển thị loading
            if (editState.status == PizzaEditStatus.loading) {
              return const Center(child: CircularProgressIndicator());
            }

            // Nếu không, hiển thị danh sách pizza
            return BlocBuilder<GetPizzaBloc, GetPizzaState>(
              builder: (context, state) {
                if (state is GetPizzaLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is GetPizzaSuccess) {
                  // Hiển thị danh sách pizza
                  return ListView.builder(
                    // 👇 THAY ĐỔI 4: Thêm padding cho ListView
                    padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                    itemCount: state.pizzas.length,
                    itemBuilder: (context, index) {
                      final pizza = state.pizzas[index];
                      
                      // 👇 THAY ĐỔI 5: Thay thế hoàn toàn Card + ListTile
                      // Bằng một Card tùy chỉnh + Row
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2, // Thêm bóng mờ nhẹ
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
                            children: [
                              // --- 1. HÌNH ẢNH ---
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10.0),
                                child: Image.network(
                                  pizza.picture,
                                  width: 70,
                                  height: 70,
                                  fit: BoxFit.cover,
                                  // Hiển thị loading khi tải ảnh
                                  loadingBuilder: (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Container(
                                      width: 70,
                                      height: 70,
                                      color: Colors.grey[200],
                                      child: Center(
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.0,
                                          value: loadingProgress.expectedTotalBytes != null
                                              ? loadingProgress.cumulativeBytesLoaded /
                                                  loadingProgress.expectedTotalBytes!
                                              : null,
                                        ),
                                      ),
                                    );
                                  },
                                  // Hiển thị icon lỗi nếu không tải được ảnh
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      width: 70,
                                      height: 70,
                                      color: Colors.grey[200],
                                      child: const Icon(Icons.broken_image, color: Colors.grey),
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(width: 16),

                              // --- 2. TÊN VÀ GIÁ ---
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      pizza.name,
                                      style: const TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      '${pizza.price} ₫',
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8), // Đệm nhỏ trước nút

                              // --- 3. CÁC NÚT ---
                              // Nút Sửa (Edit)
                              IconButton(
                                icon: const Icon(
                                  Icons.edit,
                                  color: Colors.blueAccent, // Đổi màu
                                ),
                                onPressed: () {
                                  // *** GIỮ NGUYÊN LOGIC CŨ CỦA BẠN ***
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => MultiBlocProvider(
                                        providers: [
                                          BlocProvider.value(
                                            value: context.read<PizzaEditBloc>(),
                                          ),
                                          BlocProvider(
                                            create: (blocContext) => UploadPictureBloc(
                                              pizzaRepo: blocContext.read<PizzaRepo>(),
                                            ),
                                          ),
                                        ],
                                        child: AddEditPizzaScreen(pizza: pizza),
                                      ),
                                    ),
                                  );
                                },
                              ),
                              // Nút Xóa (Delete)
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.redAccent, // Đổi màu
                                ),
                                onPressed: () {
                                  // *** GIỮ NGUYÊN LOGIC CŨ CỦA BẠN ***
                                  showDialog(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                      title: const Text('Xác nhận xóa'),
                                      content: Text(
                                        'Bạn có chắc muốn xóa ${pizza.name}?',
                                      ),
                                      actions: [
                                        TextButton(
                                          child: const Text('Hủy'),
                                          onPressed: () => Navigator.of(ctx).pop(),
                                        ),
                                        TextButton(
                                          child: const Text('Xóa'),
                                          onPressed: () {
                                            context.read<PizzaEditBloc>().add(
                                                  DeletePizza(pizza.pizzaId),
                                                );
                                            Navigator.of(ctx).pop();
                                          },
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }
                if (state is GetPizzaFailure) {
                  return const Center(
                    child: Text('Không thể tải danh sách pizza.'),
                  );
                }
                // Trạng thái ban đầu hoặc không xác định
                return const Center(child: Text('Đang tải...'));
              },
            );
          },
        ),
      ),
    );
  }
}