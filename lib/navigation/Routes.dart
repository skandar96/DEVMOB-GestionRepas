import 'package:flutter/material.dart';
import '../views/Auth/RegisterPage .dart';
import '../views/Auth/LoginPage.dart';
import '../views/Home/main_screen.dart';

class AppRoutes {
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String recettes = '/recettes';

  // Map des routes
  static Map<String, WidgetBuilder> getRoutes() {
    return {
      login: (context) => const LoginScreen(),
      register: (context) => const RegisterScreen(),
      home: (context) => const MainNavigation(),
    };
  }

  // Route initiale
  static const String initialRoute = '/login';
}
