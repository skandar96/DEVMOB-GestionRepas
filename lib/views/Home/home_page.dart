import 'package:flutter/material.dart';
import '../Home/main_screen.dart';
import '../Recipe/AddRecipePage.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF7C3AED), Color(0xFFDB2777)],
        ),
      ),
      child: SafeArea(
        child: Stack(
          children: [
            // 🔵 HEADER (BACKGROUND)
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 40,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.restaurant_menu,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'DEVMOB',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Gestion de Repas',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 80), // space for floating card
              ],
            ),

            // ⚪ BODY (WHITE CONTAINER)
            Positioned.fill(
              top: 140,
              child: Container(
                decoration: const BoxDecoration(color: Color(0xFFF5F5F5)),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 100, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // TITLE
                      Text(
                        'ACCÈS RAPIDE',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade500,
                        ),
                      ),

                      const SizedBox(height: 12),

                      // GRID
                      GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 1.3,
                        children: [
                          _QuickAccessCard(
                            icon: Icons.menu_book,
                            title: 'Mes Recettes',
                            subtitle: 'Parcourir et gérer',
                            color: const Color(0xFF7C3AED),
                            onTap: () => _navigateToTab(context, 1),
                          ),
                          _QuickAccessCard(
                            icon: Icons.add_box_rounded,
                            title: 'Nouvelle\nRecette',
                            subtitle: 'Ajouter une recette',
                            color: const Color(0xFFF59E0B),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const AddRecipePage(),
                                ),
                              );
                            },
                          ),
                          _QuickAccessCard(
                            icon: Icons.calendar_month,
                            title: 'Planning Repas',
                            subtitle: 'Planifier la semaine',
                            color: const Color(0xFFEC4899),
                            onTap: () => _navigateToTab(context, 2),
                          ),
                          _QuickAccessCard(
                            icon: Icons.shopping_cart,
                            title: 'Liste de\nCourses',
                            subtitle: 'Gérer mes achats',
                            color: const Color(0xFFEF4444),
                            onTap: () => _navigateToTab(context, 3),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // STATS
                      _buildStatsCard(),
                    ],
                  ),
                ),
              ),
            ),

            // 🔥 FLOATING WELCOME CARD (FIRST PLAN)
            Positioned(
              top: 110,
              left: 20,
              right: 20,
              child: _buildWelcomeCard(),
            ),
          ],
        ),
      ),
    );
  }

  // NAVIGATION
  void _navigateToTab(BuildContext context, int index) {
    final mainNav = context.findAncestorStateOfType<MainNavigationState>();
    mainNav?.switchTab(index);
  }

  // WELCOME CARD
  Widget _buildWelcomeCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFFEF3C7),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Center(
              child: Text('👋', style: TextStyle(fontSize: 22)),
            ),
          ),
          const SizedBox(width: 20),

          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bienvenue !',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4),
                Text(
                  'Organisez vos repas et simplifiez vos courses',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // STATS CARD
  Widget _buildStatsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF7C3AED), Color(0xFFDB2777)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: const [
          Text("Cette Semaine", style: TextStyle(color: Colors.white)),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _StatItem(value: '12', label: 'Recettes'),
              _StatItem(value: '7', label: 'Repas'),
              _StatItem(value: '24', label: 'Articles'),
            ],
          ),
        ],
      ),
    );
  }
}

// QUICK CARD
class _QuickAccessCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback? onTap;

  const _QuickAccessCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(fontSize: 13)),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

// STAT ITEM
class _StatItem extends StatelessWidget {
  final String value;
  final String label;

  const _StatItem({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 26,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 11),
        ),
      ],
    );
  }
}
