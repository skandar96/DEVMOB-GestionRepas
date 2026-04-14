import 'package:flutter/foundation.dart';
import '../Models/meal_plan.dart';
import '../services/meal_plan_service.dart';

class MealPlanProvider with ChangeNotifier {
  final MealPlanService _mealPlanService = MealPlanService();

  List<MealPlan> _mealPlans = [];
  bool _isLoading = false;
  String _error = '';
  DateTime _selectedWeekStart = DateTime.now();

  // Getters
  List<MealPlan> get mealPlans => _mealPlans;
  bool get isLoading => _isLoading;
  String get error => _error;
  DateTime get selectedWeekStart => _selectedWeekStart;

  // Helper getter for the end of week
  DateTime get selectedWeekEnd =>
      _selectedWeekStart.add(const Duration(days: 6));

  // Setters
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String message) {
    _error = message;
    notifyListeners();
  }

  void clearError() {
    _error = '';
    notifyListeners();
  }

  // Set week
  void setWeekStart(DateTime date) {
    // Get Monday of the week
    DateTime monday = date.subtract(Duration(days: date.weekday - 1));
    _selectedWeekStart = DateTime(monday.year, monday.month, monday.day);
    notifyListeners();
  }

  // Move to next week
  void nextWeek() {
    _selectedWeekStart = _selectedWeekStart.add(const Duration(days: 7));
    notifyListeners();
  }

  // Move to previous week
  void previousWeek() {
    _selectedWeekStart = _selectedWeekStart.subtract(const Duration(days: 7));
    notifyListeners();
  }

  // Fetch meal plans for selected week
  Future<void> fetchMealPlansForWeek(String userId) async {
    _setLoading(true);
    try {
      _mealPlans =
          await _mealPlanService.getMealPlansForWeek(userId, _selectedWeekStart);
      _setError('');
    } catch (e) {
      _setError("Error loading meal plans: $e");
    }
    _setLoading(false);
  }

  // Add meal plan
  Future<bool> addMealPlan(MealPlan mealPlan) async {
    _setLoading(true);
    try {
      await _mealPlanService.addMealPlan(mealPlan);
      _mealPlans.add(mealPlan);
      notifyListeners();
      return true;
    } catch (e) {
      _setError("Error adding meal plan: $e");
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Update meal plan
  Future<bool> updateMealPlan(MealPlan mealPlan) async {
    _setLoading(true);
    try {
      await _mealPlanService.updateMealPlan(mealPlan);
      int index = _mealPlans.indexWhere((m) => m.id == mealPlan.id);
      if (index != -1) {
        _mealPlans[index] = mealPlan;
      }
      notifyListeners();
      return true;
    } catch (e) {
      _setError("Error updating meal plan: $e");
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Delete meal plan
  Future<bool> deleteMealPlan(String mealPlanId) async {
    _setLoading(true);
    try {
      await _mealPlanService.deleteMealPlan(mealPlanId);
      _mealPlans.removeWhere((m) => m.id == mealPlanId);
      notifyListeners();
      return true;
    } catch (e) {
      _setError("Error deleting meal plan: $e");
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Get meals for a specific date
  List<MealPlan> getMealsForDate(DateTime date) {
    return _mealPlans.where((meal) {
      return meal.date.year == date.year &&
          meal.date.month == date.month &&
          meal.date.day == date.day;
    }).toList();
  }

  // Get meal for a specific date and meal type
  MealPlan? getMealForDateAndType(DateTime date, MealType mealType) {
    try {
      return _mealPlans.firstWhere((meal) {
        return meal.date.year == date.year &&
            meal.date.month == date.month &&
            meal.date.day == date.day &&
            meal.mealType == mealType;
      });
    } catch (e) {
      return null;
    }
  }
}
