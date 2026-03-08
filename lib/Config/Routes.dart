import 'package:flutter/material.dart';
import '../views/screens/Login_screen.dart';
import '../views/screens/Register_screen.dart';
import '../views/screens/home_screen.dart';

class AppRoutes {
  // Noms des routes (constants pour éviter les fautes de frappe)
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';

  
  // Map des routes
  static Map<String, WidgetBuilder> getRoutes() {
    return {
      login: (context) => const LoginScreen(),
      register: (context) => const RegisterScreen(),
      home: (context) => const HomeScreen(),
    
    };
  }
  
  // Route initiale
  static const String initialRoute = login;
}