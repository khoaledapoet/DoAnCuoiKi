part of 'upload_picture_bloc.dart'; // Sẽ tạo file bloc ở bước 3

abstract class UploadPictureEvent extends Equatable {
  const UploadPictureEvent();

  @override
  List<Object> get props => [];
}

// Event để bắt đầu upload ảnh
class UploadPicture extends UploadPictureEvent {
  final Uint8List fileBytes; // Dữ liệu ảnh dạng byte
  final String fileName; // Tên file ảnh

  const UploadPicture(this.fileBytes, this.fileName);

  @override
  List<Object> get props => [fileBytes, fileName];
}
