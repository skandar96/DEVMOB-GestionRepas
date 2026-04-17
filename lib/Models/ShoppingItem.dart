import 'package:uuid/uuid.dart';

class ShoppingItem {
  final String id;
  final String userId;
  final String name;
  final double quantity;
  final String unit; // "kg", "g", "ml", "l", "pièce", etc.
  final bool isPurchased;
  final String? category; // "Fruits", "Légumes", "Viande", etc.
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
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : id = id ?? const Uuid().v4(),
       createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

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
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'ShoppingItem(id: $id, name: $name, quantity: $quantity, unit: $unit, isPurchased: $isPurchased)';
  }
}
