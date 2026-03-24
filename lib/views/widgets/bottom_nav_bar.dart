import 'package:flutter/material.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTap;

  const CustomBottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
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
          final isSelected = selectedIndex == index;

          return GestureDetector(
            onTap: () => onTap(index),
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