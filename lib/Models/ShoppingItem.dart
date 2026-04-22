import 'package:uuid/uuid.dart';
import 'Recipe.dart';

class ShoppingItem {
  final String id;
  final String userId;
  final String name;
  final double quantity;
  final String unit; // "kg", "g", "ml", "l", "pièce", etc.
  final bool isPurchased;
  final String? category; // "Fruits", "Légumes", "Viande", etc.
  final int? mealType; // 0 = petitDejeuner, 1 = dejeuner, 2 = diner
  final DateTime createdAt;
  final DateTime updatedAt;

  ShoppingItem({
    String? id,
    required this.userId,
    required this.name,
    required this.quantity,
    required this.unit,
    this.isPurchased = false,
    this.category,
    this.mealType,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : id = id ?? const Uuid().v4(),
       createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  // Get mealType as RecipeCategory enum
  RecipeCategory? get mealTypeCategory {
    if (mealType == null) return null;
    return RecipeCategory.values[mealType!];
  }

  // Get meal type label with emoji
  String get mealTypeLabel {
    switch (mealTypeCategory) {
      case RecipeCategory.petitDejeuner:
        return 'Petit déjeuner ☀️';
      case RecipeCategory.dejeuner:
        return 'Déjeuner 🍽️';
      case RecipeCategory.diner:
        return 'Dîner 🌙';
      default:
        return 'Non spécifié';
    }
  }

  // Convert to JSON for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'quantity': quantity,
      'unit': unit,
      'isPurchased': isPurchased,
      'category': category,
      'mealType': mealType,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // Create from JSON (from Firestore)
  factory ShoppingItem.fromMap(Map<String, dynamic> map) {
    return ShoppingItem(
      id: map['id'] as String,
      userId: map['userId'] as String,
      name: map['name'] as String,
      quantity: (map['quantity'] as num).toDouble(),
      unit: map['unit'] as String,
      isPurchased: map['isPurchased'] as bool? ?? false,
      category: map['category'] as String?,
      mealType: map['mealType'] as int?,
      createdAt: DateTime.parse(
        map['createdAt'] as String? ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        map['updatedAt'] as String? ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  // Copy with method
  ShoppingItem copyWith({
    String? id,
    String? userId,
    String? name,
    double? quantity,
    String? unit,
    bool? isPurchased,
    String? category,
    int? mealType,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ShoppingItem(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      isPurchased: isPurchased ?? this.isPurchased,
      category: category ?? this.category,
      mealType: mealType ?? this.mealType,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'ShoppingItem(id: $id, name: $name, quantity: $quantity, unit: $unit, isPurchased: $isPurchased)';
  }
}
