import 'package:flutter/material.dart';
import '../Models/Recipe.dart';
import '../services/RecipeService.dart';

class RecipeProvider with ChangeNotifier {
  final RecipeService _recipeService = RecipeService();
  late String _userId;

  List<Recipe> _recipes = [];
  bool _isLoading = false;
  String? _error;

  List<Recipe> get recipes => _recipes;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Initialiser le provider avec l'userId
  void setUserId(String userId) {
    _userId = userId;
    _recipes = [];
    notifyListeners();
  }

  // Charger toutes les recettes de l'utilisateur
  Future<void> loadRecipes() async {
    if (_userId.isEmpty) {
      _error = 'User ID is required';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _recipes = await _recipeService.getRecipes(_userId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Ajouter une nouvelle recette
  Future<void> addRecipe(Recipe recipe) async {
    if (_userId.isEmpty) {
      _error = 'User ID is required';
      notifyListeners();
      return;
    }

    try {
      // Créer une nouvelle recette avec l'userId
      final recipeWithUser = Recipe(
        id: recipe.id,
        userId: _userId,
        name: recipe.name,
        description: recipe.description,
        preparationTime: recipe.preparationTime,
        servings: recipe.servings,
        ingredients: recipe.ingredients,
        instructions: recipe.instructions,
        category: recipe.category,
        difficulty: recipe.difficulty,
        isFavorite: recipe.isFavorite,
        imageUrl: recipe.imageUrl,
      );
      await _recipeService.addRecipe(_userId, recipeWithUser);
      _recipes.add(recipeWithUser);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  // Mettre à jour une recette
  Future<void> updateRecipe(String id, Recipe updatedRecipe) async {
    if (_userId.isEmpty) {
      _error = 'User ID is required';
      notifyListeners();
      return;
    }

    try {
      // Créer une recette mise à jour avec l'userId
      final recipeWithUser = Recipe(
        id: updatedRecipe.id,
        userId: _userId,
        name: updatedRecipe.name,
        description: updatedRecipe.description,
        preparationTime: updatedRecipe.preparationTime,
        servings: updatedRecipe.servings,
        ingredients: updatedRecipe.ingredients,
        instructions: updatedRecipe.instructions,
        category: updatedRecipe.category,
        difficulty: updatedRecipe.difficulty,
        isFavorite: updatedRecipe.isFavorite,
        imageUrl: updatedRecipe.imageUrl,
      );
      await _recipeService.updateRecipe(_userId, id, recipeWithUser);
      int index = _recipes.indexWhere((recipe) => recipe.id == id);
      if (index != -1) {
        _recipes[index] = recipeWithUser;
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  // Supprimer une recette
  Future<void> deleteRecipe(String id) async {
    if (_userId.isEmpty) {
      _error = 'User ID is required';
      notifyListeners();
      return;
    }

    try {
      await _recipeService.deleteRecipe(_userId, id);
      _recipes.removeWhere((recipe) => recipe.id == id);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  // Récupérer une recette par ID
  Future<Recipe?> getRecipeById(String id) async {
    if (_userId.isEmpty) {
      _error = 'User ID is required';
      notifyListeners();
      return null;
    }

    try {
      return await _recipeService.getRecipeById(_userId, id);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
