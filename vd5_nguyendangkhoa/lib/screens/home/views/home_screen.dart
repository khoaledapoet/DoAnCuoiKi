// ...existing code...
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vd5_nguyendangkhoa/screens/home/blocs/get_pizza_bloc.dart';
import 'package:vd5_nguyendangkhoa/screens/home/views/details_screnn.dart';
import 'package:vd5_nguyendangkhoa/blocs/authentication_bloc/authentication_bloc.dart';
import 'package:user_repository/user_repository.dart';
import 'package:vd5_nguyendangkhoa/screens/admin/admin_screen.dart';
import 'package:vd5_nguyendangkhoa/blocs/favorite_bloc/favorite_bloc.dart';
import 'package:vd5_nguyendangkhoa/main.dart'; // <-- thêm để dùng navigatorKey
// ...existing code...

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    context.read<GetPizzaBloc>().add(GetPizza());
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthenticationBloc>().state;
    final MyUser? user = authState.user;

    return BlocListener<AuthenticationBloc, AuthenticationState>(
      listener: (context, state) {
        if (state.status == AuthenticationStatus.unauthenticated) {
          Navigator.of(context).popUntil((route) => route.isFirst);
        }
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.surface,
          title: Row(
            children: [
              Image.asset('assets/8.png', scale: 14),
              const SizedBox(width: 8),
              const Text(
                'PIZZA',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 30),
              ),
            ],
          ),
          actions: [
            if (user != null && user.role == 'admin')
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AdminScreen(),
                    ),
                  );
                },
                tooltip: 'Admin Panel',
                icon: const Icon(CupertinoIcons.shield_lefthalf_fill),
              ),

            // Giỏ hàng (hiện nếu user đã đăng nhập)
            if (user != null)
              IconButton(
                icon: const Icon(Icons.shopping_cart_outlined),
                tooltip: 'Giỏ hàng',
                onPressed: () {
                  // dùng navigatorKey để điều hướng tới route đã đăng ký '/cart'
                  navigatorKey.currentState?.pushNamed('/cart');
                },
              ),

            // Hồ sơ người dùng (hiện nếu user đã đăng nhập)
            if (user != null)
              IconButton(
                icon: const Icon(Icons.person_outline),
                tooltip: 'Hồ sơ',
                onPressed: () {
                  // nếu bạn có route '/profile' thì nó sẽ hoạt động, nếu không hãy đổi đường dẫn
                  navigatorKey.currentState?.pushNamed('/profile');
                },
              ),

            // Đăng xuất (hiện nếu user đã đăng nhập)
            if (user != null)
              IconButton(
                icon: const Icon(Icons.logout),
                tooltip: 'Đăng xuất',
                onPressed: () {
                  context.read<AuthenticationBloc>().add(AuthenticationLogoutRequested());
                },
              ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: BlocBuilder<GetPizzaBloc, GetPizzaState>(
            builder: (context, state) {
              if (state is GetPizzaLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state is GetPizzaFailure) {
                return const Center(
                  child: Text("Đã có lỗi xảy ra khi tải pizza..."),
                );
              }
              if (state is GetPizzaSuccess) {
                return GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 3 / 5.2, // ⚡ Điều chỉnh tỉ lệ chiều cao
                  ),
                  itemCount: state.pizzas.length,
                  itemBuilder: (context, i) {
                    final pizza = state.pizzas[i];
                    return LayoutBuilder(
                      builder: (context, constraints) {
                        return Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 5,
                                offset: const Offset(2, 2),
                              ),
                            ],
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(20),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DetailsScreen(pizza),
                                ),
                              );
                            },
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Stack(
                                  children: [
                                    ClipRRect(
                                      borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(20),
                                      ),
                                      child: Image.network(
                                        pizza.picture,
                                        height: constraints.maxHeight * 0.45,
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stack) =>
                                            const Icon(
                                              Icons.broken_image,
                                              size: 40,
                                            ),
                                      ),
                                    ),
                                    // Icon yêu thích
                                    Positioned(
                                      top: 8,
                                      right: 8,
                                      child: BlocBuilder<FavoriteBloc, FavoriteState>(
                                        builder: (context, favoriteState) {
                                          final isFavorite = favoriteState.isFavorite(pizza.pizzaId);
                                          return GestureDetector(
                                            onTap: () {
                                              final authState = context.read<AuthenticationBloc>().state;
                                              if (authState.status == AuthenticationStatus.authenticated &&
                                                  authState.user != null) {
                                                final userId = authState.user!.userId;
                                                if (isFavorite) {
                                                  context.read<FavoriteBloc>().add(
                                                    RemoveFavorite(pizza.pizzaId, userId),
                                                  );
                                                } else {
                                                  context.read<FavoriteBloc>().add(
                                                    AddFavorite(pizza.pizzaId, userId),
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
                                            child: Container(
                                              padding: const EdgeInsets.all(6),
                                              decoration: BoxDecoration(
                                                color: Colors.white.withOpacity(0.9),
                                                shape: BoxShape.circle,
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black.withOpacity(0.1),
                                                    blurRadius: 4,
                                                    offset: const Offset(0, 2),
                                                  ),
                                                ],
                                              ),
                                              child: Icon(
                                                isFavorite ? Icons.favorite : Icons.favorite_border,
                                                color: isFavorite ? Colors.red : Colors.grey.shade600,
                                                size: 20,
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Wrap(
                                    spacing: 4,
                                    runSpacing: 4,
                                    children: [
                                      _buildTag(
                                        text: pizza.isVeg ? "CHAY" : "MẶN",
                                        color: pizza.isVeg
                                            ? Colors.green.shade100
                                            : Colors.red.shade100,
                                        textColor: pizza.isVeg
                                            ? Colors.green.shade800
                                            : Colors.red.shade800,
                                      ),
                                      _buildTag(
                                        text: pizza.spicy == 1
                                            ? "🌶️ KHÔNG CAY"
                                            : (pizza.spicy == 2
                                                  ? "🌶️ CAY VỪA"
                                                  : "🌶️🌶️ CAY"),
                                        color: Colors.orange.shade50,
                                        textColor: pizza.spicy == 1
                                            ? Colors.green
                                            : (pizza.spicy == 2
                                                  ? Colors.orange.shade700
                                                  : Colors.redAccent),
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8.0,
                                  ),
                                  child: Text(
                                    pizza.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8.0,
                                  ),
                                  child: Text(
                                    pizza.description,
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 11,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const Spacer(),
                                Padding(
                                  padding: const EdgeInsets.only(
                                    left: 8,
                                    right: 8,
                                    bottom: 6,
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "${(pizza.price * (1 - pizza.discount / 100)).toStringAsFixed(0)} ₫",
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Theme.of(
                                                context,
                                              ).colorScheme.primary,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          if (pizza.discount > 0)
                                            Text(
                                              "${pizza.price} ₫",
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: Colors.grey.shade500,
                                                decoration:
                                                    TextDecoration.lineThrough,
                                              ),
                                            ),
                                        ],
                                      ),
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Theme.of(
                                            context,
                                          ).colorScheme.primary,
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 6,
                                          ),
                                          minimumSize: Size.zero,
                                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                        ),
                                        onPressed: () {
                                          // Mở trang chi tiết sản phẩm
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => DetailsScreen(pizza),
                                            ),
                                          );
                                        },
                                        child: const Text(
                                          'Mua ngay',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildTag({
    required String text,
    required Color color,
    required Color textColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 7),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.bold,
          fontSize: 9,
        ),
      ),
    );
  }
}
// ...existing code...