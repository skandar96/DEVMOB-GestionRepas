import 'package:flutter/material.dart';
import '../widgets/bottom_nav_bar.dart';
import '../Home/home_page.dart';
import '../Mealplan/MealCalendarPage.dart';
import '../Shopping/ShoppingListPage.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => MainNavigationState();
}

class MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  void switchTab(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  final List<Widget> _pages = const [
    HomePage(),
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
