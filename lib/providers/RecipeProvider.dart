import 'package:flutter/material.dart';
import '../Models/recipe.dart';
import '../services/RecipeService.dart';

class RecipeProvider with ChangeNotifier {
  final RecipeService _recipeService = RecipeService();

  List<Recipe> _recipes = [];
  bool _isLoading = false;
  String? _error;

  List<Recipe> get recipes => _recipes;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Charger toutes les recettes de Firestore
  Future<void> loadRecipes() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _recipes = await _recipeService.getRecipes();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Ajouter une nouvelle recette
  Future<void> addRecipe(Recipe recipe) async {
    try {
      await _recipeService.addRecipe(recipe);
      _recipes.add(recipe);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  // Mettre à jour une recette
  Future<void> updateRecipe(String id, Recipe updatedRecipe) async {
    try {
      await _recipeService.updateRecipe(id, updatedRecipe);
      int index = _recipes.indexWhere((recipe) => recipe.id == id);
      if (index != -1) {
        _recipes[index] = updatedRecipe;
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
    try {
      await _recipeService.deleteRecipe(id);
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
    try {
      return await _recipeService.getRecipeById(id);
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
