import 'package:flutter/material.dart';
import 'package:athlynew/colors.dart';

class MealPlanScreen extends StatelessWidget {
  const MealPlanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 🔒 Temporary static data – later from Firebase
    const waterCurrent = 6;
    const waterGoal = 8;

    const totalPrepMinutes = 60; // 1 hr total

    const breakfastPrep = 10;
    const lunchPrep = 15;
    const dinnerPrep = 20;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.navy,
        elevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: AppColors.textDark),
        title: Center(
          child: const Text(
            "Plan your meals",
            style: TextStyle(
              fontFamily: "Poppins",
              fontWeight: FontWeight.bold,
              fontSize: 25,
              color: Colors.white,
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: ScrollConfiguration(
          behavior: const ScrollBehavior().copyWith(overscroll: false),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              24,
              24,
              24,
              kBottomNavigationBarHeight + 24,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                
                // 💧 Water + Prep time row
                Row(
                  children: [
                    Expanded(
                      child: _summaryStatCard(
                        icon: Icons.water_drop_outlined,
                        label: "Water Intake",
                        value: "$waterCurrent / $waterGoal glasses",
                        bg: AppColors.accentBlue,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _summaryStatCard(
                        icon: Icons.timer_outlined,
                        label: "Meal Prep Time",
                        value: "${(totalPrepMinutes / 60).round()} hr total",
                        caption: "for all meals",
                        bg: AppColors.secondary,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // 🍽 Today’s meals
                const Text(
                  "Today’s Meals",
                  style: TextStyle(
                    fontFamily: "Poppins",
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 14),

                _mealCard(
                  mealTitle: "Breakfast",
                  calories: 485,
                  proteinGrams: 20,
                  prepMinutes: breakfastPrep,
                  dishName: "Veggie Omelette",
                  description: "2 eggs, spinach, bell pepper, cheese",
                  onViewRecipe: () {
                    // TODO: navigate to recipe screen
                  },
                ),
                const SizedBox(height: 14),

                _mealCard(
                  mealTitle: "Lunch",
                  calories: 450,
                  proteinGrams: 18,
                  prepMinutes: lunchPrep,
                  dishName: "Quinoa Salad",
                  description: "Quinoa, veggies, feta, lemon dressing",
                  onViewRecipe: () {},
                ),
                const SizedBox(height: 14),

                _mealCard(
                  mealTitle: "Dinner",
                  calories: 600,
                  proteinGrams: 25,
                  prepMinutes: dinnerPrep,
                  dishName: "Grilled Salmon",
                  description: "Salmon, potatoes, steamed veggies",
                  onViewRecipe: () {},
                ),

                const SizedBox(height: 24),

                // 🧬 Nutrition breakdown
                _nutritionBreakdownCard(
                  carbsPercent: 41,
                  fatsPercent: 30,
                  proteinPercent: 29,
                ),

                const SizedBox(height: 24),

                // 📅 Weekly planner
                _groceryListCard(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ================== SUMMARY CARDS ==================

Widget _summaryStatCard({
  required IconData icon,
  required String label,
  required String value,
  String? caption,
  required Color bg,
}) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    decoration: BoxDecoration(
      color: bg,
      borderRadius: BorderRadius.circular(18),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 22, color: Colors.black87),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontFamily: "Poppins",
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontFamily: "Poppins",
            fontSize: 13,
            color: Colors.black87,
          ),
        ),
        if (caption != null) ...[
          const SizedBox(height: 2),
          Text(
            caption,
            style: const TextStyle(
              fontFamily: "Poppins",
              fontSize: 11,
              color: Colors.black54,
            ),
          ),
        ],
      ],
    ),
  );
}

// ================== MEAL CARD ==================

Widget _mealCard({
  required String mealTitle,
  required int calories,
  required int proteinGrams,
  required int prepMinutes,
  required String dishName,
  required String description,
  required VoidCallback onViewRecipe,
}) {
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(22),
      boxShadow: [
        BoxShadow(
          color: Colors.black12.withOpacity(.06),
          blurRadius: 16,
          offset: const Offset(0, 8),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header line
        Row(
          children: [
            Text(
              mealTitle,
              style: const TextStyle(
                fontFamily: "Poppins",
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: Colors.black87,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              "$calories kcal • ${proteinGrams}g protein",
              style: const TextStyle(
                fontFamily: "Poppins",
                fontSize: 12,
                color: Colors.black54,
              ),
            ),
            const Spacer(),
            Text(
              "Prep: ${prepMinutes} min",
              style: const TextStyle(
                fontFamily: "Poppins",
                fontSize: 12,
                color: Colors.black54,
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        Row(
          children: [
            // Left: simple “image” placeholder (replace with Image.asset later)
            Container(
              width: 88,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Center(
                child: Icon(
                  Icons.restaurant_menu_rounded,
                  size: 34,
                  color: Colors.black38,
                ),
              ),
            ),
            const SizedBox(width: 14),

            // Right: dish info + button
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dishName,
                    style: const TextStyle(
                      fontFamily: "Poppins",
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: const TextStyle(
                      fontFamily: "Poppins",
                      fontSize: 13,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: ElevatedButton(
                      onPressed: onViewRecipe,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.navy,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 18, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(999),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        "View Recipe",
                        style: TextStyle(
                          fontFamily: "Poppins",
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

// ================== NUTRITION BREAKDOWN ==================

Widget _nutritionBreakdownCard({
  required int carbsPercent,
  required int fatsPercent,
  required int proteinPercent,
}) {
  return Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(22),
      boxShadow: [
        BoxShadow(
          color: Colors.black12.withOpacity(.06),
          blurRadius: 16,
          offset: const Offset(0, 8),
        ),
      ],
    ),
    child: Row(
      children: [
        // Text list
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Nutrition Breakdown",
                style: TextStyle(
                  fontFamily: "Poppins",
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 10),
              _macroRow(color: Colors.amber, label: "Carbs", percent: carbsPercent),
              const SizedBox(height: 6),
              _macroRow(color: Colors.blue, label: "Fats", percent: fatsPercent),
              const SizedBox(height: 6),
              _macroRow(color: Colors.teal, label: "Protein", percent: proteinPercent),
            ],
          ),
        ),

        const SizedBox(width: 16),

        // Simple donut chart
        SizedBox(
          width: 90,
          height: 90,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 90,
                height: 90,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: SweepGradient(
                    colors: [
                      Colors.amber,
                      Colors.blue,
                      Colors.teal,
                      Colors.amber,
                    ],
                  ),
                ),
              ),
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

Widget _macroRow({
  required Color color,
  required String label,
  required int percent,
}) {
  return Row(
    children: [
      Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
      ),
      const SizedBox(width: 8),
      Text(
        "$percent% $label",
        style: const TextStyle(
          fontFamily: "Poppins",
          fontSize: 13,
          color: Colors.black87,
        ),
      ),
    ],
  );
}

// ================== WEEKLY PLANNER ==================

Widget _groceryListCard() {
  // For now: static items based on the example meals.
  // Later, when you connect Firebase, generate this list dynamically.
  final items = [
    "Eggs (4)",
    "Spinach (1 cup)",
    "Bell pepper (1)",
    "Cheese (50g)",
    "Quinoa (1 cup)",
    "Mixed veggies",
    "Feta cheese",
    "Lemon",
    "Salmon fillet (200g)",
    "Potatoes",
    "Broccoli / green veggies",
  ];

  return Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(22),
      boxShadow: [
        BoxShadow(
          color: Colors.black12.withOpacity(.06),
          blurRadius: 16,
          offset: const Offset(0, 8),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Grocery List for Today",
          style: TextStyle(
            fontFamily: "Poppins",
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          "Based on your planned meals.",
          style: TextStyle(
            fontFamily: "Poppins",
            fontSize: 13,
            color: Colors.black54,
          ),
        ),
        const SizedBox(height: 12),
        ...items.map(
          (item) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                const Icon(
                  Icons.check_box_outline_blank,
                  size: 18,
                  color: Colors.black38,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    item,
                    style: const TextStyle(
                      fontFamily: "Poppins",
                      fontSize: 13,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}
