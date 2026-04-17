import 'package:flutter/foundation.dart';
import '../Models/ShoppingItem.dart';
import '../services/ShoppingListService.dart';

class ShoppingListProvider with ChangeNotifier {
  final ShoppingListService _shoppingListService = ShoppingListService();
  late String _userId;

  List<ShoppingItem> _shoppingItems = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<ShoppingItem> get shoppingItems => _shoppingItems;
  List<ShoppingItem> get unpurchasedItems =>
      _shoppingItems.where((item) => !item.isPurchased).toList();
  List<ShoppingItem> get purchasedItems =>
      _shoppingItems.where((item) => item.isPurchased).toList();
  bool get isLoading => _isLoading;
  String? get error => _error;

  int get totalItems => _shoppingItems.length;
  int get purchasedCount => purchasedItems.length;
  int get unpurchasedCount => unpurchasedItems.length;

  // Initialize with user ID
  void setUserId(String userId) {
    _userId = userId;
    _shoppingItems = [];
    notifyListeners();
  }

  // Load shopping items
  Future<void> loadShoppingItems() async {
    if (_userId.isEmpty) {
      _error = 'User ID is required';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _shoppingItems = await _shoppingListService.getShoppingItems(_userId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add item to shopping list
  Future<void> addItem(ShoppingItem item) async {
    if (_userId.isEmpty) {
      _error = 'User ID is required';
      notifyListeners();
      return;
    }

    try {
      final newItem = item.copyWith(userId: _userId);
      await _shoppingListService.addShoppingItem(_userId, newItem);
      _shoppingItems.insert(0, newItem); // Add to top of list
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  // Update item
  Future<void> updateItem(ShoppingItem item) async {
    if (_userId.isEmpty) {
      _error = 'User ID is required';
      notifyListeners();
      return;
    }

    try {
      await _shoppingListService.updateShoppingItem(_userId, item.id, item);
      int index = _shoppingItems.indexWhere((i) => i.id == item.id);
      if (index != -1) {
        _shoppingItems[index] = item;
      }
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  // Toggle purchased status
  Future<void> togglePurchased(String itemId, bool isPurchased) async {
    if (_userId.isEmpty) {
      _error = 'User ID is required';
      notifyListeners();
      return;
    }

    try {
      await _shoppingListService.togglePurchased(_userId, itemId, isPurchased);
      int index = _shoppingItems.indexWhere((i) => i.id == itemId);
      if (index != -1) {
        _shoppingItems[index] = _shoppingItems[index].copyWith(
          isPurchased: isPurchased,
        );
      }
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  // Delete item
  Future<void> deleteItem(String itemId) async {
    if (_userId.isEmpty) {
      _error = 'User ID is required';
      notifyListeners();
      return;
    }

    try {
      await _shoppingListService.deleteShoppingItem(_userId, itemId);
      _shoppingItems.removeWhere((item) => item.id == itemId);
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  // Clear all purchased items
  Future<void> clearPurchasedItems() async {
    if (_userId.isEmpty) {
      _error = 'User ID is required';
      notifyListeners();
      return;
    }

    try {
      await _shoppingListService.clearPurchasedItems(_userId);
      _shoppingItems.removeWhere((item) => item.isPurchased);
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  // Clear all items
  Future<void> clearAllItems() async {
    if (_userId.isEmpty) {
      _error = 'User ID is required';
      notifyListeners();
      return;
    }

    try {
      await _shoppingListService.clearAllItems(_userId);
      _shoppingItems.clear();
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  // Add multiple items (from meal plan)
  Future<void> addMultipleItems(List<ShoppingItem> items) async {
    if (_userId.isEmpty) {
      _error = 'User ID is required';
      notifyListeners();
      return;
    }

    try {
      final itemsWithUserId = items
          .map((item) => item.copyWith(userId: _userId))
          .toList();
      await _shoppingListService.addMultipleItems(_userId, itemsWithUserId);
      _shoppingItems.insertAll(0, itemsWithUserId);
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
