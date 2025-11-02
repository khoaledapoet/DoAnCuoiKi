part of 'pizza_edit_bloc.dart';

abstract class PizzaEditEvent extends Equatable {
  const PizzaEditEvent();

  @override
  List<Object> get props => [];
}

// Event khi người dùng nhấn nút Xóa
class DeletePizza extends PizzaEditEvent {
  final String pizzaId;

  const DeletePizza(this.pizzaId);

  @override
  List<Object> get props => [pizzaId];
}

class AddPizza extends PizzaEditEvent {
  final Pizza pizza;

  const AddPizza(this.pizza);

  @override
  List<Object> get props => [pizza];
}

// 👇 THÊM EVENT NÀY
class UpdatePizza extends PizzaEditEvent {
  final Pizza pizza;

  const UpdatePizza(this.pizza);

  @override
  List<Object> get props => [pizza];
}
// (Chúng ta sẽ thêm event AddPizza và UpdatePizza sau)