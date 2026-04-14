import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/meal_plan_provider.dart';
import '../../providers/auth_provider.dart';
import '../../Models/meal_plan.dart';
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
      final mealPlanProvider =
          Provider.of<MealPlanProvider>(context, listen: false);
      final authProvider =
          Provider.of<AuthProvider>(context, listen: false);

      mealPlanProvider.setWeekStart(_selectedDate);
      if (authProvider.user != null) {
        final userId = authProvider.user!.id;
        if (userId != null) {
          mealPlanProvider.fetchMealPlansForWeek(userId);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final mealPlanProvider = Provider.of<MealPlanProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header with week navigation
              _buildHeader(context, mealPlanProvider),

              // Week calendar selector
              _buildWeekCalendar(mealPlanProvider),

              // Meal sections
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    _buildMealSection(
                      context,
                      'Petit Déjeuner',
                      '7:00 - 9:00',
                      MealType.breakfast,
                      const Color(0xFFFFA500),
                      mealPlanProvider,
                      authProvider,
                    ),
                    const SizedBox(height: 16),
                    _buildMealSection(
                      context,
                      'Déjeuner',
                      '12:00 - 13:30',
                      MealType.lunch,
                      const Color(0xFF1E88E5),
                      mealPlanProvider,
                      authProvider,
                    ),
                    const SizedBox(height: 16),
                    _buildMealSection(
                      context,
                      'Dîner',
                      '19:00 - 20:30',
                      MealType.dinner,
                      const Color(0xFFEC4899),
                      mealPlanProvider,
                      authProvider,
                    ),
                    const SizedBox(height: 16),
                    _buildMealSection(
                      context,
                      'Goûter',
                      '15:00 - 16:00',
                      MealType.snack,
                      const Color(0xFF9C27B0),
                      mealPlanProvider,
                      authProvider,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      '💡 Afficher votre message entre les jours et les jours',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(
      BuildContext context, MealPlanProvider mealPlanProvider) {
    final startDate = mealPlanProvider.selectedWeekStart;

    String dayName =
        DateFormat('EEEE', 'fr_FR').format(startDate).capitalize();
    int dayNum = startDate.day;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF7C4DFF), Color(0xFFE040FB)],
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left, color: Colors.white),
                onPressed: () {
                  mealPlanProvider.previousWeek();
                  final authProvider =
                      Provider.of<AuthProvider>(context, listen: false);
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
                  const Text(
                    'Semaine du',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                  Text(
                    '$dayName $dayNum',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right, color: Colors.white),
                onPressed: () {
                  mealPlanProvider.nextWeek();
                  final authProvider =
                      Provider.of<AuthProvider>(context, listen: false);
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
          const SizedBox(height: 8),
          // Smooth indicator dots
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (int i = 0; i < 7; i++)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: Container(
                    width: i == 3 ? 24 : 6,
                    height: 6,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(3),
                      color: Colors.white.withOpacity(
                        i == 3 ? 1.0 : 0.5,
                      ),
                    ),
                  ),
                )
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWeekCalendar(MealPlanProvider mealPlanProvider) {
    final startDate = mealPlanProvider.selectedWeekStart;

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(7, (index) {
          final date = startDate.add(Duration(days: index));
          final isSelected = date.day == _selectedDate.day &&
              date.month == _selectedDate.month &&
              date.year == _selectedDate.year;

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedDate = date;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: isSelected
                    ? const Color(0xFF7C4DFF)
                    : Colors.grey[200],
              ),
              child: Column(
                children: [
                  Text(
                    DateFormat('E', 'fr_FR')
                        .format(date)
                        .substring(0, 3)
                        .toUpperCase(),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.white : Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    date.day.toString().padLeft(2, '0'),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : Colors.grey[800],
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildMealSection(
    BuildContext context,
    String title,
    String time,
    MealType mealType,
    Color color,
    MealPlanProvider mealPlanProvider,
    AuthProvider authProvider,
  ) {
    final meal =
        mealPlanProvider.getMealForDateAndType(_selectedDate, mealType);

    return Column(
      children: [
        // Header - Time and status
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: color,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    time,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
              if (meal != null)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    '✓ Planifiée',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                )
            ],
          ),
        ),

        // Content
        Container(
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(16),
              bottomRight: Radius.circular(16),
            ),
          ),
          padding: const EdgeInsets.all(12),
          child: meal == null
              ? _buildAddMealButton(context, mealType, authProvider)
              : _buildMealContent(
                  context, meal, mealType, mealPlanProvider, authProvider),
        ),
      ],
    );
  }

  Widget _buildAddMealButton(
      BuildContext context, MealType mealType, AuthProvider authProvider) {
    IconData icon;
    switch (mealType) {
      case MealType.breakfast:
        icon = Icons.breakfast_dining;
        break;
      case MealType.lunch:
        icon = Icons.lunch_dining;
        break;
      case MealType.dinner:
        icon = Icons.dinner_dining;
        break;
      case MealType.snack:
        icon = Icons.icecream;
        break;
    }

    return SizedBox(
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 32, color: Colors.grey[400]),
          const SizedBox(height: 8),
          const Text(
            'Ajouter un repas',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Sélectionner une recette pour ajouter',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 40,
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AssignRecipePage(
                      date: _selectedDate,
                      mealType: mealType,
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('Ajouter'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.grey[800],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMealContent(
    BuildContext context,
    MealPlan meal,
    MealType mealType,
    MealPlanProvider mealPlanProvider,
    AuthProvider authProvider,
  ) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                Icons.restaurant_menu,
                color: Colors.grey[600],
                size: 24,
              ),
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
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[600],
                      ),
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
                              const SnackBar(
                                content: Text('Repas supprimé'),
                              ),
                            );
                          },
                          child: const Text('Supprimer',
                              style: TextStyle(color: Colors.red)),
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
