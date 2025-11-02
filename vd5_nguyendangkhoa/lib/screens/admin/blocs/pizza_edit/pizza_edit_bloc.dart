import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:pizza_repository/pizza_repository.dart'; // Import repository của bạn

part 'pizza_edit_event.dart';
part 'pizza_edit_state.dart';

class PizzaEditBloc extends Bloc<PizzaEditEvent, PizzaEditState> {
  final PizzaRepo _pizzaRepo; // Sử dụng PizzaRepo (hoặc tên interface của bạn)

  PizzaEditBloc({required PizzaRepo pizzaRepo})
    : _pizzaRepo = pizzaRepo,
      super(const PizzaEditState()) {
    // Đăng ký xử lý sự kiện DeletePizza
    on<DeletePizza>(_onDeletePizza);
    on<AddPizza>(_onAddPizza);
    on<UpdatePizza>(_onUpdatePizza);
  }

  // Hàm xử lý khi sự kiện DeletePizza được gọi
  Future<void> _onDeletePizza(
    DeletePizza event,
    Emitter<PizzaEditState> emit,
  ) async {
    // 1. Phát ra state Loading
    emit(state.copyWith(status: PizzaEditStatus.loading));
    try {
      // 2. Gọi hàm deletePizza từ repository
      await _pizzaRepo.deletePizza(event.pizzaId);

      // 3. Phát ra state Success
      emit(state.copyWith(status: PizzaEditStatus.success));
    } catch (e) {
      // 4. Nếu lỗi, phát ra state Failure
      emit(
        state.copyWith(status: PizzaEditStatus.failure, error: e.toString()),
      );
    }
  }

  Future<void> _onAddPizza(AddPizza event, Emitter<PizzaEditState> emit) async {
    emit(state.copyWith(status: PizzaEditStatus.loading));
    try {
      await _pizzaRepo.addPizza(event.pizza);
      emit(state.copyWith(status: PizzaEditStatus.success));
    } catch (e) {
      emit(
        state.copyWith(status: PizzaEditStatus.failure, error: e.toString()),
      );
    }
  }

  Future<void> _onUpdatePizza(
    UpdatePizza event,
    Emitter<PizzaEditState> emit,
  ) async {
    emit(state.copyWith(status: PizzaEditStatus.loading));
    try {
      await _pizzaRepo.updatePizza(event.pizza);
      emit(state.copyWith(status: PizzaEditStatus.success));
    } catch (e) {
      emit(
        state.copyWith(status: PizzaEditStatus.failure, error: e.toString()),
      );
    }
  }
}
