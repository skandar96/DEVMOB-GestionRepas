import 'package:cloud_firestore/cloud_firestore.dart';
import '../Models/meal_plan.dart';

class MealPlanService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Add a meal plan
  Future<bool> addMealPlan(MealPlan mealPlan) async {
    try {
      await _firestore
          .collection('meal_plans')
          .doc(mealPlan.id)
          .set(mealPlan.toJson());
      return true;
    } catch (e) {
      print("Error adding meal plan: $e");
      rethrow;
    }
  }

  // Update a meal plan
  Future<bool> updateMealPlan(MealPlan mealPlan) async {
    try {
      await _firestore
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
      await _firestore.collection('meal_plans').doc(mealPlanId).delete();
      return true;
    } catch (e) {
      print("Error deleting meal plan: $e");
      rethrow;
    }
  }

  // Get meal plans for a specific week
  Future<List<MealPlan>> getMealPlansForWeek(
      String userId, DateTime weekStart) async {
    try {
      DateTime weekEnd = weekStart.add(const Duration(days: 7));

      final querySnapshot = await _firestore
          .collection('meal_plans')
          .where('userId', isEqualTo: userId)
          .where('date',
              isGreaterThanOrEqualTo: weekStart,
              isLessThan: weekEnd)
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
      String userId, DateTime date) async {
    try {
      DateTime nextDay = DateTime(date.year, date.month, date.day + 1);

      final querySnapshot = await _firestore
          .collection('meal_plans')
          .where('userId', isEqualTo: userId)
          .where('date', isGreaterThanOrEqualTo: date, isLessThan: nextDay)
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
      String userId, DateTime date, MealType mealType) async {
    try {
      DateTime nextDay = DateTime(date.year, date.month, date.day + 1);

      final querySnapshot = await _firestore
          .collection('meal_plans')
          .where('userId', isEqualTo: userId)
          .where('date', isGreaterThanOrEqualTo: date, isLessThan: nextDay)
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
