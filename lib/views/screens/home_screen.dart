import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/auth_controller.dart';
import '../../providers/auth_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthController _authController = AuthController();
  int _selectedIndex = 0;

  void _onBottomTabTap(int index) {
    if (index == 1) {
      Navigator.pushNamed(context, '/recettes');
      return;
    }

    setState(() {
      _selectedIndex = index;
    });
  }

  void _onQuickActionTap(int index) {
    if (index == 0) {
      Navigator.pushNamed(context, '/recettes');
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Section bientôt disponible')),
    );
  }

  Future<void> _logout(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await _authController.signOut(authProvider);
    if (!context.mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F3FA),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                child: Transform.translate(
                  offset: const Offset(0, -18),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildWelcomeCard(),
                        const SizedBox(height: 26),
                        const Text(
                          'ACCÈS RAPIDE',
                          style: TextStyle(
                            color: Color(0xFF7C879F),
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.8,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildQuickActionsGrid(),
                        const SizedBox(height: 24),
                        _buildStatsCard(),
                        const SizedBox(height: 18),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 150,
      padding: const EdgeInsets.fromLTRB(26, 18, 20, 26),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF5E38FF), Color(0xFFE50092)],
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.18),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.restaurant_menu_rounded,
              color: Colors.white,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Padding(
              padding: EdgeInsets.only(top: 2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'DEVMOB',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      height: 1.1,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Gestion de Repas',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.18),
              borderRadius: BorderRadius.circular(14),
            ),
            child: IconButton(
              onPressed: () => _logout(context),
              padding: EdgeInsets.zero,
              tooltip: 'Se déconnecter',
              icon: const Icon(
                Icons.logout_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F8FB),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: const LinearGradient(
                colors: [Color(0xFF6A4CFF), Color(0xFFB24BFF)],
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x336A4CFF),
                  blurRadius: 14,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: const Center(
              child: Text(
                '👋',
                style: TextStyle(fontSize: 24),
              ),
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bienvenue !',
                  style: TextStyle(
                    fontSize: 18,
                    color: Color(0xFF2E3650),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Organisez vos repas et\nsimplifiez vos courses\nquotidiennes',
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.5,
                    color: Color(0xFF667189),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsGrid() {
    final actions = <_QuickActionItem>[
      const _QuickActionItem(
        title: 'Mes Recettes',
        subtitle: 'Parcourir et gérer',
        icon: Icons.menu_book_rounded,
        colorA: Color(0xFF6553FF),
        colorB: Color(0xFF8F49FF),
      ),
      const _QuickActionItem(
        title: 'Nouvelle\nRecette',
        subtitle: 'Ajouter une recette',
        icon: Icons.soup_kitchen_rounded,
        colorA: Color(0xFFA64DFF),
        colorB: Color(0xFFFF2D8E),
      ),
      const _QuickActionItem(
        title: 'Planning Repas',
        subtitle: 'Planifier la semaine',
        icon: Icons.calendar_month_rounded,
        colorA: Color(0xFFFF2F86),
        colorB: Color(0xFFFF4E5A),
      ),
      const _QuickActionItem(
        title: 'Liste de\nCourses',
        subtitle: 'Gérer mes achats',
        icon: Icons.shopping_cart_outlined,
        colorA: Color(0xFFFF7A00),
        colorB: Color(0xFFFFA000),
      ),
    ];

    return GridView.builder(
      itemCount: actions.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.88,
      ),
      itemBuilder: (context, index) {
        return _QuickActionCard(
          item: actions[index],
          onTap: () => _onQuickActionTap(index),
        );
      },
    );
  }

  Widget _buildStatsCard() {
    return Container(
      width: double.infinity,
      height: 122,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF5B30FF), Color(0xFFC427FF), Color(0xFFFF2C8E)],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            left: -18,
            bottom: -22,
            child: Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.10),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            right: -10,
            top: -12,
            child: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.10),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.circle, size: 7, color: Colors.white),
                    SizedBox(width: 8),
                    Text(
                      'Cette Semaine',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _StatsValue(value: '12', label: 'Recettes'),
                    _StatsValue(value: '7', label: 'Repas planifiés'),
                    _StatsValue(value: '24', label: 'Articles'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    final tabs = <({String label, IconData icon})>[
      (label: 'Accueil', icon: Icons.home_outlined),
      (label: 'Recettes', icon: Icons.menu_book_outlined),
      (label: 'Planning', icon: Icons.calendar_today_outlined),
      (label: 'Courses', icon: Icons.shopping_cart_outlined),
    ];

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 16,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(tabs.length, (index) {
          final tab = tabs[index];
          final isSelected = _selectedIndex == index;

          return GestureDetector(
            onTap: () => _onBottomTabTap(index),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? null
                        : const Color(0xFFF1F3F8),
                    gradient: isSelected
                        ? const LinearGradient(
                            colors: [Color(0xFF6A4CFF), Color(0xFFB24BFF)],
                          )
                        : null,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: isSelected
                        ? const [
                            BoxShadow(
                              color: Color(0x336A4CFF),
                              blurRadius: 14,
                              offset: Offset(0, 6),
                            ),
                          ]
                        : null,
                  ),
                  child: Icon(
                    tab.icon,
                    size: 22,
                    color: isSelected
                        ? Colors.white
                        : const Color(0xFF7A859D),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  tab.label,
                  style: TextStyle(
                    fontSize: 12,
                    color: isSelected
                        ? const Color(0xFF2F3B57)
                        : const Color(0xFF7A859D),
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class _QuickActionItem {
  const _QuickActionItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.colorA,
    required this.colorB,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color colorA;
  final Color colorB;
}

class _QuickActionCard extends StatelessWidget {
  const _QuickActionCard({
    required this.item,
    required this.onTap,
  });

  final _QuickActionItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 18, 16, 18),
          decoration: BoxDecoration(
            color: const Color(0xFFFBFBFD),
            borderRadius: BorderRadius.circular(24),
            boxShadow: const [
              BoxShadow(
                color: Color(0x12000000),
                blurRadius: 16,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  gradient: LinearGradient(
                    colors: [item.colorA, item.colorB],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: item.colorA.withOpacity(0.28),
                      blurRadius: 14,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Icon(
                  item.icon,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const Spacer(),
              Text(
                item.title,
                style: const TextStyle(
                  fontSize: 16,
                  height: 1.35,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF27324A),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                item.subtitle,
                style: const TextStyle(
                  fontSize: 12,
                  height: 1.35,
                  color: Color(0xFF7C879F),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatsValue extends StatelessWidget {
  const _StatsValue({
    required this.value,
    required this.label,
  });

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}