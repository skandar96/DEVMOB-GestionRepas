import 'package:flutter/material.dart';
import '../views/Auth/RegisterPage .dart';
import '../views/Auth/LoginPage.dart';
import '../views/Home/main_screen.dart';

import '../views/Recipe/AddRecipePage.dart';
import '../views/Recipe/RecipeDetailPage.dart';

class AppRoutes {
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String addRecipe = '/addRecipe';
  static const String recipeDetail = '/recipeDetail';

  // Map des routes
  static Map<String, WidgetBuilder> getRoutes() {
    return {
      login: (context) => const LoginScreen(),
      register: (context) => const RegisterScreen(),
      home: (context) => const MainNavigation(),
      addRecipe: (context) => const AddRecipePage(),
      recipeDetail: (context) => const RecipeDetailPage(),
    };
  }

  // Route avec arguments
  static Route<dynamic>? generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case recipeDetail:
        final recipe = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (context) => RecipeDetailPage(recipe: recipe),
        );
      default:
        return null;
    }
  }

  // Route initiale
  static const String initialRoute = '/login';
}
