import 'package:cloud_firestore/cloud_firestore.dart';
import '../Models/recipe.dart';

class RecipeService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Obtenir la collection de recettes d'un utilisateur
  CollectionReference _getUserRecipesCollection(String userId) {
    return _firestore.collection('users').doc(userId).collection('recipes');
  }

  Future<void> addRecipe(String userId, Recipe recipe) async {
    try {
      await _getUserRecipesCollection(
        userId,
      ).doc(recipe.id).set(recipe.toMap());
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Recipe>> getRecipes(String userId) async {
    try {
      QuerySnapshot snapshot = await _getUserRecipesCollection(userId).get();
      return snapshot.docs
          .map(
            (doc) => Recipe.fromMap({
              'id': doc.id,
              ...doc.data() as Map<String, dynamic>,
            }),
          )
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<Recipe?> getRecipeById(String userId, String recipeId) async {
    try {
      DocumentSnapshot doc = await _getUserRecipesCollection(
        userId,
      ).doc(recipeId).get();
      if (doc.exists) {
        return Recipe.fromMap({
          'id': doc.id,
          ...doc.data() as Map<String, dynamic>,
        });
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateRecipe(
    String userId,
    String recipeId,
    Recipe recipe,
  ) async {
    try {
      await _getUserRecipesCollection(
        userId,
      ).doc(recipeId).update(recipe.toMap());
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteRecipe(String userId, String recipeId) async {
    try {
      await _getUserRecipesCollection(userId).doc(recipeId).delete();
    } catch (e) {
      rethrow;
    }
  }
}
