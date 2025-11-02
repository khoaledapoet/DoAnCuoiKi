import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pizza_repository/pizza_repository.dart';
import '../../../components/macro.dart';
import '../../../blocs/cart_bloc/cart_bloc.dart';
import '../../../blocs/authentication_bloc/authentication_bloc.dart';
import '../../../blocs/favorite_bloc/favorite_bloc.dart';

class DetailsScreen extends StatefulWidget {
  final Pizza pizza;
  const DetailsScreen(this.pizza, {super.key});

  @override
  State<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  PizzaSize _selectedSize = PizzaSize.medium; // Size mặc định

  int get _finalPrice {
    final basePrice = widget.pizza.price -
        (widget.pizza.price * widget.pizza.discount / 100);
    return (basePrice * _selectedSize.priceMultiplier).toInt();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        actions: [
          BlocBuilder<FavoriteBloc, FavoriteState>(
            builder: (context, favoriteState) {
              final isFavorite = favoriteState.isFavorite(widget.pizza.pizzaId);
              return IconButton(
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: isFavorite ? Colors.red : Colors.grey.shade600,
                ),
                onPressed: () {
                  final authState = context.read<AuthenticationBloc>().state;
                  if (authState.status == AuthenticationStatus.authenticated &&
                      authState.user != null) {
                    final userId = authState.user!.userId;
                    if (isFavorite) {
                      context.read<FavoriteBloc>().add(
                        RemoveFavorite(widget.pizza.pizzaId, userId),
                      );
                    } else {
                      context.read<FavoriteBloc>().add(
                        AddFavorite(widget.pizza.pizzaId, userId),
                      );
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Vui lòng đăng nhập!'),
                      ),
                    );
                  }
                },
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.width - (40),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.grey,
                    offset: Offset(3, 3),
                    blurRadius: 5,
                  ),
                ],
                image: DecorationImage(image: NetworkImage(widget.pizza.picture)),
              ),
            ),
            const SizedBox(height: 30),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.grey,
                    offset: Offset(3, 3),
                    blurRadius: 5,
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          flex: 2,
                          child: Text(
                            widget.pizza.name,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  "$_finalPrice ₫",
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                  ),
                                ),
                                if (widget.pizza.discount > 0)
                                  Text(
                                    "${widget.pizza.price}.00 ₫",
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey,
                                      decoration: TextDecoration.lineThrough,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        MyMacroWidget(
                          title: "Calo",
                          value: widget.pizza.macros.calories,
                          icon: FontAwesomeIcons.fire,
                        ),
                        const SizedBox(width: 10),
                        MyMacroWidget(
                          title: "Đạm",
                          value: widget.pizza.macros.proteins,
                          icon: FontAwesomeIcons.dumbbell,
                        ),
                        const SizedBox(width: 10),
                        MyMacroWidget(
                          title: "Béo",
                          value: widget.pizza.macros.fat,
                          icon: FontAwesomeIcons.oilWell,
                        ),
                        const SizedBox(width: 10),
                        MyMacroWidget(
                          title: "Carbs",
                          value: widget.pizza.macros.carbs,
                          icon: FontAwesomeIcons.breadSlice,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Chọn size
                    const Text(
                      'Chọn size:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: PizzaSize.values.map((size) {
                        final isSelected = _selectedSize == size;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedSize = size;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Theme.of(context).colorScheme.primary
                                  : Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSelected
                                    ? Theme.of(context).colorScheme.primary
                                    : Colors.grey.shade400,
                                width: 2,
                              ),
                            ),
                            child: Text(
                              size.label,
                              style: TextStyle(
                                color: isSelected ? Colors.white : Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: MediaQuery.of(context).size.width,
                      height: 50,
                      child: TextButton(
                        onPressed: () {
                          // Lấy thông tin user hiện tại
                          final authState =
                              context.read<AuthenticationBloc>().state;
                          if (authState.status ==
                                  AuthenticationStatus.authenticated &&
                              authState.user != null) {
                            final userId = authState.user!.userId;

                            // Tạo CartItem từ Pizza hiện tại với size đã chọn
                            final cartItem = CartItem(
                              pizzaId: widget.pizza.pizzaId,
                              pizzaName: widget.pizza.name,
                              picture: widget.pizza.picture,
                              price: _finalPrice,
                              quantity: 1, // Mặc định thêm 1 món
                              size: _selectedSize,
                            );

                            // Gửi event AddCartItem đến CartBloc
                            context.read<CartBloc>().add(
                                  AddCartItem(cartItem, userId),
                                );

                            // Hiển thị thông báo
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    'Đã thêm ${widget.pizza.name} (${_selectedSize.label}) vào giỏ hàng!'),
                                duration: const Duration(seconds: 2),
                                action: SnackBarAction(
                                  label: 'Xem giỏ hàng',
                                  onPressed: () {
                                    Navigator.of(context).pushNamed('/cart');
                                  },
                                ),
                              ),
                            );
                          } else {
                            // Nếu chưa đăng nhập
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    'Vui lòng đăng nhập để thêm vào giỏ hàng!'),
                              ),
                            );
                          }
                        },
                        style: TextButton.styleFrom(
                          elevation: 3.0,
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          "Thêm vào giỏ hàng",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
