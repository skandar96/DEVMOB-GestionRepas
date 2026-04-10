import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../Models/recipe.dart';
import '../../providers/RecipeProvider.dart';

class RecipeDetailPage extends StatefulWidget {
  final Recipe? recipe;

  const RecipeDetailPage({super.key, this.recipe});

  @override
  State<RecipeDetailPage> createState() => _RecipeDetailPageState();
}

class _RecipeDetailPageState extends State<RecipeDetailPage> {
  late Recipe _recipe;
  bool _isLoading = false;
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    if (widget.recipe == null) {
      throw Exception('RecipeDetailPage requires a recipe argument');
    }
    _recipe = widget.recipe!;
    _isFavorite = _recipe.isFavorite;
  }

  void _toggleFavorite() async {
    setState(() => _isFavorite = !_isFavorite);

    try {
      final updatedRecipe = _recipe.copyWith(isFavorite: _isFavorite);
      await context.read<RecipeProvider>().updateRecipe(
        _recipe.id,
        updatedRecipe,
      );
      setState(() => _recipe = updatedRecipe);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isFavorite ? 'Ajoutée aux favoris' : 'Retirée des favoris',
            ),
            duration: const Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      setState(() => _isFavorite = !_isFavorite);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _deleteRecipe() {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Supprimer la recette'),
        content: Text('Êtes-vous sûr de vouloir supprimer "${_recipe.name}" ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => _confirmDelete(),
            child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete() async {
    Navigator.pop(context); // Fermer le dialog

    try {
      await context.read<RecipeProvider>().deleteRecipe(_recipe.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Recette supprimée'),
            backgroundColor: Colors.green,
          ),
        );
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _editRecipe() {
    Navigator.pushNamed(context, '/addRecipe', arguments: _recipe);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              _recipe.category.color.withValues(alpha: 0.8),
              _recipe.category.color.withValues(alpha: 0.5),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // 🔥 HEADER
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                    const Expanded(
                      child: Text(
                        'Détails Recette',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        _isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: Colors.red,
                      ),
                      onPressed: _toggleFavorite,
                    ),
                  ],
                ),
              ),

              // 🔥 CONTENU
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(28),
                      topRight: Radius.circular(28),
                    ),
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        // 🔥 CARD HEADER
                        _buildHeaderCard(),
                        const SizedBox(height: 20),

                        // 🔥 INFOS
                        _buildInfoRow(),
                        const SizedBox(height: 20),

                        // 🔥 INGRÉDIENTS
                        _buildSection(
                          'Ingrédients',
                          Icons.shopping_basket,
                          Colors.orange,
                          _buildIngredients(),
                        ),
                        const SizedBox(height: 20),

                        // 🔥 INSTRUCTIONS
                        _buildSection(
                          'Instructions',
                          Icons.menu_book,
                          Colors.purple,
                          _buildInstructions(),
                        ),

                        const SizedBox(height: 80),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),

      // 🔥 BOUTONS BAS
      bottomNavigationBar: _buildButtons(),
    );
  }

  // 🔥 CARD PRINCIPALE
  Widget _buildHeaderCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _recipe.category.color.withValues(alpha: 0.7),
                  _recipe.category.color,
                ],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(Icons.restaurant, color: Colors.white, size: 40),
          ),
          const SizedBox(height: 16),
          Text(
            _recipe.name,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            _recipe.description,
            style: const TextStyle(fontSize: 14, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _infoChip(Icons.timer, '${_recipe.preparationTime} min', Colors.blue),
          _infoChip(Icons.people, '${_recipe.servings} pers', Colors.green),
          _infoChip(Icons.trending_up, _recipe.difficulty.label, Colors.orange),
          _infoChip(
            Icons.restaurant_menu,
            _recipe.category.label,
            _recipe.category.color,
          ),
        ],
      ),
    );
  }

  Widget _infoChip(IconData icon, String text, Color color) {
    return Column(
      children: [
        Icon(icon, size: 24, color: color),
        const SizedBox(height: 6),
        Text(
          text,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  // 🔥 SECTION DESIGN
  Widget _buildSection(
    String title,
    IconData icon,
    Color color,
    Widget content,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          content,
        ],
      ),
    );
  }

  // 🔥 INGREDIENTS
  Widget _buildIngredients() {
    return Column(
      children: _recipe.ingredients
          .map(
            (ingredient) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: Colors.purple,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: Text('${ingredient.name}')),
                  Text(
                    '${ingredient.quantity} ${ingredient.unit}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }

  // 🔥 INSTRUCTIONS
  Widget _buildInstructions() {
    return Column(
      children: _recipe.instructions
          .asMap()
          .entries
          .map(
            (entry) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          _recipe.category.color.withValues(alpha: 0.7),
                          _recipe.category.color,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Center(
                      child: Text(
                        '${entry.key + 1}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      entry.value,
                      style: const TextStyle(fontSize: 14, height: 1.5),
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }

  // 🔥 BOUTONS BAS
  Widget _buildButtons() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // 🔴 BOUTON SUPPRIMER
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _isLoading ? null : _deleteRecipe,
              icon: const Icon(Icons.delete_outline, size: 20),
              label: const Text('Supprimer'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade50,
                foregroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // 🟣 BOUTON ÉDITER
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _isLoading ? null : _editRecipe,
              icon: const Icon(Icons.edit_outlined, size: 20),
              label: const Text('Éditer'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7C3AED),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
