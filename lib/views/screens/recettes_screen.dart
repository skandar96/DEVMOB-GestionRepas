import 'package:flutter/material.dart';

class RecettesScreen extends StatefulWidget {
  const RecettesScreen({super.key});

  @override
  State<RecettesScreen> createState() => _RecettesScreenState();
}

class _RecettesScreenState extends State<RecettesScreen> {
  final TextEditingController _searchController = TextEditingController();

  final List<String> _categories = const [
    'Tous',
    'Petit Dejeuner',
    'Dejeuner',
    'Diner',
  ];

  final List<_RecipeItem> _allRecipes = const [
    _RecipeItem(
      name: 'Salade Cesar',
      minutes: 20,
      people: 2,
      tag: 'Dejeuner',
      colorA: Color(0xFF2B7BFF),
      colorB: Color(0xFF16C1F3),
    ),
    _RecipeItem(
      name: 'Omelette aux legumes',
      minutes: 15,
      people: 1,
      tag: 'Petit Dejeuner',
      colorA: Color(0xFFFF9800),
      colorB: Color(0xFFFF7A00),
    ),
    _RecipeItem(
      name: 'Pates Carbonara',
      minutes: 26,
      people: 2,
      tag: 'Diner',
      colorA: Color(0xFFA03BFF),
      colorB: Color(0xFFFF2E88),
    ),
    _RecipeItem(
      name: 'Smoothie Bowl',
      minutes: 10,
      people: 1,
      tag: 'Petit Dejeuner',
      colorA: Color(0xFFFF9800),
      colorB: Color(0xFFFF7A00),
    ),
    _RecipeItem(
      name: 'Poulet Roti aux Herbes',
      minutes: 60,
      people: 4,
      tag: 'Diner',
      colorA: Color(0xFFA03BFF),
      colorB: Color(0xFFFF2E88),
    ),
    _RecipeItem(
      name: 'Tarte aux Pommes',
      minutes: 45,
      people: 6,
      tag: 'Dessert',
      colorA: Color(0xFFFF2E88),
      colorB: Color(0xFFFF3F6C),
    ),
  ];

  int _selectedBottomIndex = 1;
  String _selectedCategory = 'Tous';

  List<_RecipeItem> get _filteredRecipes {
    final query = _searchController.text.trim().toLowerCase();

    return _allRecipes.where((recipe) {
      final categoryMatch =
          _selectedCategory == 'Tous' || recipe.tag == _selectedCategory;
      final searchMatch =
          query.isEmpty || recipe.name.toLowerCase().contains(query);
      return categoryMatch && searchMatch;
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onBottomTabTap(int index) {
    if (index == 0) {
      Navigator.pushReplacementNamed(context, '/home');
      return;
    }

    if (index == 1) {
      setState(() {
        _selectedBottomIndex = index;
      });
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Section bientot disponible')));
  }

  @override
  Widget build(BuildContext context) {
    final recipes = _filteredRecipes;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F5F9),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCategoryFilters(),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        const Icon(
                          Icons.circle,
                          size: 7,
                          color: Color(0xFF6D5EFF),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${recipes.length} recettes trouvees',
                          style: const TextStyle(
                            color: Color(0xFF5E6B85),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ListView.separated(
                      itemCount: recipes.length,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final recipe = recipes[index];
                        return _RecipeCard(recipe: recipe);
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF5A2CFF), Color(0xFFE4009B)],
        ),
      ),
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconButton(
            onPressed: () => Navigator.pushReplacementNamed(context, '/home'),
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Colors.white,
              size: 18,
            ),
            style: IconButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: const Size(34, 34),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
          const Text(
            'Mes Recettes',
            style: TextStyle(
              color: Colors.white,
              fontSize: 34,
              height: 1,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),
          Container(
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFF2F4FA),
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (_) => setState(() {}),
              style: const TextStyle(color: Color(0xFF303A56), fontSize: 14),
              decoration: const InputDecoration(
                border: InputBorder.none,
                prefixIcon: Icon(Icons.search, color: Color(0xFF8A98B3)),
                hintText: 'Rechercher une recette...',
                hintStyle: TextStyle(color: Color(0xFFA4AFC2)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilters() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.filter_alt_outlined, size: 16, color: Color(0xFF7A879E)),
            SizedBox(width: 5),
            Text(
              'CATEGORIES',
              style: TextStyle(
                letterSpacing: 0.9,
                color: Color(0xFF7A879E),
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _categories.map((category) {
            final isSelected = _selectedCategory == category;

            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedCategory = category;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 9,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(9),
                  color: isSelected
                      ? const Color(0xFF6C7890)
                      : const Color(0xFFEBEEF5),
                  boxShadow: isSelected
                      ? const [
                          BoxShadow(
                            color: Color(0x2A54657D),
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  category,
                  style: TextStyle(
                    fontSize: 13,
                    color: isSelected ? Colors.white : const Color(0xFF616D86),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildBottomNavigationBar() {
    final tabs = <({String label, IconData icon})>[
      (label: 'Accueil', icon: Icons.home_outlined),
      (label: 'Recettes', icon: Icons.menu_book_outlined),
      (label: 'Planning', icon: Icons.calendar_month_outlined),
      (label: 'Courses', icon: Icons.shopping_cart_outlined),
    ];

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color(0x14111827),
            blurRadius: 18,
            offset: Offset(0, -3),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(tabs.length, (index) {
          final tab = tabs[index];
          final isSelected = _selectedBottomIndex == index;

          return InkWell(
            onTap: () => _onBottomTabTap(index),
            borderRadius: BorderRadius.circular(14),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(11),
                      gradient: isSelected
                          ? const LinearGradient(
                              colors: [Color(0xFF9A41FF), Color(0xFFFF2E99)],
                            )
                          : null,
                      color: isSelected ? null : const Color(0xFFF0F2F7),
                    ),
                    child: Icon(
                      tab.icon,
                      size: 20,
                      color: isSelected
                          ? Colors.white
                          : const Color(0xFF6A7792),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    tab.label,
                    style: TextStyle(
                      color: isSelected
                          ? const Color(0xFF2E3855)
                          : const Color(0xFF7C8AA4),
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w500,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _RecipeCard extends StatelessWidget {
  const _RecipeCard({required this.recipe});

  final _RecipeItem recipe;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F2F7),
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x10000000),
            blurRadius: 14,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(colors: [recipe.colorA, recipe.colorB]),
            ),
            child: const Icon(
              Icons.restaurant_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  recipe.name,
                  style: const TextStyle(
                    color: Color(0xFF303A56),
                    fontSize: 25,
                    height: 1.1,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.timelapse_outlined,
                      size: 12,
                      color: Color(0xFF8A97B0),
                    ),
                    const SizedBox(width: 3),
                    Text(
                      '${recipe.minutes} min',
                      style: const TextStyle(
                        color: Color(0xFF7987A1),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 9),
                    const Icon(
                      Icons.person_outline_rounded,
                      size: 12,
                      color: Color(0xFF8A97B0),
                    ),
                    const SizedBox(width: 3),
                    Text(
                      '${recipe.people} pers.',
                      style: const TextStyle(
                        color: Color(0xFF7987A1),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 9),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1E8FF),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        recipe.tag,
                        style: const TextStyle(
                          color: Color(0xFF9A62FF),
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          Container(
            width: 34,
            height: 34,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [Color(0xFF7B44FF), Color(0xFFB54BFF)],
              ),
              boxShadow: [
                BoxShadow(
                  color: Color(0x3D7B44FF),
                  blurRadius: 12,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: IconButton(
              onPressed: () {},
              icon: const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: Colors.white,
              ),
              splashRadius: 17,
              padding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
    );
  }
}

class _RecipeItem {
  const _RecipeItem({
    required this.name,
    required this.minutes,
    required this.people,
    required this.tag,
    required this.colorA,
    required this.colorB,
  });

  final String name;
  final int minutes;
  final int people;
  final String tag;
  final Color colorA;
  final Color colorB;
}
