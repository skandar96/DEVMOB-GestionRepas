import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'ingredient.dart';

enum RecipeCategory { petitDejeuner, dejeuner, diner, dessert }

enum RecipeDifficulty { facile, moyen, difficile }

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

  Color get color {
    switch (this) {
      case RecipeCategory.petitDejeuner:
        return const Color(0xFFF97316); // Orange
      case RecipeCategory.dejeuner:
        return const Color(0xFF3B82F6); // Blue
      case RecipeCategory.diner:
        return const Color(0xFFEC4899); // Pink
      case RecipeCategory.dessert:
        return const Color(0xFFA855F7); // Purple
    }
  }
}

extension RecipeDifficultyExtension on RecipeDifficulty {
  String get label {
    switch (this) {
      case RecipeDifficulty.facile:
        return 'Facile';
      case RecipeDifficulty.moyen:
        return 'Moyen';
      case RecipeDifficulty.difficile:
        return 'Difficile';
    }
  }
}

class Recipe {
  final String id;
  final String userId; // Liée à l'utilisateur
  final String name;
  final String description;
  final int preparationTime; // en minutes
  final int servings;
  final List<Ingredient> ingredients;
  final List<String> instructions;
  final RecipeCategory category;
  final RecipeDifficulty difficulty;
  final bool isFavorite;
  final String? imageUrl;

  Recipe({
    String? id,
    required this.userId,
    required this.name,
    required this.description,
    required this.preparationTime,
    this.servings = 2,
    required this.ingredients,
    required this.instructions,
    this.category = RecipeCategory.dejeuner,
    this.difficulty = RecipeDifficulty.moyen,
    this.isFavorite = false,
    this.imageUrl,
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'description': description,
      'preparationTime': preparationTime,
      'servings': servings,
      'ingredients': ingredients.map((i) => i.toMap()).toList(),
      'instructions': instructions,
      'category': category.index,
      'difficulty': difficulty.index,
      'isFavorite': isFavorite,
      'imageUrl': imageUrl,
    };
  }

  factory Recipe.fromMap(Map<String, dynamic> map) {
    return Recipe(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      preparationTime: map['preparationTime'] ?? 0,
      servings: map['servings'] ?? 2,
      ingredients:
          (map['ingredients'] as List?)
              ?.map((i) => Ingredient.fromMap(i as Map<String, dynamic>))
              .toList() ??
          [],
      instructions: List<String>.from(map['instructions'] ?? []),
      category: RecipeCategory.values[map['category'] ?? 1],
      difficulty: RecipeDifficulty.values[map['difficulty'] ?? 1],
      isFavorite: map['isFavorite'] ?? false,
      imageUrl: map['imageUrl'],
    );
  }

  Recipe copyWith({
    String? id,
    String? userId,
    String? name,
    String? description,
    int? preparationTime,
    int? servings,
    List<Ingredient>? ingredients,
    List<String>? instructions,
    RecipeCategory? category,
    RecipeDifficulty? difficulty,
    bool? isFavorite,
    String? imageUrl,
  }) {
    return Recipe(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      description: description ?? this.description,
      preparationTime: preparationTime ?? this.preparationTime,
      servings: servings ?? this.servings,
      ingredients: ingredients ?? this.ingredients,
      instructions: instructions ?? this.instructions,
      category: category ?? this.category,
      difficulty: difficulty ?? this.difficulty,
      isFavorite: isFavorite ?? this.isFavorite,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}
