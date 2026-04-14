enum MealType { breakfast, lunch, dinner, snack }

class MealPlan {
  final String id;
  final String userId;
  final DateTime date;
  final MealType mealType;
  final String? recipeId;
  final String? recipeName;
  final int servings;

  MealPlan({
    required this.id,
    required this.userId,
    required this.date,
    required this.mealType,
    this.recipeId,
    this.recipeName,
    this.servings = 1,
  });

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'date': date.toIso8601String(),
      'mealType': mealType.toString(),
      'recipeId': recipeId,
      'recipeName': recipeName,
      'servings': servings,
    };
  }

  // Create from JSON
  factory MealPlan.fromJson(Map<String, dynamic> json) {
    return MealPlan(
      id: json['id'] as String,
      userId: json['userId'] as String,
      date: DateTime.parse(json['date'] as String),
      mealType: MealType.values.firstWhere(
        (e) => e.toString() == json['mealType'],
        orElse: () => MealType.breakfast,
      ),
      recipeId: json['recipeId'] as String?,
      recipeName: json['recipeName'] as String?,
      servings: json['servings'] as int? ?? 1,
    );
  }

  // Copy with method
  MealPlan copyWith({
    String? id,
    String? userId,
    DateTime? date,
    MealType? mealType,
    String? recipeId,
    String? recipeName,
    int? servings,
  }) {
    return MealPlan(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      date: date ?? this.date,
      mealType: mealType ?? this.mealType,
      recipeId: recipeId ?? this.recipeId,
      recipeName: recipeName ?? this.recipeName,
      servings: servings ?? this.servings,
    );
  }
}
