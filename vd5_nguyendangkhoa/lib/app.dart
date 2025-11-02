import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vd5_nguyendangkhoa/app_view.dart'; // Import AppView
// Import Repositories
import 'package:user_repository/user_repository.dart';
import 'package:pizza_repository/pizza_repository.dart';
// Import Screens and main.dart (for navigatorKey)
import 'package:vd5_nguyendangkhoa/screens/auth/views/welcome_screnn.dart';
import 'package:vd5_nguyendangkhoa/main.dart';
// Import BLoCs
import 'blocs/authentication_bloc/authentication_bloc.dart';
import 'blocs/cart_bloc/cart_bloc.dart';
import 'blocs/favorite_bloc/favorite_bloc.dart';

class MyApp extends StatelessWidget {
  // Receive both repositories via constructor
  final UserRepository userRepository;
  final PizzaRepo pizzaRepository;

  const MyApp({
    super.key,
    required this.userRepository,
    required this.pizzaRepository,
  });

  @override
  Widget build(BuildContext context) {
    // Provide repositories first using MultiRepositoryProvider
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: userRepository),
        RepositoryProvider.value(value: pizzaRepository), // Provide PizzaRepo
      ],
      // 👇 THEN provide BLoCs using MultiBlocProvider
      child: MultiBlocProvider(
        providers: [
          // Provide AuthenticationBloc
          BlocProvider(
            create: (context) => AuthenticationBloc(
              // Read UserRepository provided above
              userRepository: context.read<UserRepository>(),
            ),
          ),
          // Provide CartBloc
          BlocProvider(
            create: (context) => CartBloc(
              // CartBloc needs UserRepository
              userRepository: context.read<UserRepository>(),
            ),
          ),
          // Provide FavoriteBloc
          BlocProvider(
            create: (context) => FavoriteBloc(
              userRepository: context.read<UserRepository>(),
            ),
          ),
        ],
        // Listen to AuthenticationBloc to control CartBloc and FavoriteBloc
        child: BlocListener<AuthenticationBloc, AuthenticationState>(
          listener: (context, state) {
            // Get CartBloc and FavoriteBloc instances
            final cartBloc = context.read<CartBloc>();
            final favoriteBloc = context.read<FavoriteBloc>();

            if (state.status == AuthenticationStatus.authenticated &&
                state.user != null &&
                state.user!.userId.isNotEmpty) {
              // When user logs in -> Start listening to cart and favorite streams
              print(
                "User Authenticated: ${state.user!.userId}. Starting Cart & Favorite Listeners.",
              );
              cartBloc.add(StartCartListener(state.user!.userId));
              favoriteBloc.add(StartFavoriteListener(state.user!.userId));
            } else if (state.status == AuthenticationStatus.unauthenticated) {
              // When user logs out -> Stop listening and clear state
              print(
                "User Unauthenticated. Stopping Cart & Favorite Listeners.",
              );
              cartBloc.add(StopCartListener());
              favoriteBloc.add(StopFavoriteListener());

              // Navigate back to WelcomeScreen
              WidgetsBinding.instance.addPostFrameCallback((_) {
                navigatorKey.currentState?.pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const WelcomeScreen()),
                  (route) => false,
                );
              });
            }
          },
          // The actual UI view
          child: const MyAppView(),
        ),
      ),
    );
  }
}
