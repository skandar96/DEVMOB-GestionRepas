import 'package:flutter/material.dart';

class RecipeDetailPage extends StatefulWidget {
  final Map<String, dynamic>? recipe;

  const RecipeDetailPage({super.key, this.recipe});

  @override
  State<RecipeDetailPage> createState() => _RecipeDetailPageState();
}

class _RecipeDetailPageState extends State<RecipeDetailPage> {
  late Map<String, dynamic> _recipe;

  @override
  void initState() {
    super.initState();
    _recipe = widget.recipe ?? _getDefaultRecipe();
  }

  Map<String, dynamic> _getDefaultRecipe() {
    return {
      'name': 'Salade Césair',
      'time': '15 min',
      'servings': '2',
      'difficulty': 'Facile',
      'color': const Color(0xFF3B82F6),
      'category': 'Déjeuner',
      'ingredients': ['Laitue', 'Parmesan', 'Croûtons', 'Œufs'],
      'instructions': ['Préparer les ingrédients', 'Mélanger', 'Servir'],
    };
  }

  void _deleteRecipe() {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Supprimer la recette'),
        content: Text(
          'Êtes-vous sûr de vouloir supprimer "${_recipe['name']}" ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Fermer le dialog
              Navigator.pop(context); // Retour à la page précédente
            },
            child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // 🔥 GRADIENT MODERNE
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF4A6CFF), Color(0xFF8A2BE2), Color(0xFFFF1493)],
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
                      icon: const Icon(Icons.delete_forever, color: Colors.red),
                      onPressed: _deleteRecipe,
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

                        _buildSection(
                          'Ingrédients',
                          Icons.shopping_basket,
                          Colors.orange,
                          _buildIngredients(),
                        ),

                        const SizedBox(height: 20),

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
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [_recipe['color'].withOpacity(0.7), _recipe['color']],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(Icons.restaurant, color: Colors.white, size: 40),
          ),

          const SizedBox(height: 16),

          Text(
            _recipe['name'],
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 10),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _infoChip(Icons.timer, _recipe['time']),
              const SizedBox(width: 20),
              _infoChip(Icons.people, '${_recipe['servings']} pers'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoChip(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey),
        const SizedBox(width: 6),
        Text(text, style: const TextStyle(color: Colors.grey)),
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
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
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
                  color: color.withOpacity(0.15),
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
      children: (_recipe['ingredients'] as List)
          .map(
            (e) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
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
                  const SizedBox(width: 10),
                  Text(e.toString()),
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
      children: (_recipe['instructions'] as List)
          .asMap()
          .entries
          .map(
            (entry) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Container(
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          _recipe['color'].withOpacity(0.7),
                          _recipe['color'],
                        ],
                      ),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Center(
                      child: Text(
                        '${entry.key + 1}',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(child: Text(entry.value.toString())),
                ],
              ),
            ),
          )
          .toList(),
    );
  }

  // 🔥 BOUTONS BAS
  Widget _buildButtons() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Retour'),
            ),
          ),
        ],
      ),
    );
  }
}
