import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// Import các BLoC, Repo, màn hình cần thiết
import 'package:vd5_nguyendangkhoa/blocs/authentication_bloc/authentication_bloc.dart';
import 'package:vd5_nguyendangkhoa/screens/home/blocs/get_pizza_bloc.dart';
import 'package:pizza_repository/pizza_repository.dart';
import 'package:vd5_nguyendangkhoa/screens/main/main_screen.dart';
import 'package:vd5_nguyendangkhoa/screens/auth/views/welcome_screnn.dart';
import 'package:vd5_nguyendangkhoa/screens/cart/cart_screen.dart';
import 'package:vd5_nguyendangkhoa/main.dart'; // Import main.dart cho navigatorKey

// ----- DÒNG BẠN CẦN THÊM -----
import 'package:vd5_nguyendangkhoa/screens/profile/profile_screen.dart'; 
// 👆 (Hãy đảm bảo đường dẫn này đúng với cấu trúc thư mục của bạn)
// ----- KẾT THÚC DÒNG THÊM -----


class MyAppView extends StatelessWidget {
  const MyAppView({super.key});

  @override
  Widget build(BuildContext context) {
    // 👇 BỌC MaterialApp BẰNG BlocProvider<GetPizzaBloc>
    return BlocProvider(
      create: (context) => GetPizzaBloc(
        // Lấy PizzaRepo từ MultiRepositoryProvider trong app.dart
        context.read<PizzaRepo>(),
      )..add(GetPizza()), // Bắt đầu tải pizza ngay
      child: MaterialApp(
        navigatorKey: navigatorKey, // Gắn key
        title: 'Pizza Delivery',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: const ColorScheme.light().copyWith(
            surface: Colors.grey.shade100,
            onSurface: Colors.black,
            primary: Colors.blue,
            onPrimary: Colors.white,
          ),
        ),
        // Thêm named routes
        routes: {
          '/cart': (context) => const CartScreen(),
          
          // ----- DÒNG BẠN CẦN THÊM -----
          '/profile': (context) => const ProfileScreen(),
          // ----- KẾT THÚC DÒNG THÊM -----
        
        },
        // 👇 Dùng BlocBuilder ở đây để quyết định màn hình ban đầu
        home: BlocBuilder<AuthenticationBloc, AuthenticationState>(
          builder: (context, state) {
            if (state.status == AuthenticationStatus.authenticated) {
              return const MainScreen(); // Nếu đã đăng nhập -> MainScreen
            } else {
              return const WelcomeScreen(); // Nếu chưa -> WelcomeScreen
            }
          },
        ),
      ),
    );
  }
}