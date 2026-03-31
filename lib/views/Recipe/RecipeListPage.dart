import 'package:flutter/material.dart';

class RecipeListPage extends StatefulWidget {
  const RecipeListPage({super.key});

  @override
  State<RecipeListPage> createState() => _RecipeListPageState();
}

class _RecipeListPageState extends State<RecipeListPage> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'Tous';

  final List<String> _categories = [
    'Tous',
    'Petit Déjeuner',
    'Déjeuner',
    'Dîner',
    'Dessert',
  ];

  final List<Map<String, dynamic>> _recipes = [
    {
      'id': 1,
      'name': 'Salade Césair',
      'time': '15 min',
      'servings': '2',
      'difficulty': 'Facile',
      'color': const Color(0xFF3B82F6),
      'category': 'Déjeuner',
    },
    {
      'id': 2,
      'name': 'Omelette aux légumes',
      'time': '10 min',
      'servings': '1',
      'difficulty': 'Facile',
      'color': const Color(0xFFF97316),
      'category': 'Petit Déjeuner',
    },
    {
      'id': 3,
      'name': 'Pâtes Carbonara',
      'time': '20 min',
      'servings': '2',
      'difficulty': 'Moyen',
      'color': const Color(0xFFA855F7),
      'category': 'Dîner',
    },
    {
      'id': 4,
      'name': 'Smoothie Bowl',
      'time': '5 min',
      'servings': '1',
      'difficulty': 'Facile',
      'color': const Color(0xFFF97316),
      'category': 'Petit Déjeuner',
    },
    {
      'id': 5,
      'name': 'Poulet Rôti aux Herbes',
      'time': '45 min',
      'servings': '4',
      'difficulty': 'Moyen',
      'color': const Color(0xFFA855F7),
      'category': 'Dîner',
    },
    {
      'id': 6,
      'name': 'Tarte aux Pommes',
      'time': '60 min',
      'servings': '6',
      'difficulty': 'Difficile',
      'color': const Color(0xFFEC4899),
      'category': 'Dessert',
    },
  ];

  List<Map<String, dynamic>> get _filteredRecipes {
    return _recipes.where((recipe) {
      final matchesCategory =
          _selectedCategory == 'Tous' ||
          recipe['category'] == _selectedCategory;
      final matchesSearch = recipe['name'].toLowerCase().contains(
        _searchController.text.toLowerCase(),
      );
      return matchesCategory && matchesSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildCategoryFilter(),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: const Color(0xFF7C3AED),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${_filteredRecipes.length} recettes trouvées',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _filteredRecipes.length,
              itemBuilder: (context, index) {
                return _buildRecipeCard(_filteredRecipes[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFF7C86FF),
      elevation: 0,
      toolbarHeight: 160,
      flexibleSpace: Container(
        decoration: BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color.fromARGB(147, 74, 128, 255), // bleu
        Color.fromARGB(129, 137, 43, 226), // violet
        Color.fromARGB(149, 255, 20, 145), // rose
      ],)
        ),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Mes Recettes',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _searchController,
            onChanged: (value) => setState(() {}),
            decoration: InputDecoration(
              hintText: 'Rechercher une recette...',
              hintStyle: const TextStyle(color: Colors.grey),
              prefixIcon: const Icon(Icons.search, color: Colors.grey),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.white.withOpacity(0.95),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
          ),
        ],
      ),
      centerTitle: false,
    );
  }

  Widget _buildCategoryFilter() {
  return SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    child: Row(
      children: [
        const Icon(Icons.filter_list, size: 16, color: Colors.grey),
        const SizedBox(width: 8),
        const Text(
          'CATÉGORIES',
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 12),

        ..._categories.map((category) {
          final isSelected = _selectedCategory == category;

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedCategory = category;
              });
            },
            child: Container(
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 12,
              ),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF6B7280) // gris foncé (comme image)
                    : const Color(0xFFF1F2F6), // gris clair
                borderRadius: BorderRadius.circular(20),

                // 🔥 Ombre seulement si sélectionné
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : [],
              ),
              child: Text(
                category,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey[700],
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                ),
              ),
            ),
          );
        }).toList(),
      ],
    ),
  );
}
  Widget _buildRecipeCard(Map<String, dynamic> recipe) {
    return GestureDetector(
      onTap: () =>
          Navigator.pushNamed(context, '/recipeDetail', arguments: recipe),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.15),
              blurRadius: 8,
              spreadRadius: 0,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Image container
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [recipe['color'].withOpacity(0.7), recipe['color']],
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.restaurant,
                color: Colors.white,
                size: 40,
              ),
            ),
            const SizedBox(width: 16),
            // Info container
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recipe['name'],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildInfoBadge('⏱️${recipe['time']}'),
                      const SizedBox(width: 8),
                      _buildInfoBadge('👥${recipe['servings']} pers.'),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: recipe['color'].withOpacity(0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      recipe['category'],
                      style: TextStyle(
                        fontSize: 12,
                        color: recipe['color'],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Action button
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [recipe['color'].withOpacity(0.7), recipe['color']],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.arrow_forward,
                color: Colors.white,
                size: 24,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 12, color: Colors.grey),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
