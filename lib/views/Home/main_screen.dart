import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/bottom_nav_bar.dart';
import '../Home/home_page.dart';
import '../Recipe/RecipeListPage.dart';
import '../Mealplan/MealCalendarPage.dart';
import '../Shopping/ShoppingListPage.dart';
import '../../providers/RecipeProvider.dart';
import '../../providers/meal_plan_provider.dart';
import '../../providers/auth_provider.dart';

class MainNavigation extends StatefulWidget {
  final int initialIndex;

  const MainNavigation({super.key, this.initialIndex = 0});

  @override
  State<MainNavigation> createState() => MainNavigationState();
}

class MainNavigationState extends State<MainNavigation> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
    // Initialiser les données utilisateur après le premier build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = context.read<AuthProvider>();
      if (authProvider.user != null && authProvider.user!.id != null) {
        final userId = authProvider.user!.id!;
        context.read<RecipeProvider>().setUserId(userId);
        context.read<MealPlanProvider>().setWeekStart(DateTime.now());
        context.read<MealPlanProvider>().fetchMealPlansForWeek(userId);
        context.read<RecipeProvider>().loadRecipes();
      }
    });
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

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomePage(onNavigateToTab: switchTab),
      const RecipeListPage(),
      const MealCalendarPage(),
      const ShoppingListPage(),
    ];

    return Scaffold(
      body: pages[_selectedIndex],
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: _selectedIndex,
        onTap: switchTab,
      ),
    );
  }
}
