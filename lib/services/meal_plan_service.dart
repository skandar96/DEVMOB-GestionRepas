import 'package:cloud_firestore/cloud_firestore.dart';
import '../Models/meal_plan.dart';

class MealPlanService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String _dateQueryValue(DateTime date) => date.toIso8601String();

  // Add a meal plan
  Future<bool> addMealPlan(MealPlan mealPlan) async {
    try {
      await _firestore
          .collection('users')
          .doc(mealPlan.userId)
          .collection('meal_plans')
          .doc(mealPlan.id)
          .set(mealPlan.toJson());
      return true;
    } catch (e) {
      print("Error adding meal plan: $e");
      rethrow;
    }
  }

  // Delete a meal plan for a specific user (subcollection)
  Future<bool> deleteMealPlanForUser(String userId, String mealPlanId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('meal_plans')
          .doc(mealPlanId)
          .delete();
      return true;
    } catch (e) {
      print("Error deleting meal plan for user: $e");
      rethrow;
    }
  }

  // Update a meal plan
  Future<bool> updateMealPlan(MealPlan mealPlan) async {
    try {
      await _firestore
          .collection('users')
          .doc(mealPlan.userId)
          .collection('meal_plans')
          .doc(mealPlan.id)
          .update(mealPlan.toJson());
      return true;
    } catch (e) {
      print("Error updating meal plan: $e");
      rethrow;
    }
  }

  // Delete a meal plan
  Future<bool> deleteMealPlan(String mealPlanId) async {
    try {
      // This method requires userId context; caller should delete via the user's subcollection.
      // Keep backward-compatibility by attempting to delete from any matching document in collectionGroup.
      final query = await _firestore
          .collectionGroup('meal_plans')
          .where('id', isEqualTo: mealPlanId)
          .limit(1)
          .get();
      if (query.docs.isNotEmpty) {
        await query.docs.first.reference.delete();
      }
      return true;
    } catch (e) {
      print("Error deleting meal plan: $e");
      rethrow;
    }
  }

  // Get meal plans for a specific week
  Future<List<MealPlan>> getMealPlansForWeek(
    String userId,
    DateTime weekStart,
  ) async {
    try {
      DateTime weekEnd = weekStart.add(const Duration(days: 7));

      final querySnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('meal_plans')
          .where(
            'date',
            isGreaterThanOrEqualTo: _dateQueryValue(weekStart),
            isLessThan: _dateQueryValue(weekEnd),
          )
          .get();

      return querySnapshot.docs
          .map((doc) => MealPlan.fromJson(doc.data()))
          .toList();
    } catch (e) {
      print("Error fetching meal plans: $e");
      rethrow;
    }
  }

  // Get meal plans for a specific date
  Future<List<MealPlan>> getMealPlansForDate(
    String userId,
    DateTime date,
  ) async {
    try {
      DateTime nextDay = DateTime(date.year, date.month, date.day + 1);

      final querySnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('meal_plans')
          .where(
            'date',
            isGreaterThanOrEqualTo: _dateQueryValue(date),
            isLessThan: _dateQueryValue(nextDay),
          )
          .get();

      return querySnapshot.docs
          .map((doc) => MealPlan.fromJson(doc.data()))
          .toList();
    } catch (e) {
      print("Error fetching meal plans for date: $e");
      rethrow;
    }
  }

  // Get meal plan for a specific meal type on a specific date
  Future<MealPlan?> getMealPlanForMealType(
    String userId,
    DateTime date,
    MealType mealType,
  ) async {
    try {
      DateTime nextDay = DateTime(date.year, date.month, date.day + 1);

      final querySnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('meal_plans')
          .where(
            'date',
            isGreaterThanOrEqualTo: _dateQueryValue(date),
            isLessThan: _dateQueryValue(nextDay),
          )
          .where('mealType', isEqualTo: mealType.toString())
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return MealPlan.fromJson(querySnapshot.docs.first.data());
      }
      return null;
    } catch (e) {
      print("Error fetching meal plan for meal type: $e");
      rethrow;
    }
  }
}
