import 'package:uuid/uuid.dart';

enum RecipeCategory { petitDejeuner, dejeuner, diner, dessert }

extension RecipeCategoryExtension on RecipeCategory {
  String get label {
    switch (this) {
      case RecipeCategory.petitDejeuner:
        return 'Petit Déjeuner';
      case RecipeCategory.dejeuner:
        return 'Déjeuner';
      case RecipeCategory.diner:
        return 'Dîner';
      case RecipeCategory.dessert:
        return 'Dessert';
    }
  }

  String get colorCode {
    switch (this) {
      case RecipeCategory.petitDejeuner:
        return '#6366F1'; // Indigo
      case RecipeCategory.dejeuner:
        return '#F97316'; // Orange
      case RecipeCategory.diner:
        return '#EC4899'; // Pink
      case RecipeCategory.dessert:
        return '#8B5CF6'; // Purple
    }
  }
}

class Recipe {
  final String id;
  final String title;
  final String description;
  final int prepTime; // en minutes
  final int portions;
  final List<String> ingredients;
  final List<String> steps;
  final RecipeCategory category;

  Recipe({
    String? id,
    required this.title,
    required this.description,
    required this.prepTime,
    this.portions = 2,
    required this.ingredients,
    required this.steps,
    this.category = RecipeCategory.dejeuner,
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'prepTime': prepTime,
      'portions': portions,
      'ingredients': ingredients,
      'steps': steps,
      'category': category.toString(),
    };
  }

  factory Recipe.fromMap(Map<String, dynamic> map) {
    return Recipe(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      prepTime: map['prepTime'] ?? 0,
      portions: map['portions'] ?? 2,
      ingredients: List<String>.from(map['ingredients'] ?? []),
      steps: List<String>.from(map['steps'] ?? []),
      category: RecipeCategory.values[int.parse(map['category'] ?? '1')],
    );
  }

  Recipe copyWith({
    String? id,
    String? title,
    String? description,
    int? prepTime,
    int? portions,
    List<String>? ingredients,
    List<String>? steps,
    RecipeCategory? category,
  }) {
    return Recipe(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      prepTime: prepTime ?? this.prepTime,
      portions: portions ?? this.portions,
      ingredients: ingredients ?? this.ingredients,
      steps: steps ?? this.steps,
      category: category ?? this.category,
    );
  }
}
