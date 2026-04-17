import 'package:cloud_firestore/cloud_firestore.dart';
import '../Models/ShoppingItem.dart';

class ShoppingListService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get reference to user's shopping list collection
  CollectionReference _getUserShoppingListCollection(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('shopping_list');
  }

  // Add item to shopping list
  Future<void> addShoppingItem(String userId, ShoppingItem item) async {
    try {
      await _getUserShoppingListCollection(
        userId,
      ).doc(item.id).set(item.toMap());
    } catch (e) {
      rethrow;
    }
  }

  // Get all shopping items for user
  Future<List<ShoppingItem>> getShoppingItems(String userId) async {
    try {
      final snapshot = await _getUserShoppingListCollection(
        userId,
      ).orderBy('createdAt', descending: true).get();
      return snapshot.docs
          .map(
            (doc) => ShoppingItem.fromMap({
              'id': doc.id,
              ...doc.data() as Map<String, dynamic>,
            }),
          )
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  // Get unpurchased items
  Future<List<ShoppingItem>> getUnpurchasedItems(String userId) async {
    try {
      final snapshot = await _getUserShoppingListCollection(userId)
          .where('isPurchased', isEqualTo: false)
          .orderBy('createdAt', descending: true)
          .get();
      return snapshot.docs
          .map(
            (doc) => ShoppingItem.fromMap({
              'id': doc.id,
              ...doc.data() as Map<String, dynamic>,
            }),
          )
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  // Update shopping item
  Future<void> updateShoppingItem(
    String userId,
    String itemId,
    ShoppingItem item,
  ) async {
    try {
      await _getUserShoppingListCollection(
        userId,
      ).doc(itemId).update(item.toMap());
    } catch (e) {
      rethrow;
    }
  }

  // Toggle purchased status
  Future<void> togglePurchased(
    String userId,
    String itemId,
    bool isPurchased,
  ) async {
    try {
      await _getUserShoppingListCollection(userId).doc(itemId).update({
        'isPurchased': isPurchased,
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      rethrow;
    }
  }

  // Delete shopping item
  Future<void> deleteShoppingItem(String userId, String itemId) async {
    try {
      await _getUserShoppingListCollection(userId).doc(itemId).delete();
    } catch (e) {
      rethrow;
    }
  }

  // Clear all purchased items
  Future<void> clearPurchasedItems(String userId) async {
    try {
      final snapshot = await _getUserShoppingListCollection(
        userId,
      ).where('isPurchased', isEqualTo: true).get();
      for (var doc in snapshot.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      rethrow;
    }
  }

  // Delete all items (clear entire list)
  Future<void> clearAllItems(String userId) async {
    try {
      final snapshot = await _getUserShoppingListCollection(userId).get();
      for (var doc in snapshot.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      rethrow;
    }
  }

  // Bulk add items (for generating from meal plan)
  Future<void> addMultipleItems(String userId, List<ShoppingItem> items) async {
    try {
      final batch = _firestore.batch();
      for (var item in items) {
        final docRef = _getUserShoppingListCollection(userId).doc(item.id);
        batch.set(docRef, item.toMap());
      }
      await batch.commit();
    } catch (e) {
      rethrow;
    }
  }
}
