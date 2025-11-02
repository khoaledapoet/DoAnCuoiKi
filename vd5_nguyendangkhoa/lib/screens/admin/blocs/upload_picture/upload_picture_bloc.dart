import 'dart:typed_data'; // Cần cho Uint8List
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
// 💡 Đảm bảo import đúng PizzaRepo và các hàm upload ảnh bạn đã thêm
import 'package:pizza_repository/pizza_repository.dart';

part 'upload_picture_event.dart';
part 'upload_picture_state.dart';

class UploadPictureBloc extends Bloc<UploadPictureEvent, UploadPictureState> {
  final PizzaRepo _pizzaRepo;

  UploadPictureBloc({required PizzaRepo pizzaRepo})
    : _pizzaRepo = pizzaRepo,
      super(UploadPictureInitial()) {
    on<UploadPicture>(_onUploadPicture);
  }

  Future<void> _onUploadPicture(
    UploadPicture event,
    Emitter<UploadPictureState> emit,
  ) async {
    emit(UploadPictureLoading()); // Bắt đầu loading
    try {
      // Gọi hàm upload ảnh từ repository (hàm này cần nhận bytes và tên file)
      // Giả sử hàm đó tên là uploadImageBytes
      final imageUrl = await _pizzaRepo.uploadImageBytes(
        event.fileBytes,
        event.fileName,
      );

      emit(UploadPictureSuccess(imageUrl)); // Thành công, trả về URL
    } catch (e) {
      emit(UploadPictureFailure(error: e.toString())); // Thất bại
    }
  }
}
