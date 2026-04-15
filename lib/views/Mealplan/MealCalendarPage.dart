import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/meal_plan_provider.dart';
import '../../providers/auth_provider.dart';
import '../../Models/meal_plan.dart';
import '../../theme/gradient_header.dart';
import './AssignRecipePage.dart';

class MealCalendarPage extends StatefulWidget {
  const MealCalendarPage({super.key});

  @override
  State<MealCalendarPage> createState() => _MealCalendarPageState();
}

class _MealCalendarPageState extends State<MealCalendarPage> {
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final mealPlanProvider = Provider.of<MealPlanProvider>(
        context,
        listen: false,
      );
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      mealPlanProvider.setWeekStart(_selectedDate);
      if (authProvider.user != null) {
        final userId = authProvider.user!.id;
        if (userId != null) {
          mealPlanProvider.fetchMealPlansForWeek(userId);
        }
      }
    });
  }

  String _getMonthYear() {
    return DateFormat('MMMM yyyy', 'fr_FR').format(_selectedDate).capitalize();
  }

  String _getDayName() {
    return DateFormat('EEEE', 'fr_FR').format(_selectedDate).capitalize();
  }

  @override
  Widget build(BuildContext context) {
    final mealPlanProvider = Provider.of<MealPlanProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final isToday =
        _selectedDate.day == DateTime.now().day &&
        _selectedDate.month == DateTime.now().month &&
        _selectedDate.year == DateTime.now().year;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // --- HEADER AVEC DÉGRADÉ ---
            GradientHeader(
              padding: const EdgeInsets.only(
                top: 50,
                left: 20,
                right: 20,
                bottom: 30,
              ),
              child: Column(
                children: [
                  Row(
                    children: const [
                      Icon(Icons.calendar_month, color: Colors.white, size: 28),
                      SizedBox(width: 10),
                      Text(
                        "Planning Hebdomadaire",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 25),
                  // Sélecteur de date central
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.chevron_left,
                            color: Colors.white,
                            size: 30,
                          ),
                          onPressed: () {
                            setState(() {
                              _selectedDate = _selectedDate.subtract(
                                Duration(days: 1),
                              );
                            });
                            mealPlanProvider.setWeekStart(_selectedDate);
                            if (authProvider.user != null) {
                              final userId = authProvider.user!.id;
                              if (userId != null) {
                                mealPlanProvider.fetchMealPlansForWeek(userId);
                              }
                            }
                          },
                        ),
                        Column(
                          children: [
                            Text(
                              _getMonthYear(),
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              '${_getDayName()} ${_selectedDate.day}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.chevron_right,
                            color: Colors.white,
                            size: 30,
                          ),
                          onPressed: () {
                            setState(() {
                              _selectedDate = _selectedDate.add(
                                Duration(days: 1),
                              );
                            });
                            mealPlanProvider.setWeekStart(_selectedDate);
                            if (authProvider.user != null) {
                              final userId = authProvider.user!.id;
                              if (userId != null) {
                                mealPlanProvider.fetchMealPlansForWeek(userId);
                              }
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 15),
                  // Indicateurs de pagination (les points)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(7, (index) {
                      final startDate = mealPlanProvider.selectedWeekStart;
                      final date = startDate.add(Duration(days: index));
                      final isCurrentDay =
                          date.day == _selectedDate.day &&
                          date.month == _selectedDate.month &&
                          date.year == _selectedDate.year;
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        width: isCurrentDay ? 25 : 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(
                            isCurrentDay ? 1 : 0.5,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),

            // --- CALENDRIER HORIZONTAL ---
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: _buildWeekDays(mealPlanProvider),
                ),
              ),
            ),

            // Badge "Aujourd'hui"
            if (isToday)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00C853),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        CircleAvatar(radius: 3, backgroundColor: Colors.white),
                        SizedBox(width: 5),
                        Text(
                          "Aujourd'hui",
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // --- SECTIONS DE REPAS ---
            _buildMealSection(
              context,
              title: "Petit Déjeuner",
              time: "07:00 - 09:00",
              color: const Color(0xFFFFA000),
              icon: Icons.wb_twilight,
              mealType: MealType.breakfast,
              mealPlanProvider: mealPlanProvider,
              authProvider: authProvider,
            ),
            _buildMealSection(
              context,
              title: "Déjeuner",
              time: "12:00 - 14:00",
              color: const Color(0xFF03A9F4),
              icon: Icons.wb_sunny,
              mealType: MealType.lunch,
              mealPlanProvider: mealPlanProvider,
              authProvider: authProvider,
            ),
            _buildMealSection(
              context,
              title: "Dîner",
              time: "19:00 - 21:00",
              color: const Color(0xFFE91E63),
              icon: Icons.nightlight_round,
              mealType: MealType.dinner,
              mealPlanProvider: mealPlanProvider,
              authProvider: authProvider,
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildWeekDays(MealPlanProvider mealPlanProvider) {
    final startDate = mealPlanProvider.selectedWeekStart;
    final days = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];

    return List.generate(7, (index) {
      final date = startDate.add(Duration(days: index));
      final isSelected =
          date.day == _selectedDate.day &&
          date.month == _selectedDate.month &&
          date.year == _selectedDate.year;

      return GestureDetector(
        onTap: () {
          setState(() {
            _selectedDate = date;
          });
        },
        child: _buildDayItem(days[index], date.day.toString(), isSelected),
      );
    });
  }

  Widget _buildDayItem(String day, String date, bool isSelected) {
    return Column(
      children: [
        Text(
          day,
          style: TextStyle(
            color: isSelected ? Colors.indigo : Colors.grey,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF7B61FF) : Colors.transparent,
            borderRadius: BorderRadius.circular(15),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.3),
                      blurRadius: 8,
                    ),
                  ]
                : [],
          ),
          child: Text(
            date,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black87,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMealSection(
    BuildContext context, {
    required String title,
    required String time,
    required Color color,
    required IconData icon,
    required MealType mealType,
    required MealPlanProvider mealPlanProvider,
    required AuthProvider authProvider,
  }) {
    final meal = mealPlanProvider.getMealForDateAndType(
      _selectedDate,
      mealType,
    );

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
        ],
      ),
      child: Column(
        children: [
          // En-tête coloré du repas
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: color,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(25),
                topRight: Radius.circular(25),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 15),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      time,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Zone "Ajouter un repas" ou affichage du repas
          Padding(
            padding: const EdgeInsets.all(20),
            child: meal == null
                ? _buildAddMealButtonNew(context, mealType, color)
                : _buildMealContentNew(
                    context,
                    meal,
                    mealType,
                    mealPlanProvider,
                    authProvider,
                    color,
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddMealButtonNew(
    BuildContext context,
    MealType mealType,
    Color color,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 30),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.7), color],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      AssignRecipePage(date: _selectedDate, mealType: mealType),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Icon(Icons.add, color: Colors.white, size: 30),
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            "Ajouter un repas",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          const Text(
            "Choisissez une recette pour ce repas",
            style: TextStyle(color: Colors.white70, fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _buildMealContentNew(
    BuildContext context,
    MealPlan meal,
    MealType mealType,
    MealPlanProvider mealPlanProvider,
    AuthProvider authProvider,
    Color color,
  ) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(Icons.restaurant_menu, color: color, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      meal.recipeName ?? 'Recette',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      '${meal.servings} portion${meal.servings > 1 ? 's' : ''}',
                      style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, size: 20),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Supprimer ce repas ?'),
                      content: Text('Supprimer ${meal.recipeName} ?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Annuler'),
                        ),
                        TextButton(
                          onPressed: () {
                            mealPlanProvider.deleteMealPlan(meal.id);
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Repas supprimé')),
                            );
                          },
                          child: const Text(
                            'Supprimer',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AssignRecipePage(
                    date: _selectedDate,
                    mealType: mealType,
                    mealPlan: meal,
                  ),
                ),
              );
            },
            icon: const Icon(Icons.edit_outlined, size: 18),
            label: const Text('Modifier'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.grey[700],
              padding: const EdgeInsets.symmetric(vertical: 10),
            ),
          ),
        ),
      ],
    );
  }
}

extension on String {
  String capitalize() {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1);
  }
}
