import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/ShoppingListProvider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/RecipeProvider.dart';
import '../../providers/meal_plan_provider.dart';
import '../../Models/ShoppingItem.dart';
import '../../Models/ingredient.dart';
import '../../Models/Recipe.dart';
import '../../theme/gradient_header.dart';
import '../../services/shopping_list_generator.dart';

class ShoppingListPage extends StatefulWidget {
  const ShoppingListPage({super.key});

  @override
  State<ShoppingListPage> createState() => _ShoppingListPageState();
}

class _ShoppingListPageState extends State<ShoppingListPage> {
  late TextEditingController _itemNameController;
  late TextEditingController _quantityController;
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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final shoppingProvider = Provider.of<ShoppingListProvider>(
        context,
        listen: false,
      );
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      if (authProvider.user != null) {
        final userId = authProvider.user!.id;
        if (userId != null) {
          shoppingProvider.setUserId(userId);
          shoppingProvider.loadShoppingItems();
        }
      }
    });
  }

  @override
  void dispose() {
    _itemNameController.dispose();
    _quantityController.dispose();
    super.dispose();
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

      // Clear form
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

  void _generateFromMealPlan() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final mealPlanProvider = Provider.of<MealPlanProvider>(
        context,
        listen: false,
      );
      final recipeProvider = Provider.of<RecipeProvider>(
        context,
        listen: false,
      );
      final shoppingProvider = Provider.of<ShoppingListProvider>(
        context,
        listen: false,
      );

      if (authProvider.user?.id == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vous devez être connecté')),
        );
        return;
      }

      // Montrer un loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          content: Row(
            children: const [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Expanded(child: Text('Génération en cours...')),
            ],
          ),
        ),
      );

      // Récupérer les recettes pour les repas de la semaine
      final mealPlans = mealPlanProvider.mealPlans;
      final allIngredients = <Ingredient>[];

      for (final mealPlan in mealPlans) {
        if (mealPlan.recipeId != null) {
          // Trouver la recette dans la liste
          Recipe? recipe;
          try {
            recipe = recipeProvider.recipes.firstWhere(
              (r) => r.id == mealPlan.recipeId,
            );
          } catch (e) {
            // Recette non trouvée, continuer
            recipe = null;
          }

          if (recipe != null) {
            // Ajouter les ingrédients
            allIngredients.addAll(recipe.ingredients);
          }
        }
      }

      if (allIngredients.isEmpty) {
        Navigator.pop(context); // Fermer le loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Aucune recette trouvée pour cette semaine'),
          ),
        );
        return;
      }

      // Générer les articles de shopping
      final shoppingItems = ShoppingListGenerator.generateFromIngredients(
        allIngredients,
        authProvider.user!.id!,
        categoryMapper: ShoppingListGenerator.categorizeIngredient,
      );

      // Ajouter à la liste
      await shoppingProvider.addMultipleItems(shoppingItems);

      Navigator.pop(context); // Fermer le loading dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${shoppingItems.length} articles ajoutés')),
      );
    } catch (e) {
      Navigator.pop(context); // Fermer le loading dialog si encore ouvert
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erreur: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // --- HEADER AVEC DÉGRADÉ ---
            GradientHeader(
              padding: const EdgeInsets.only(
                top: 50,
                left: 20,
                right: 20,
                bottom: 30,
              ),
              child: Column(
                children: [
                  Row(
                    children: const [
                      Icon(Icons.shopping_cart, color: Colors.white, size: 28),
                      SizedBox(width: 10),
                      Text(
                        "Ma Liste de Courses",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Statistiques
                  Consumer<ShoppingListProvider>(
                    builder: (context, shoppingProvider, _) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStat(
                            '${shoppingProvider.unpurchasedCount}',
                            'À acheter',
                            Colors.white,
                          ),
                          _buildStat(
                            '${shoppingProvider.purchasedCount}',
                            'Achetés',
                            Colors.white70,
                          ),
                          _buildStat(
                            '${shoppingProvider.totalItems}',
                            'Total',
                            Colors.white,
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),

            // --- BOUTON GÉNÉRER DEPUIS LE PLANNING ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton.icon(
                  onPressed: _generateFromMealPlan,
                  icon: const Icon(Icons.restaurant_menu),
                  label: const Text('Générer depuis le planning'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF7C4DFF),
                    side: const BorderSide(color: Color(0xFF7C4DFF)),
                  ),
                ),
              ),
            ),

            // --- FORMULAIRE D'AJOUT ---
            Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Ajouter un article',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Nom de l'article
                    TextField(
                      controller: _itemNameController,
                      decoration: InputDecoration(
                        hintText: 'Ex: Pommes, Lait, Riz...',
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon: const Icon(Icons.label_outline),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Quantité et unité
                    Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: TextField(
                            controller: _quantityController,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Qté',
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 10,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              prefixIcon: const Icon(Icons.numbers),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          flex: 1,
                          child: DropdownButtonFormField<String>(
                            value: _selectedUnit,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 10,
                              ),
                            ),
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
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Catégorie
                    DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      decoration: InputDecoration(
                        labelText: 'Catégorie',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      items: _categories
                          .map(
                            (cat) =>
                                DropdownMenuItem(value: cat, child: Text(cat)),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _selectedCategory = value);
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    // Bouton ajouter
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton.icon(
                        onPressed: _addItem,
                        icon: const Icon(Icons.add),
                        label: const Text('Ajouter'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF7C4DFF),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // --- LISTE DES ARTICLES ---
            Consumer<ShoppingListProvider>(
              builder: (context, shoppingProvider, _) {
                if (shoppingProvider.isLoading) {
                  return const SizedBox(
                    height: 300,
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                if (shoppingProvider.totalItems == 0) {
                  return Center(
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
                          const Text(
                            'Ajoutez des articles à votre liste',
                            style: TextStyle(fontSize: 13, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      // Articles non achetés
                      if (shoppingProvider.unpurchasedItems.isNotEmpty) ...[
                        _buildSectionHeader(
                          'À acheter (${shoppingProvider.unpurchasedCount})',
                          Colors.orange,
                        ),
                        _buildItemsList(
                          shoppingProvider.unpurchasedItems,
                          shoppingProvider,
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Articles achetés
                      if (shoppingProvider.purchasedItems.isNotEmpty) ...[
                        _buildSectionHeader(
                          'Achetés (${shoppingProvider.purchasedCount})',
                          Colors.green,
                        ),
                        _buildItemsList(
                          shoppingProvider.purchasedItems,
                          shoppingProvider,
                        ),
                        const SizedBox(height: 16),
                        // Bouton nettoyer
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Effacer les achats'),
                                  content: const Text(
                                    'Êtes-vous sûr de vouloir supprimer tous les articles achetés?',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('Annuler'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        shoppingProvider.clearPurchasedItems();
                                        Navigator.pop(context);
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Articles achetés supprimés',
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
                            icon: const Icon(Icons.delete_outline),
                            label: const Text('Effacer les achats'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.red.shade400,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStat(String value, String label, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 11, color: color.withOpacity(0.8)),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 20,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemsList(
    List<ShoppingItem> items,
    ShoppingListProvider shoppingProvider,
  ) {
    return Column(
      children: items.map((item) {
        return _buildItemCard(item, shoppingProvider);
      }).toList(),
    );
  }

  Widget _buildItemCard(
    ShoppingItem item,
    ShoppingListProvider shoppingProvider,
  ) {
    return Dismissible(
      key: Key(item.id),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.centerRight,
        child: Icon(Icons.delete_outline, color: Colors.red.shade400),
      ),
      onDismissed: (_) {
        shoppingProvider.deleteItem(item.id);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Article supprimé')));
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: item.isPurchased ? Colors.grey[300]! : Colors.grey[200]!,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // Checkbox
            Checkbox(
              value: item.isPurchased,
              onChanged: (value) {
                if (value != null) {
                  shoppingProvider.togglePurchased(item.id, value);
                }
              },
              activeColor: const Color(0xFF7C4DFF),
            ),
            // Info article
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: item.isPurchased
                          ? Colors.grey[400]
                          : Colors.black87,
                      decoration: item.isPurchased
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        '${item.quantity} ${item.unit}',
                        style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                      ),
                      const SizedBox(width: 8),
                      if (item.category != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            item.category!,
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            // Bouton supprimer
            IconButton(
              icon: const Icon(Icons.close, size: 18),
              onPressed: () {
                shoppingProvider.deleteItem(item.id);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Article supprimé')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
