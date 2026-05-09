import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/ShoppingListProvider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/RecipeProvider.dart';
import '../../providers/meal_plan_provider.dart';
import '../../Models/ShoppingItem.dart';
import '../../Models/Recipe.dart';
import '../../services/shopping_list_generator.dart';

class ShoppingListPage extends StatefulWidget {
  const ShoppingListPage({super.key});

  @override
  State<ShoppingListPage> createState() => _ShoppingListPageState();
}

class _ShoppingListPageState extends State<ShoppingListPage> {
  late TextEditingController _itemNameController;
  late TextEditingController _quantityController;
  late TextEditingController _searchController;
  MealPlanProvider? _mealPlanProvider;
  RecipeProvider? _recipeProvider;
  bool _isAutoSyncing = false;
  String _lastSyncSignature = '';
  String _selectedUnit = 'pièce';
  String _selectedCategory = 'Autres';

  final List<String> _units = [
    'pièce',
    'g',
    'kg',
    'ml',
    'l',
    'verre',
    'cuillère',
    'paquet',
    'boîte',
  ];

  final List<String> _categories = [
    'Fruits',
    'Légumes',
    'Viande',
    'Poisson',
    'Produits laitiers',
    'Œufs',
    'Pain & Céréales',
    'Épicerie',
    'Boissons',
    'Autres',
  ];

  @override
  void initState() {
    super.initState();
    _itemNameController = TextEditingController();
    _quantityController = TextEditingController(text: '1');
    _searchController = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final shoppingProvider = Provider.of<ShoppingListProvider>(
        context,
        listen: false,
      );
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      _mealPlanProvider = Provider.of<MealPlanProvider>(context, listen: false);
      _recipeProvider = Provider.of<RecipeProvider>(context, listen: false);

      _mealPlanProvider?.addListener(_onMealPlanOrRecipeChanged);
      _recipeProvider?.addListener(_onMealPlanOrRecipeChanged);

      if (authProvider.user != null) {
        final userId = authProvider.user!.id;
        if (userId != null) {
          shoppingProvider.setUserId(userId);
          await shoppingProvider.loadShoppingItems();
          await _syncShoppingListFromMealPlan(force: true);
        }
      }
    });
  }

  @override
  void dispose() {
    _mealPlanProvider?.removeListener(_onMealPlanOrRecipeChanged);
    _recipeProvider?.removeListener(_onMealPlanOrRecipeChanged);
    _itemNameController.dispose();
    _quantityController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onMealPlanOrRecipeChanged() {
    _syncShoppingListFromMealPlan();
  }

  String _buildSyncSignature(List<dynamic> mealPlans, List<Recipe> recipes) {
    final sortedMealPlans = mealPlans.toList()
      ..sort((a, b) => (a.id as String).compareTo(b.id as String));

    final mealPlanSignature = sortedMealPlans
        .map(
          (m) =>
              '${m.id}|${m.recipeId}|${m.date.toIso8601String()}|${m.mealType.index}|${m.servings}',
        )
        .join(';');

    final sortedRecipes = recipes.toList()
      ..sort((a, b) => a.id.compareTo(b.id));

    final recipeSignature = sortedRecipes
        .map((r) {
          final ingredientSignature =
              r.ingredients
                  .map(
                    (ingredient) =>
                        '${ingredient.name.trim().toLowerCase()}|${ingredient.quantity.trim()}|${ingredient.unit.trim().toLowerCase()}',
                  )
                  .toList()
                ..sort();

          return '${r.id}|${r.servings}|${ingredientSignature.join(',')}';
        })
        .join(';');

    return '$mealPlanSignature||$recipeSignature';
  }

  Future<void> _syncShoppingListFromMealPlan({bool force = false}) async {
    if (!mounted || _isAutoSyncing) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final shoppingProvider = Provider.of<ShoppingListProvider>(
      context,
      listen: false,
    );

    if (authProvider.user?.id == null) return;

    final mealPlans = _mealPlanProvider?.mealPlans ?? [];
    final recipes = _recipeProvider?.recipes ?? <Recipe>[];
    final signature = _buildSyncSignature(mealPlans, recipes);

    if (!force && signature == _lastSyncSignature) return;

    _isAutoSyncing = true;
    try {
      final previousItems = List<ShoppingItem>.from(
        shoppingProvider.shoppingItems,
      );
      final ingredientsWithMealType = <Map<String, dynamic>>[];

      for (final mealPlan in mealPlans) {
        if (mealPlan.recipeId != null) {
          Recipe? recipe;
          try {
            recipe = recipes.firstWhere((r) => r.id == mealPlan.recipeId);
          } catch (_) {
            recipe = null;
          }

          if (recipe != null) {
            final recipeServings = recipe.servings <= 0 ? 1 : recipe.servings;
            final plannedServings = mealPlan.servings <= 0
                ? 1
                : mealPlan.servings;

            for (final ingredient in recipe.ingredients) {
              ingredientsWithMealType.add({
                'ingredient': ingredient,
                'mealType': mealPlan.mealType.index,
                'recipeServings': recipeServings,
                'plannedServings': plannedServings,
                'mealPlanId': mealPlan.id,
              });
            }
          }
        }
      }

      await shoppingProvider.clearAllItems();

      if (ingredientsWithMealType.isNotEmpty) {
        final shoppingItems =
            ShoppingListGenerator.generateFromIngredientsWithMealType(
              ingredientsWithMealType,
              authProvider.user!.id!,
              categoryMapper: ShoppingListGenerator.categorizeIngredient,
              existingItems: previousItems,
            );
        await shoppingProvider.addMultipleItems(shoppingItems);
      }

      _lastSyncSignature = signature;
    } catch (e) {
      debugPrint('Erreur sync auto liste de courses: $e');
    } finally {
      _isAutoSyncing = false;
    }
  }

  void _addItem() async {
    if (_itemNameController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Entrez un nom d\'article')));
      return;
    }

    try {
      final quantity = double.tryParse(_quantityController.text) ?? 1.0;
      final shoppingProvider = Provider.of<ShoppingListProvider>(
        context,
        listen: false,
      );
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      final newItem = ShoppingItem(
        userId: authProvider.user?.id ?? '',
        name: _itemNameController.text.trim(),
        quantity: quantity,
        unit: _selectedUnit,
        category: _selectedCategory,
        isPurchased: false,
      );

      await shoppingProvider.addItem(newItem);

      _itemNameController.clear();
      _quantityController.text = '1';
      _selectedUnit = 'pièce';
      _selectedCategory = 'Autres';

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Article ajouté')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erreur: $e')));
    }
  }

  Future<void> _deleteItemAndRelatedMealPlans(
    ShoppingItem item,
    ShoppingListProvider shoppingProvider,
  ) async {
    final mealPlanIds = item.sourceMealPlanIds ?? const <String>[];
    final mealPlanProvider = _mealPlanProvider;

    if (mealPlanIds.isNotEmpty && mealPlanProvider != null) {
      for (final mealPlanId in mealPlanIds) {
        await mealPlanProvider.deleteMealPlan(mealPlanId);
      }
    }

    await shoppingProvider.deleteItem(item.id);
  }

  Map<int, List<ShoppingItem>> _getGroupedItemsByMealType(
    List<ShoppingItem> items,
  ) {
    final grouped = <int, List<ShoppingItem>>{};
    for (final item in items) {
      final mealType = item.mealType ?? 1; // Par défaut Déjeuner
      grouped.putIfAbsent(mealType, () => []);
      grouped[mealType]!.add(item);
    }
    // Trier par mealType (0 = Petit déj, 1 = Déj, 2 = Dîner)
    final sortedKeys = grouped.keys.toList()..sort();
    return Map.fromEntries(
      sortedKeys.map((key) => MapEntry(key, grouped[key]!)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      body: Consumer<ShoppingListProvider>(
        builder: (context, shoppingProvider, _) {
          if (shoppingProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final allItems = [
            ...shoppingProvider.unpurchasedItems,
            ...shoppingProvider.purchasedItems,
          ];
          final groupedByMealType = _getGroupedItemsByMealType(allItems);
          final totalItems = shoppingProvider.totalItems;
          final purchasedItems = shoppingProvider.purchasedCount;
          final mealsCount = groupedByMealType.length;

          return CustomScrollView(
            slivers: [
              // Header avec dégradé
              SliverToBoxAdapter(
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                       Color(0xFF5D38FF), Color(0xFFEE1289)
                      ],
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Liste de Courses',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 20),
                          // Barre de progression circulaire
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 50,
                                  height: 50,
                                  child: CircularProgressIndicator(
                                    value: totalItems == 0
                                        ? 0
                                        : purchasedItems / totalItems,
                                    backgroundColor: Colors.white.withOpacity(
                                      0.2,
                                    ),
                                    valueColor:
                                        const AlwaysStoppedAnimation<Color>(
                                          Colors.white,
                                        ),
                                    strokeWidth: 6,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Progression',
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 14,
                                      ),
                                    ),
                                    Text(
                                      '$purchasedItems/$totalItems',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Liste des catégories
              if (groupedByMealType.isEmpty)
                SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 50),
                      child: Column(
                        children: [
                          Icon(
                            Icons.shopping_cart_outlined,
                            size: 80,
                            color: Colors.grey[300],
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Liste vide',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final entry = groupedByMealType.entries.elementAt(index);
                      final mealType = entry.key;
                      final items = entry.value;
                      final mealTypeData = _getMealTypeData(mealType);

                      return _buildMealTypeCard(
                        mealType: mealType,
                        items: items,
                        color: mealTypeData['color'] as Color,
                        gradient: mealTypeData['gradient'] as LinearGradient,
                        label: mealTypeData['label'] as String,
                        shoppingProvider: shoppingProvider,
                      );
                    }, childCount: groupedByMealType.length),
                  ),
                ),

              // Récapitulatif
              if (totalItems > 0)
                SliverToBoxAdapter(
                  child: Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF5D38FF), Color(0xFFEE1289)],
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Récapitulatif',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildRecapItem(
                              value: '$totalItems',
                              label: 'Articles total',
                            ),
                            _buildRecapItem(
                              value: '$purchasedItems',
                              label: 'Restants',
                            ),
                            _buildRecapItem(
                              value: '$mealsCount',
                              label: 'Repas',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

              const SliverToBoxAdapter(child: SizedBox(height: 20)),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddItemSheet(context),
        backgroundColor: const Color(0xFF8B5CF6),
        icon: const Icon(Icons.add),
        label: const Text('Ajouter'),
      ),
    );
  }

  Widget _buildMealTypeCard({
    required int mealType,
    required List<ShoppingItem> items,
    required Color color,
    required LinearGradient gradient,
    required String label,
    required ShoppingListProvider shoppingProvider,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header de mealType avec gradient
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${items.length} articles',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.keyboard_arrow_up, color: Colors.white70),
              ],
            ),
          ),
          // Items
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: items.map((item) {
                return _buildItemRow(item, shoppingProvider);
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemRow(
    ShoppingItem item,
    ShoppingListProvider shoppingProvider,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          // Checkbox circulaire
          GestureDetector(
            onTap: () {
              shoppingProvider.togglePurchased(item.id, !item.isPurchased);
            },
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: item.isPurchased
                      ? Colors.grey[400]!
                      : const Color(0xFF8B5CF6),
                  width: 2,
                ),
                color: item.isPurchased ? Colors.grey[400] : Colors.transparent,
              ),
              child: item.isPurchased
                  ? const Icon(Icons.check, size: 16, color: Colors.white)
                  : null,
            ),
          ),
          const SizedBox(width: 12),
          // Nom et quantité
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: item.isPurchased ? Colors.grey[400] : Colors.black87,
                    decoration: item.isPurchased
                        ? TextDecoration.lineThrough
                        : null,
                  ),
                ),
                Text(
                  '${item.quantity} ${item.unit}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                ),
              ],
            ),
          ),
          // Bouton supprimer
          IconButton(
            icon: Icon(Icons.delete_outline, color: Colors.grey[400], size: 20),
            onPressed: () {
              showDialog(
                context: context,
                builder: (dialogContext) => AlertDialog(
                  title: const Text('Supprimer l’article ?'),
                  content: Text(
                    item.sourceMealPlanIds?.isNotEmpty == true
                        ? 'Supprimer aussi le repas planifié associé ?'
                        : 'Supprimer cet article de la liste ?',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(dialogContext),
                      child: const Text('Annuler'),
                    ),
                    TextButton(
                      onPressed: () async {
                        Navigator.pop(dialogContext);
                        await _deleteItemAndRelatedMealPlans(
                          item,
                          shoppingProvider,
                        );
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              item.sourceMealPlanIds?.isNotEmpty == true
                                  ? 'Article et planning supprimés'
                                  : 'Article supprimé',
                            ),
                          ),
                        );
                      },
                      child: const Text(
                        'Supprimer',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRecapItem({required String value, required String label}) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12),
        ),
      ],
    );
  }

  void _showAddItemSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          top: 20,
          left: 20,
          right: 20,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Ajouter un article',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _itemNameController,
              decoration: InputDecoration(
                hintText: 'Nom de l\'article',
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: const Icon(Icons.label_outline),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: _quantityController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Qté',
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 3,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedUnit,
                        isExpanded: true,
                        items: _units
                            .map(
                              (unit) => DropdownMenuItem(
                                value: unit,
                                child: Text(unit),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _selectedUnit = value);
                          }
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedCategory,
                  isExpanded: true,
                  hint: const Text('Catégorie'),
                  items: _categories
                      .map(
                        (cat) => DropdownMenuItem(value: cat, child: Text(cat)),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _selectedCategory = value);
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () {
                  _addItem();
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.add),
                label: const Text('Ajouter'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8B5CF6),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Map<String, dynamic> _getMealTypeData(int mealType) {
    switch (mealType) {
      case 0: // Petit Déjeuner
        return {
          'label': 'Petit déjeuner ☀️',
          'color': const Color(0xFFF59E0B),
          'gradient': const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFFCD34D), // Jaune clair
              Color(0xFFF59E0B), // Ambre
            ],
          ),
        };
      case 1: // Déjeuner
        return {
          'label': 'Déjeuner 🍽️',
          'color': const Color(0xFF06B6D4),
          'gradient': const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0EA5E9), // Bleu clair
              Color(0xFF06B6D4), // Cyan
            ],
          ),
        };
      case 2: // Dîner
        return {
          'label': 'Dîner 🌙',
          'color': const Color(0xFF8B5CF6),
          'gradient': const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xA78B5CF6), // Indigo
              Color(0xFF7C3AED), // Violet
            ],
          ),
        };
      default:
        return {
          'label': 'Non spécifié',
          'color': const Color(0xFF95A5A6),
          'gradient': const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFBDC3C7), Color(0xFF95A5A6)],
          ),
        };
    }
  }
}
