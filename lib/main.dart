import 'package:flutter/material.dart';
import 'controllers/cart_controller.dart';
import 'views/screens/login_screen.dart';

// Global dark mode toggle
final ValueNotifier<bool> isDarkMode = ValueNotifier(false);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await CartManager().loadFromDatabase();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: isDarkMode,
      builder: (context, darkMode, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Global Recipe Book',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
            useMaterial3: true,
            scaffoldBackgroundColor: Colors.white,
          ),
          darkTheme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.orange,
              brightness: Brightness.dark,
            ),
            useMaterial3: true,
            scaffoldBackgroundColor: const Color(0xFF2C2C2C), // dark gray
          ),
          themeMode: darkMode ? ThemeMode.dark : ThemeMode.light,
          home: const LoginScreen(),
        );
      },
    );
  }
}