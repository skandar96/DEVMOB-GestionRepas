import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import '../../providers/RecipeProvider.dart';
import '../../providers/meal_plan_provider.dart';
import '../../providers/auth_provider.dart';
import '../../Models/meal_plan.dart';

class AssignRecipePage extends StatefulWidget {
  final DateTime date;
  final MealType mealType;
  final MealPlan? mealPlan;

  const AssignRecipePage({
    super.key,
    required this.date,
    required this.mealType,
    this.mealPlan,
  });

  @override
  State<AssignRecipePage> createState() => _AssignRecipePageState();
}

class _AssignRecipePageState extends State<AssignRecipePage> {
  late int _servings;
  String? _selectedRecipeId;
  String? _selectedRecipeName;

  @override
  void initState() {
    super.initState();
    _servings = widget.mealPlan?.servings ?? 1;
    _selectedRecipeId = widget.mealPlan?.recipeId;
    _selectedRecipeName = widget.mealPlan?.recipeName;
  }

  @override
  Widget build(BuildContext context) {
    final recipeProvider = Provider.of<RecipeProvider>(context);
    final mealTypeLabel = _getMealTypeLabel(widget.mealType);
    final dateFormatted =
        DateFormat('EEEE dd MMMM', 'fr_FR').format(widget.date);

    return Scaffold(
      appBar: AppBar(
        title: Text('Ajouter une recette'),
        backgroundColor: const Color(0xFF7C4DFF),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Header with selected meal info
          Container(
            color: const Color(0xFFF3F0F8),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  mealTypeLabel,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF3A1078),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  dateFormatted,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),

          // Recipe list
          Expanded(
            child: recipeProvider.recipes.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: recipeProvider.recipes.length,
                    itemBuilder: (context, index) {
                      final recipe = recipeProvider.recipes[index];
                      final isSelected = _selectedRecipeId == recipe.id;

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedRecipeId = recipe.id;
                            _selectedRecipeName = recipe.name;
                          });
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(
                              color: isSelected
                                  ? const Color(0xFF7C4DFF)
                                  : Colors.grey[300]!,
                              width: isSelected ? 2 : 1,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              // Recipe image or icon
                              Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: recipe.imageUrl != null
                                    ? Image.network(
                                        recipe.imageUrl!,
                                        fit: BoxFit.cover,
                                      )
                                    : Icon(
                                        Icons.restaurant,
                                        color: Colors.grey[400],
                                      ),
                              ),
                              const SizedBox(width: 12),

                              // Recipe info
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      recipe.name,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Icon(Icons.timer_outlined,
                                            size: 14, color: Colors.grey),
                                        const SizedBox(width: 4),
                                        Text(
                                          '${recipe.preparationTime} min',
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Icon(Icons.people_outlined,
                                            size: 14, color: Colors.grey),
                                        const SizedBox(width: 4),
                                        Text(
                                          '${recipe.servings}',
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                              // Selection indicator
                              if (isSelected)
                                const Icon(
                                  Icons.check_circle,
                                  color: Color(0xFF7C4DFF),
                                  size: 24,
                                )
                              else
                                const Icon(
                                  Icons.radio_button_unchecked,
                                  color: Colors.grey,
                                  size: 24,
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),

          // Bottom section with servings and add button
          if (_selectedRecipeId != null)
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border:
                    Border(top: BorderSide(color: Colors.grey[300]!, width: 1)),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Nombre de portions',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline),
                        onPressed: _servings > 1
                            ? () {
                                setState(() => _servings--);
                              }
                            : null,
                      ),
                      Expanded(
                        child: Center(
                          child: Text(
                            _servings.toString(),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline),
                        onPressed: () {
                          setState(() => _servings++);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () => _addOrUpdateMeal(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF7C4DFF),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        widget.mealPlan != null ? 'Modifier' : 'Ajouter',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  void _addOrUpdateMeal() async {
    if (_selectedRecipeId == null || _selectedRecipeName == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez sélectionner une recette')),
      );
      return;
    }

    final mealPlanProvider =
        Provider.of<MealPlanProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    if (authProvider.user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erreur: Utilisateur non trouvé')),
      );
      return;
    }

    if (widget.mealPlan != null) {
      // Update existing meal plan
      final updatedMeal = widget.mealPlan!.copyWith(
        recipeId: _selectedRecipeId,
        recipeName: _selectedRecipeName,
        servings: _servings,
      );

      final success = await mealPlanProvider.updateMealPlan(updatedMeal);
      if (success && mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Repas modifié avec succès')),
        );
      }
    } else {
      // Create new meal plan
      final newMeal = MealPlan(
        id: const Uuid().v4(),
        userId: authProvider.user?.id ?? '',
        date: widget.date,
        mealType: widget.mealType,
        recipeId: _selectedRecipeId,
        recipeName: _selectedRecipeName,
        servings: _servings,
      );

      final success = await mealPlanProvider.addMealPlan(newMeal);
      if (success && mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Repas ajouté avec succès')),
        );
      }
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.restaurant_menu, size: 48, color: Colors.grey[400]),
          const SizedBox(height: 16),
          const Text(
            'Aucune recette disponible',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Ajoutez d\'abord une recette',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  String _getMealTypeLabel(MealType mealType) {
    switch (mealType) {
      case MealType.breakfast:
        return 'Petit Déjeuner';
      case MealType.lunch:
        return 'Déjeuner';
      case MealType.dinner:
        return 'Dîner';
      case MealType.snack:
        return 'Goûter';
    }
  }
}
