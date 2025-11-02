import 'models/models.dart';
import 'dart:typed_data';

abstract class PizzaRepo {
  Future<List<Pizza>> getPizzas();
  Future<void> deletePizza(String pizzaId);
  Future<void> addPizza(Pizza pizza);
  Future<void> updatePizza(Pizza pizza);
  Future<String> uploadImageBytes(Uint8List fileBytes, String fileName);
  Future<List<Order>> getOrders();
}
