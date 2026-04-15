import 'package:flutter/material.dart';

void main() {
  runApp(const MealPlannerApp());
}

class MealPlannerApp extends StatelessWidget {
  const MealPlannerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      
      theme: ThemeData(
        primarySwatch: Colors.purple,
        scaffoldBackgroundColor: const Color(0xFFF8F9FE),
      ),
      home: const WeeklyPlanningPage(),
    );
  }
}

class WeeklyPlanningPage extends StatelessWidget {
  const WeeklyPlanningPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // --- HEADER AVEC DÉGRADÉ ---
        Container(
          padding: const EdgeInsets.only(top: 50, left: 20, right: 20, bottom: 30),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft, // On commence à gauche
              end: Alignment.centerRight,   // Vers la droite
              colors: [
                Color(0xFF5D38FF), // Le bleu/violet de gauche (selon votre image)
                Color(0xFFEE1289), // Le rose/magenta de droite (selon votre image)
              ],
            ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(0),
                  bottomRight: Radius.circular(0),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: const [
                      Icon(Icons.calendar_month, color: Colors.white, size: 28),
                      SizedBox(width: 10),
                      Text(
                        "Planning Hebdomadaire",
                        style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 25),
                  // Sélecteur de date central
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Icon(Icons.chevron_left, color: Colors.white, size: 30),
                        Column(
                          children: const [
                            Text("février 2026", style: TextStyle(color: Colors.white70, fontSize: 14)),
                            Text("Dimanche 15", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w500)),
                          ],
                        ),
                        const Icon(Icons.chevron_right, color: Colors.white, size: 30),
                      ],
                    ),
                  ),
                  const SizedBox(height: 15),
                  // Indicateurs de pagination (les points)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(6, (index) => 
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        width: index == 5 ? 25 : 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(index == 5 ? 1 : 0.5),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),

            // --- CALENDRIER HORIZONTAL ---
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildDayItem("Lun", "9"),
                    _buildDayItem("Mar", "10"),
                    _buildDayItem("Mer", "11"),
                    _buildDayItem("Jeu", "12"),
                    _buildDayItem("Ven", "13"),
                    _buildDayItem("Sam", "14"),
                    _buildDayItem("Dim", "15", isSelected: true),
                  ],
                ),
              ),
            ),

            // Badge "Aujourd'hui"
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00C853),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      CircleAvatar(radius: 3, backgroundColor: Colors.white),
                      SizedBox(width: 5),
                      Text("Aujourd'hui", style: TextStyle(color: Colors.white, fontSize: 12)),
                    ],
                  ),
                ),
              ),
            ),

            // --- SECTIONS DE REPAS ---
            _buildMealSection(
              title: "Petit Déjeuner",
              time: "07:00 - 09:00",
              color: const Color(0xFFFFA000),
              icon: Icons.wb_twilight,
            ),
            _buildMealSection(
              title: "Déjeuner",
              time: "12:00 - 14:00",
              color: const Color(0xFF03A9F4),
              icon: Icons.wb_sunny,
            ),
            _buildMealSection(
              title: "Diner",
              time: "19:00 - 21:00",
              color: const Color(0xFFE91E63),
              icon: Icons.nightlight_round,
            ),
            
            ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  // Widget pour un jour dans le calendrier
  Widget _buildDayItem(String day, String date, {bool isSelected = false}) {
    return Column(
      children: [
        Text(day, style: TextStyle(color: isSelected ? Colors.indigo : Colors.grey, fontSize: 12)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF7B61FF) : Colors.transparent,
            borderRadius: BorderRadius.circular(15),
            boxShadow: isSelected ? [BoxShadow(color: Colors.blue.withOpacity(0.3), blurRadius: 8)] : [],
          ),
          child: Text(
            date,
            style: TextStyle(color: isSelected ? Colors.white : Colors.black87, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  // Widget réutilisable pour chaque section de repas
  Widget _buildMealSection({required String title, required String time, required Color color, required IconData icon}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        children: [
          // En-tête coloré du repas
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: color,
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(25), topRight: Radius.circular(25)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(10)),
                  child: Icon(icon, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 15),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    Text(time, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                  ],
                )
              ],
            ),
          ),
          // Zone "Ajouter un repas"
          Padding(
            padding: const EdgeInsets.all(20),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 30),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [color.withOpacity(0.7), color]),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const Icon(Icons.add, color: Colors.white, size: 30),
                  ),
                  const SizedBox(height: 10),
                  const Text("Ajouter un repas", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  const Text("Choisissez une recette pour ce repas", style: TextStyle(color: Colors.white70, fontSize: 11)),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  

  Widget _navIcon(IconData icon, String label, bool isActive) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        isActive 
          ? Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFF52D6C),
                borderRadius: BorderRadius.circular(15),
                boxShadow: [BoxShadow(color: Colors.pink.withOpacity(0.3), blurRadius: 10)],
              ),
              child: Icon(icon, color: Colors.white),
            )
          : Icon(icon, color: Colors.grey),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(color: isActive ? Colors.black : Colors.grey, fontSize: 10)),
      ],
    );
  }
}