import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart'; // <-- added
// Import interface và implementation
import 'package:pizza_repository/pizza_repository.dart';
import 'package:user_repository/user_repository.dart';
// Chỉ cần import app.dart một lần
import 'app.dart';
import 'package:vd5_nguyendangkhoa/simple_bloc_observer.dart';

// GlobalKey cho Navigator (giữ nguyên)
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // DEBUG: buộc logout khi khởi động để kiểm tra flow (bỏ khi đã fix)
  await FirebaseAuth.instance.signOut();

  Bloc.observer = SimpleBlocObserver();

  // Tạo cả hai repository
  final userRepo = FirebaseUserRepo();
  final pizzaRepo = FirebasePizzaRepo();

  // Chạy MyApp và truyền repo
  runApp(MyApp(userRepository: userRepo, pizzaRepository: pizzaRepo));
}