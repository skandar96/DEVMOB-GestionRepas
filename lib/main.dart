import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gestionrepas/navigation/routes.dart';
import 'package:gestionrepas/providers/auth_provider.dart';
import 'package:gestionrepas/views/Recipe/RecipeDetailPage.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => AuthProvider())],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: AppRoutes.initialRoute,
      routes: AppRoutes.getRoutes(),
      onUnknownRoute: (settings) {
        if (settings.name == '/recipeDetail') {
          final recipe = settings.arguments as Map<String, dynamic>?;
          return MaterialPageRoute(
            builder: (context) => RecipeDetailPage(recipe: recipe),
          );
        }
        return null;
      },
    );
  }
}
