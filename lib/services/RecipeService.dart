import 'package:cloud_firestore/cloud_firestore.dart';
import '../Models/recipe.dart';

class RecipeService {
  final CollectionReference _recipesCollection = FirebaseFirestore.instance
      .collection('recipes');

  Future<void> addRecipe(Recipe recipe) async {
    try {
      await _recipesCollection.doc(recipe.id).set(recipe.toMap());
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Recipe>> getRecipes() async {
    try {
      QuerySnapshot snapshot = await _recipesCollection.get();
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

  Future<Recipe?> getRecipeById(String id) async {
    try {
      DocumentSnapshot doc = await _recipesCollection.doc(id).get();
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

  Future<void> updateRecipe(String id, Recipe recipe) async {
    try {
      await _recipesCollection.doc(id).update(recipe.toMap());
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteRecipe(String id) async {
    try {
      await _recipesCollection.doc(id).delete();
    } catch (e) {
      rethrow;
    }
  }
}
