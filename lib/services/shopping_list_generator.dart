import '../Models/ShoppingItem.dart';
import '../Models/ingredient.dart';

class ShoppingListGenerator {
  /// Convertit une liste d'ingrédients avec mealType en articles de shopping
  /// Agrège les ingrédients par nom et mealType, additionne les quantités,
  /// et conserve l'état d'achat existant si la ligne correspond toujours.
  static List<ShoppingItem> generateFromIngredientsWithMealType(
    List<Map<String, dynamic>> ingredientsWithMealType,
    String userId, {
    String Function(String)? categoryMapper,
    List<ShoppingItem>? existingItems,
  }) {
    final existingItemsByKey = <String, ShoppingItem>{};
    for (final item in existingItems ?? const <ShoppingItem>[]) {
      final key = _buildItemKey(item.name, item.unit, item.mealType);
      final current = existingItemsByKey[key];
      if (current == null || (!current.isPurchased && item.isPurchased)) {
        existingItemsByKey[key] = item;
      }
    }

    // Grouper les ingrédients par nom et mealType (insensible à la casse)
    final Map<String, Map<String, dynamic>> aggregated = {};

    for (final data in ingredientsWithMealType) {
      final ingredient = data['ingredient'] as Ingredient;
      final mealType = data['mealType'] as int;
      final recipeServings = data['recipeServings'] as int? ?? 1;
      final plannedServings = data['plannedServings'] as int? ?? 1;
      final mealPlanId = data['mealPlanId'] as String?;
      final key = '${ingredient.name.toLowerCase().trim()}_$mealType';
      final scaledQuantity = _scaleQuantity(
        ingredient.quantity,
        recipeServings,
        plannedServings,
      );

      if (aggregated.containsKey(key)) {
        // Si l'ingrédient existe déjà, additionner les quantités
        final existing = aggregated[key]!;
        final existingQty =
            double.tryParse(existing['quantity'] as String) ?? 1.0;
        final newQty = scaledQuantity;

        // Si les unités sont les mêmes, additionner
        if (existing['unit'] == ingredient.unit) {
          existing['quantity'] = _formatQuantity(existingQty + newQty);
          final sourceMealPlanIds =
              existing['sourceMealPlanIds'] as Set<String>;
          if (mealPlanId != null) {
            sourceMealPlanIds.add(mealPlanId);
          }
        } else {
          // Si les unités sont différentes, créer un nouvel article
          aggregated['${key}_${ingredient.unit}'] = {
            'name': ingredient.name,
            'quantity': _formatQuantity(newQty),
            'unit': ingredient.unit,
            'mealType': mealType,
            'sourceMealPlanIds': <String>{if (mealPlanId != null) mealPlanId},
          };
        }
      } else {
        aggregated[key] = {
          'name': ingredient.name,
          'quantity': _formatQuantity(scaledQuantity),
          'unit': ingredient.unit,
          'mealType': mealType,
          'sourceMealPlanIds': <String>{if (mealPlanId != null) mealPlanId},
        };
      }
    }

    // Convertir en ShoppingItems
    final shoppingItems = <ShoppingItem>[];
    for (final entry in aggregated.entries) {
      final data = entry.value;
      final quantity = double.tryParse(data['quantity'] as String) ?? 1.0;
      final itemKey = _buildItemKey(
        data['name'] as String,
        data['unit'] as String,
        data['mealType'] as int?,
      );
      final existingItem = existingItemsByKey[itemKey];
      final sourceMealPlanIds =
          (data['sourceMealPlanIds'] as Set<String>).toList()..sort();

      // Déterminer la catégorie
      String category = 'Autres';
      if (categoryMapper != null) {
        category = categoryMapper(data['name'] as String);
      }

      shoppingItems.add(
        ShoppingItem(
          id: existingItem?.id,
          userId: userId,
          name: data['name'] as String,
          quantity: quantity,
          unit: data['unit'] as String,
          category: category,
          mealType: data['mealType'] as int,
          sourceMealPlanIds: sourceMealPlanIds.isEmpty
              ? null
              : sourceMealPlanIds,
          isPurchased: existingItem?.isPurchased ?? false,
          createdAt: existingItem?.createdAt,
          updatedAt: existingItem?.updatedAt,
        ),
      );
    }

    return shoppingItems;
  }

  /// Convertit une liste d'ingrédients en articles de shopping
  /// Agrège les ingrédients par nom et additionne les quantités
  static List<ShoppingItem> generateFromIngredients(
    List<Ingredient> ingredients,
    String userId, {
    String Function(String)? categoryMapper,
  }) {
    // Grouper les ingrédients par nom (insensible à la casse)
    final Map<String, Map<String, dynamic>> aggregated = {};

    for (final ingredient in ingredients) {
      final key = ingredient.name.toLowerCase().trim();

      if (aggregated.containsKey(key)) {
        // Si l'ingrédient existe déjà, additionner les quantités
        final existing = aggregated[key]!;
        final existingQty =
            double.tryParse(existing['quantity'] as String) ?? 1.0;
        final newQty = double.tryParse(ingredient.quantity) ?? 1.0;

        // Si les unités sont les mêmes, additionner
        if (existing['unit'] == ingredient.unit) {
          existing['quantity'] = (existingQty + newQty).toString();
        } else {
          // Si les unités sont différentes, créer un nouvel article
          aggregated['${key}_${ingredient.unit}'] = {
            'name': ingredient.name,
            'quantity': ingredient.quantity,
            'unit': ingredient.unit,
          };
        }
      } else {
        aggregated[key] = {
          'name': ingredient.name,
          'quantity': ingredient.quantity,
          'unit': ingredient.unit,
        };
      }
    }

    // Convertir en ShoppingItems
    final shoppingItems = <ShoppingItem>[];
    for (final entry in aggregated.entries) {
      final data = entry.value;
      final quantity = double.tryParse(data['quantity'] as String) ?? 1.0;

      // Déterminer la catégorie
      String category = 'Autres';
      if (categoryMapper != null) {
        category = categoryMapper(data['name'] as String);
      }

      shoppingItems.add(
        ShoppingItem(
          userId: userId,
          name: data['name'] as String,
          quantity: quantity,
          unit: data['unit'] as String,
          category: category,
          isPurchased: false,
        ),
      );
    }

    return shoppingItems;
  }

  static String _buildItemKey(String name, String unit, int? mealType) {
    return '${name.toLowerCase().trim()}|${unit.toLowerCase().trim()}|${mealType ?? -1}';
  }

  static double _scaleQuantity(
    String quantity,
    int recipeServings,
    int plannedServings,
  ) {
    final baseQuantity = double.tryParse(quantity.replaceAll(',', '.')) ?? 1.0;
    final sourceServings = recipeServings <= 0 ? 1 : recipeServings;
    final targetServings = plannedServings <= 0 ? 1 : plannedServings;
    return baseQuantity * targetServings / sourceServings;
  }

  static String _formatQuantity(double quantity) {
    if (quantity == quantity.roundToDouble()) {
      return quantity.toInt().toString();
    }

    return quantity
        .toStringAsFixed(2)
        .replaceAll(RegExp(r'0+$'), '')
        .replaceAll(RegExp(r'\.$'), '');
  }

  /// Catégorise un ingrédient automatiquement basé sur son nom
  static String categorizeIngredient(String ingredientName) {
    final name = ingredientName.toLowerCase();

    // Fruits
    if (_matchesPattern(name, [
      'pomme',
      'banane',
      'orange',
      'citron',
      'fraise',
      'raisin',
      'mangue',
      'ananas',
      'pêche',
      'poire',
      'kiwi',
      'melon',
      'pastèque',
      'cerise',
    ])) {
      return 'Fruits';
    }

    // Légumes
    if (_matchesPattern(name, [
      'carotte',
      'tomate',
      'oignon',
      'ail',
      'poivron',
      'courgette',
      'aubergine',
      'brocoli',
      'chou',
      'épinard',
      'laitue',
      'roquette',
      'champignon',
      'courge',
      'haricot',
      'petits pois',
      'salade',
      'concombre',
      'betterave',
    ])) {
      return 'Légumes';
    }

    // Viande
    if (_matchesPattern(name, [
      'poulet',
      'boeuf',
      'steak',
      'veau',
      'agneau',
      'côte',
      'jambon',
      'bacon',
      'saucisse',
      'viande hachée',
      'escalope',
      'côtelette',
      'filet',
    ])) {
      return 'Viande';
    }

    // Poisson
    if (_matchesPattern(name, [
      'saumon',
      'trout',
      'bar',
      'cabillaud',
      'morue',
      'dorade',
      'turbot',
      'thon',
      'sardine',
      'anchois',
      'crevette',
      'huître',
      'moule',
      'calmar',
    ])) {
      return 'Poisson';
    }

    // Produits laitiers
    if (_matchesPattern(name, [
      'fromage',
      'lait',
      'crème',
      'yaourt',
      'yourt',
      'fromage blanc',
      'ricotta',
      'mozzarella',
      'cheddar',
      'camembert',
      'beurre',
      'crème fraîche',
    ])) {
      return 'Produits laitiers';
    }

    // Œufs
    if (_matchesPattern(name, ['oeuf', 'oeuf', 'œuf', 'œufs', 'oeuffs'])) {
      return 'Œufs';
    }

    // Pain & Céréales
    if (_matchesPattern(name, [
      'pain',
      'riz',
      'pâtes',
      'pâte',
      'farine',
      'blé',
      'flocons',
      'müesli',
      'céréales',
      'spaghetti',
      'macaroni',
      'fusilli',
      'tagliatelle',
    ])) {
      return 'Pain & Céréales';
    }

    // Épicerie
    if (_matchesPattern(name, [
      'sucre',
      'sel',
      'poivre',
      'huile',
      'vinaigre',
      'sauce',
      'épice',
      'cacao',
      'chocolat',
      'miel',
      'moutarde',
      'ketchup',
      'mayonnaise',
      'confiture',
    ])) {
      return 'Épicerie';
    }

    // Boissons
    if (_matchesPattern(name, [
      'eau',
      'jus',
      'lait',
      'café',
      'thé',
      'sodas',
      'soda',
      'vin',
      'bière',
      'champagne',
      'cidre',
    ])) {
      return 'Boissons';
    }

    return 'Autres';
  }

  /// Vérifie si le nom contient l'un des patterns
  static bool _matchesPattern(String name, List<String> patterns) {
    return patterns.any((pattern) => name.contains(pattern));
  }
}
