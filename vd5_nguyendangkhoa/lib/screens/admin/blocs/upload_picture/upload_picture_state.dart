part of 'upload_picture_bloc.dart'; // Sẽ tạo file bloc ở bước 3

abstract class UploadPictureState extends Equatable {
  const UploadPictureState();

  @override
  List<Object> get props => [];
}

// Trạng thái ban đầu
class UploadPictureInitial extends UploadPictureState {}

// Trạng thái đang upload
class UploadPictureLoading extends UploadPictureState {}

// Trạng thái upload thành công, chứa URL ảnh
class UploadPictureSuccess extends UploadPictureState {
  final String url;

  const UploadPictureSuccess(this.url);

  @override
  List<Object> get props => [url];
}

// Trạng thái upload thất bại
class UploadPictureFailure extends UploadPictureState {
  final String? error;
  const UploadPictureFailure({this.error});

  @override
  List<Object> get props => [error ?? 'Unknown error'];
}
