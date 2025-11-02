part of 'pizza_edit_bloc.dart';

enum PizzaEditStatus { initial, loading, success, failure }

class PizzaEditState extends Equatable {
  final PizzaEditStatus status;
  final String? error; // Để lưu thông báo lỗi nếu có

  const PizzaEditState({this.status = PizzaEditStatus.initial, this.error});

  // Hàm copyWith để tạo state mới
  PizzaEditState copyWith({PizzaEditStatus? status, String? error}) {
    return PizzaEditState(
      status: status ?? this.status,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [status, error];
}
