import 'package:flutter/material.dart';
import 'views/screens/login_screen.dart';
import 'controllers/cart_controller.dart';  

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); 
  await CartManager().loadFromDatabase();    
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Global Recipe Book',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
        useMaterial3: true,
      ),
      home: const LoginScreen(),
      routes: {
        '/login': (context) => const LoginScreen(),
      },
    );
  }
}