import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p; // Đổi tên để tránh trùng
import 'package:pizza_repository/pizza_repository.dart';
import 'package:uuid/uuid.dart';
import 'package:vd5_nguyendangkhoa/screens/admin/blocs/pizza_edit/pizza_edit_bloc.dart';
import 'package:vd5_nguyendangkhoa/screens/admin/blocs/upload_picture/upload_picture_bloc.dart';

import 'package:vd5_nguyendangkhoa/screens/home/blocs/get_pizza_bloc.dart';

class AddEditPizzaScreen extends StatefulWidget {
  // Nhận pizza object (nếu là Sửa) hoặc null (nếu là Thêm)
  final Pizza? pizza;

  const AddEditPizzaScreen({super.key, this.pizza});

  @override
  State<AddEditPizzaScreen> createState() => _AddEditPizzaScreenState();
}

class _AddEditPizzaScreenState extends State<AddEditPizzaScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  late TextEditingController _nameController;
  late TextEditingController _descController;
  late TextEditingController _priceController;
  late TextEditingController _discountController;
  late TextEditingController _calorieController;
  late TextEditingController _proteinController;
  late TextEditingController _fatController;
  late TextEditingController _carbsController;

  // State variables
  bool _isEditMode = false;
  bool _isVeg = false;
  int _spicyLevel = 1;
  String? _imageUrl; // Lưu URL ảnh (từ pizza cũ hoặc mới upload)
  bool _isLoading = false; // Trạng thái loading chung
  bool _isUploading = false; // Trạng thái đang upload ảnh

  @override
  void initState() {
    super.initState();
    _isEditMode = widget.pizza != null;

    // Khởi tạo controller và state variables từ widget.pizza nếu là Sửa
    _nameController = TextEditingController(
      text: _isEditMode ? widget.pizza!.name : '',
    );
    _descController = TextEditingController(
      text: _isEditMode ? widget.pizza!.description : '',
    );
    _priceController = TextEditingController(
      text: _isEditMode ? widget.pizza!.price.toString() : '',
    );
    _discountController = TextEditingController(
      text: _isEditMode ? widget.pizza!.discount.toString() : '',
    );

    _isVeg = _isEditMode ? widget.pizza!.isVeg : false;
    _spicyLevel = _isEditMode ? widget.pizza!.spicy : 1;
    _imageUrl = _isEditMode ? widget.pizza!.picture : null;

    // Khởi tạo macros controllers
    _calorieController = TextEditingController(
      text: _isEditMode ? widget.pizza!.macros.calories.toString() : '',
    );
    _proteinController = TextEditingController(
      text: _isEditMode ? widget.pizza!.macros.proteins.toString() : '',
    );
    _fatController = TextEditingController(
      text: _isEditMode ? widget.pizza!.macros.fat.toString() : '',
    );
    _carbsController = TextEditingController(
      text: _isEditMode ? widget.pizza!.macros.carbs.toString() : '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _priceController.dispose();
    _discountController.dispose();
    _calorieController.dispose();
    _proteinController.dispose();
    _fatController.dispose();
    _carbsController.dispose();
    super.dispose();
  }

  // Hàm chọn và upload ảnh (giữ nguyên logic upload ngay)
  Future<void> _pickAndUploadImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      maxHeight: 1000,
      maxWidth: 1000,
    );
    if (image != null && mounted) {
      setState(() {
        _isUploading = true;
      }); // Bắt đầu upload
      final bytes = await image.readAsBytes();
      final imageName = p.basename(image.path); // Dùng p.basename
      // Gọi UploadPictureBloc
      context.read<UploadPictureBloc>().add(UploadPicture(bytes, imageName));
    }
  }

  // Hàm lưu form
  void _saveForm() {
    if (_formKey.currentState!.validate() && _imageUrl != null) {
      final macros = Macros(
        calories: int.tryParse(_calorieController.text) ?? 0,
        proteins: int.tryParse(_proteinController.text) ?? 0,
        fat: int.tryParse(_fatController.text) ?? 0,
        carbs: int.tryParse(_carbsController.text) ?? 0,
      );

      final pizzaData = Pizza(
        pizzaId: _isEditMode ? widget.pizza!.pizzaId : const Uuid().v4(),
        name: _nameController.text,
        description: _descController.text,
        price: int.tryParse(_priceController.text) ?? 0,
        discount: int.tryParse(_discountController.text) ?? 0,
        picture: _imageUrl!, // Lấy URL ảnh đã upload hoặc ảnh cũ
        isVeg: _isVeg,
        spicy: _spicyLevel,
        macros: macros,
      );

      // Gọi PizzaEditBloc
      if (_isEditMode) {
        context.read<PizzaEditBloc>().add(UpdatePizza(pizzaData));
      } else {
        context.read<PizzaEditBloc>().add(AddPizza(pizzaData));
      }
    } else if (_imageUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chọn ảnh cho pizza!'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Listener cho PizzaEditBloc (lưu thành công/thất bại)
    return BlocListener<PizzaEditBloc, PizzaEditState>(
      listener: (context, state) {
        if (state.status == PizzaEditStatus.loading) {
          setState(() {
            _isLoading = true;
          });
        } else if (state.status == PizzaEditStatus.success) {
          setState(() {
            _isLoading = false;
          });
          // Tải lại danh sách và quay về
          context.read<GetPizzaBloc>().add(GetPizza());
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                _isEditMode ? 'Cập nhật thành công!' : 'Thêm pizza thành công!',
              ),
              backgroundColor: Colors.green,
            ),
          );
        } else if (state.status == PizzaEditStatus.failure) {
          setState(() {
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Lỗi: ${state.error}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      // Listener cho UploadPictureBloc (upload ảnh thành công/thất bại)
      child: BlocListener<UploadPictureBloc, UploadPictureState>(
        listener: (context, state) {
          if (state is UploadPictureSuccess) {
            setState(() {
              _imageUrl = state.url; // Cập nhật URL ảnh
              _isUploading = false; // Kết thúc upload
            });
          } else if (state is UploadPictureFailure) {
            setState(() {
              _isUploading = false;
            }); // Kết thúc upload (lỗi)
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Tải ảnh lên thất bại!'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text(_isEditMode ? 'Sửa Pizza' : 'Thêm Pizza'),
            actions: [
              // Nút Lưu - Disable khi đang loading hoặc upload
              IconButton(
                icon: const Icon(Icons.save),
                onPressed: (_isLoading || _isUploading) ? null : _saveForm,
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            // Hiển thị loading nếu đang lưu hoặc upload
            child: (_isLoading || _isUploading)
                ? const Center(child: CircularProgressIndicator())
                : Form(
                    key: _formKey,
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start, // Căn trái
                        children: [
                          // --- Phần hiển thị/chọn ảnh ---
                          Center(
                            // Đặt ảnh vào giữa
                            child: InkWell(
                              borderRadius: BorderRadius.circular(20),
                              onTap: _pickAndUploadImage,
                              child: Container(
                                width: 200, // Thu nhỏ ảnh
                                height: 200,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  color: Colors.grey[200],
                                  border: Border.all(color: Colors.grey),
                                ),
                                child: _imageUrl != null
                                    ? ClipRRect(
                                        // Bo góc ảnh
                                        borderRadius: BorderRadius.circular(19),
                                        child: Image.network(
                                          _imageUrl!,
                                          fit: BoxFit.cover,
                                          // Hiển thị loading khi tải ảnh
                                          loadingBuilder:
                                              (context, child, progress) {
                                                if (progress == null)
                                                  return child;
                                                return const Center(
                                                  child:
                                                      CircularProgressIndicator(),
                                                );
                                              },
                                          errorBuilder:
                                              (context, error, stack) =>
                                                  const Center(
                                                    child: Icon(
                                                      Icons.broken_image,
                                                      color: Colors.grey,
                                                    ),
                                                  ),
                                        ),
                                      )
                                    : const Column(
                                        // Placeholder khi chưa có ảnh
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            CupertinoIcons.photo,
                                            size: 50,
                                            color: Colors.grey,
                                          ),
                                          SizedBox(height: 8),
                                          Text(
                                            "Chọn ảnh",
                                            style: TextStyle(
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // --- Các trường nhập liệu ---
                          TextFormField(
                            controller: _nameController,
                            decoration: const InputDecoration(
                              labelText: 'Tên Pizza',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) =>
                                (value == null || value.isEmpty)
                                ? 'Không được bỏ trống'
                                : null,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _descController,
                            decoration: const InputDecoration(
                              labelText: 'Mô tả',
                              border: OutlineInputBorder(),
                            ),
                            maxLines: 3,
                            validator: (value) =>
                                (value == null || value.isEmpty)
                                ? 'Không được bỏ trống'
                                : null,
                          ),
                          const SizedBox(height: 16),
                          Row(
                            // Giá và Giảm giá trên cùng hàng
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _priceController,
                                  decoration: const InputDecoration(
                                    labelText: 'Giá (₫)',
                                    border: OutlineInputBorder(),
                                  ),
                                  keyboardType: TextInputType.number,
                                  validator: (value) {
                                    if (value == null || value.isEmpty)
                                      return 'Không được bỏ trống';
                                    if (int.tryParse(value) == null)
                                      return 'Phải là số';
                                    return null;
                                  },
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: TextFormField(
                                  controller: _discountController,
                                  decoration: const InputDecoration(
                                    labelText: 'Giảm giá (%)',
                                    border: OutlineInputBorder(),
                                  ),
                                  keyboardType: TextInputType.number,
                                  validator: (value) {
                                    if (value == null || value.isEmpty)
                                      return 'Không được bỏ trống';
                                    final discount = int.tryParse(value);
                                    if (discount == null) return 'Phải là số';
                                    if (discount < 0 || discount > 100)
                                      return 'Từ 0-100';
                                    return null;
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // --- Checkbox IsVeg ---
                          Row(
                            children: [
                              Checkbox(
                                value: _isVeg,
                                onChanged: (value) =>
                                    setState(() => _isVeg = value!),
                              ),
                              const Text('Là món chay?'),
                            ],
                          ),
                          const SizedBox(height: 10),

                          // --- Chọn độ cay ---
                          const Text('Độ cay:'),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [1, 2, 3]
                                .map(
                                  (level) => Padding(
                                    padding: const EdgeInsets.only(right: 8.0),
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(100),
                                      onTap: () =>
                                          setState(() => _spicyLevel = level),
                                      child: Ink(
                                        width: 30,
                                        height: 30,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: _spicyLevel == level
                                              ? Border.all(
                                                  width: 2,
                                                  color: Theme.of(
                                                    context,
                                                  ).primaryColor,
                                                )
                                              : null,
                                          color: level == 1
                                              ? Colors.green
                                              : (level == 2
                                                    ? Colors.orange
                                                    : Colors.red),
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                          const SizedBox(height: 16),

                          // --- Nhập Macros ---
                          const Text('Macros:'),
                          const SizedBox(height: 10),
                          Row(
                            // Đặt các ô nhập Macro trên cùng hàng
                            children: [
                              Expanded(
                                child: MyMacroWidget(
                                  title: "Cal",
                                  icon: FontAwesomeIcons.fire,
                                  controller: _calorieController,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: MyMacroWidget(
                                  title: "Pro",
                                  icon: FontAwesomeIcons.dumbbell,
                                  controller: _proteinController,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: MyMacroWidget(
                                  title: "Fat",
                                  icon: FontAwesomeIcons.oilWell,
                                  controller: _fatController,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: MyMacroWidget(
                                  title: "Carb",
                                  icon: FontAwesomeIcons.breadSlice,
                                  controller: _carbsController,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 30), // Khoảng trống dưới cùng
                        ],
                      ),
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

// ---- Cần tạo Widget MyMacroWidget này ----
// Bạn có thể copy từ code gốc của video hoặc tạo widget tương tự
// Ví dụ đơn giản:
class MyMacroWidget extends StatelessWidget {
  final String title;
  final IconData icon;
  final TextEditingController controller;

  const MyMacroWidget({
    super.key,
    required this.title,
    required this.icon,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        FaIcon(icon, size: 20, color: Theme.of(context).primaryColor),
        const SizedBox(height: 4),
        Text(title, style: const TextStyle(fontSize: 12)),
        const SizedBox(height: 4),
        SizedBox(
          // Giới hạn chiều rộng
          height: 40, // Giảm chiều cao
          child: TextFormField(
            controller: controller,
            textAlign: TextAlign.center,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(vertical: 8), // Giảm padding
            ),
            style: const TextStyle(fontSize: 12), // Giảm font
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) return 'Nhập';
              if (int.tryParse(value) == null) return 'Số';
              return null;
            },
          ),
        ),
      ],
    );
  }
}
