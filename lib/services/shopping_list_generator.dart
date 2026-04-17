import '../Models/ShoppingItem.dart';
import '../Models/ingredient.dart';

class ShoppingListGenerator {
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
