import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/bottom_nav_bar.dart';
import '../Home/home_page.dart';
import '../Recipe/RecipeListPage.dart';
import '../Mealplan/MealCalendarPage.dart';
import '../Shopping/ShoppingListPage.dart';
import '../../providers/RecipeProvider.dart';
import '../../providers/auth_provider.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => MainNavigationState();
}

class MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    // Initialiser l'userId du RecipeProvider
    final authProvider = context.read<AuthProvider>();
    if (authProvider.user != null && authProvider.user!.id != null) {
      context.read<RecipeProvider>().setUserId(authProvider.user!.id!);
    }
  }

  void switchTab(int index) {
    // Recharger les recettes quand on va vers la page Recettes (index 1)
    if (index == 1) {
      context.read<RecipeProvider>().loadRecipes();
    }
    setState(() {
      _selectedIndex = index;
    });
  }

  final List<Widget> _pages = const [
    HomePage(),
    RecipeListPage(),
    MealCalendarPage(),
    ShoppingListPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: _selectedIndex,
        onTap: switchTab,
      ),
    );
  }
}
