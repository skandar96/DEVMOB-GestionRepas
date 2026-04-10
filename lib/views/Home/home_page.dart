import 'package:flutter/material.dart';
import '../../services/auth_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            _buildWelcomeCard(),
            _buildQuickAccess(),
            _buildStatsCard(),
            const SizedBox(height: 80), // espace pour la bottom nav
          ],
        ),
      ),
    );
  }

  // ==================== HEADER ====================
  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 50, 20, 25),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF7C3AED), Color(0xFFDB2777)],
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.restaurant, color: Color(0xFF7C3AED)),
              ),
              const SizedBox(width: 12),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "DEVMOB",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "Gestion de Repas",
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ],
          ),
          GestureDetector(
            onTap: _handleLogout,
            child: const Icon(Icons.logout, color: Colors.white, size: 28),
          ),
        ],
      ),
    );
  }

  // ==================== WELCOME CARD ====================
  Widget _buildWelcomeCard() {
    return Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF7C3AED), Color(0xFFDB2777)],
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Text("👋", style: TextStyle(fontSize: 28)),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Bienvenue !",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 6),
                Text(
                  "Organisez vos repas et simplifiez vos courses quotidiennes",
                  style: TextStyle(fontSize: 13, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==================== QUICK ACCESS ====================
  Widget _buildQuickAccess() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "ACCÈS RAPIDE",
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.15,
            children: [
              _quickAccessCard(
                icon: Icons.menu_book_rounded,
                title: "Mes Recettes",
                subtitle: "Parcourir et gérer",
                color: Colors.purple,
              ),
              _quickAccessCard(
                icon: Icons.restaurant_menu_rounded,
                title: "Nouvelle\nRecette",
                subtitle: "Ajouter une recette",
                color: Colors.pink,
              ),
              _quickAccessCard(
                icon: Icons.calendar_today_rounded,
                title: "Planning Repas",
                subtitle: "Planifier la semaine",
                color: Colors.red,
              ),
              _quickAccessCard(
                icon: Icons.shopping_cart_rounded,
                title: "Liste de\nCourses",
                subtitle: "Gérer mes achats",
                color: Colors.orange,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _quickAccessCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color.withOpacity(0.85), color],
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: Colors.white, size: 28),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 11.5, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  // ==================== STATS CARD ====================
  Widget _buildStatsCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF7C3AED), Color(0xFFDB2777)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _StatItem(value: "12", label: "Recettes"),
          _StatItem(value: "7", label: "Repas planifiés"),
          _StatItem(value: "24", label: "Articles"),
        ],
      ),
    );
  }

  // ==================== BOTTOM NAVIGATION ====================

  // ==================== LOGOUT ====================
  Future<void> _handleLogout() async {
    final authService = AuthService();
    try {
      await authService.signOut();
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/login');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de la déconnexion: $e')),
        );
      }
    }
  }
}

// ==================== STAT ITEM WIDGET ====================
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
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 13),
        ),
      ],
    );
  }
}
