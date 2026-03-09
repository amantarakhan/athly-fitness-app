import 'package:flutter/material.dart';
import 'package:athlynew/colors.dart';
import 'package:provider/provider.dart';
import 'package:athlynew/providers/hydration_provider.dart';

// Import meals model + data
import 'package:athlynew/models/meal.dart';
import 'package:athlynew/data/meals_data.dart';

class MealPlanScreen extends StatefulWidget {
  const MealPlanScreen({super.key});

  @override
  State<MealPlanScreen> createState() => _MealPlanScreenState();
}

class _MealPlanScreenState extends State<MealPlanScreen> {
  // Grocery checklist state (only UI-specific state remains)
  Map<String, bool> _groceryChecklist = {};

  @override
  void initState() {
    super.initState();
    // Load hydration data when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HydrationProvider>().loadHydration();
    });
  }

  void _toggleGroceryItem(String item) {
    setState(() {
      _groceryChecklist[item] = !(_groceryChecklist[item] ?? false);
    });
  }

  // -----------------UI -----------------
  @override
  Widget build(BuildContext context) {
    //  get today's dynamic meals
    final todayPlan = planForDate(DateTime.now());
    final breakfast = todayPlan.breakfast;
    final lunch = todayPlan.lunch;
    final dinner = todayPlan.dinner;

    //  Build grocery list from today's meals (unique ingredients)
    final groceryItems = <String>{
      ...breakfast.ingredients,
      ...lunch.ingredients,
      ...dinner.ingredients,
    }.toList();

    //  total prep time from the 3 meals
    final totalPrepMinutes =
        breakfast.prepMinutes + lunch.prepMinutes + dinner.prepMinutes;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.navy,
        elevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: AppColors.textDark),
        title: const Center(
          child: Text(
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
                    // Use Consumer for update hydration display
                    Expanded(
                      // HYDRATION PROVIDER - Same card as HomeScreen
                      child: Consumer<HydrationProvider>(
                        builder: (context, hydration, child) {
                          if (hydration.isLoading) {
                            return Container(
                              constraints: const BoxConstraints(minHeight: 150),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppColors.accentBlue.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.black87,
                                ),
                              ),
                            );
                          }

                          return GestureDetector(
                            onTap: () async {
                              // Call provider method to add water
                              final success = await hydration.addCup(); // here is the useage of the provider 
                              
                              // Show feedback based on result
                              if (mounted) {
                                if (success) {
                                  if (hydration.currentCups == hydration.goalCups) { // the user finish all 8 cups 
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('🎉 Daily hydration goal reached!'),
                                        backgroundColor: Colors.green,
                                        duration: Duration(seconds: 2),
                                      ),
                                    );
                                  }
                                } else if (hydration.currentCups >= hydration.goalCups) { //// the user already  finish all 8 cups and tap on the widget  
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('🎉 Daily hydration goal already reached!'),
                                      backgroundColor: Colors.green,
                                      duration: Duration(seconds: 2),
                                    ),
                                  );
                                }
                              }
                            },
                            child: _buildHydrationCard(
                              hydration.currentCups,
                              hydration.goalCups,
                              hydration.progress,
                              hydration.isAdding,
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _summaryStatCard(
                        icon: Icons.timer_outlined,
                        label: "Meal Prep Time",
                        value: "${(totalPrepMinutes / 60).toStringAsFixed(1)} hr total",
                        caption: "for all meals",
                        bg: AppColors.secondary.withOpacity(0.3),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // 🍽 Today's meals
                const Text(
                  "Today's Meals",
                  style: TextStyle(
                    fontFamily: "Poppins",
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 14),

                // BREAKFAST
                _mealCard(
                  mealTitle: "Breakfast",
                  calories: breakfast.calories,
                  proteinGrams: breakfast.proteinGrams,
                  prepMinutes: breakfast.prepMinutes,
                  dishName: breakfast.name,
                  description: breakfast.overview.isNotEmpty
                      ? breakfast.overview
                      : "Tap to view full recipe",
                  imageUrl: breakfast.imageUrl,
                  emoji: breakfast.emoji,
                  onViewRecipe: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => MealRecipeScreen(meal: breakfast),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 14),

                // LUNCH
                _mealCard(
                  mealTitle: "Lunch",
                  calories: lunch.calories,
                  proteinGrams: lunch.proteinGrams,
                  prepMinutes: lunch.prepMinutes,
                  dishName: lunch.name,
                  description: lunch.overview.isNotEmpty
                      ? lunch.overview
                      : "Tap to view full recipe",
                  imageUrl: lunch.imageUrl,
                  emoji: lunch.emoji,
                  onViewRecipe: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => MealRecipeScreen(meal: lunch),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 14),

                // DINNER
                _mealCard(
                  mealTitle: "Dinner",
                  calories: dinner.calories,
                  proteinGrams: dinner.proteinGrams,
                  prepMinutes: dinner.prepMinutes,
                  dishName: dinner.name,
                  description: dinner.overview.isNotEmpty
                      ? dinner.overview
                      : "Tap to view full recipe",
                  imageUrl: dinner.imageUrl,
                  emoji: dinner.emoji,
                  onViewRecipe: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => MealRecipeScreen(meal: dinner),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 24),

                // 🧬 Nutrition breakdown (still static for now)
                _nutritionBreakdownCard(
                  carbsPercent: 41,
                  fatsPercent: 30,
                  proteinPercent: 29,
                ),

                const SizedBox(height: 24),

                // 📅 Grocery list organized by meal
                _groceryListByMeal(
                  breakfast: breakfast,
                  lunch: lunch,
                  dinner: dinner,
                  checklist: _groceryChecklist,
                  onToggle: _toggleGroceryItem,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 💧 Enhanced hydration card with progress bar
  Widget _buildHydrationCard(
    int current,
    int goal,
    double progress,
    bool isAddingWater,
  ) {
    return Container(
      constraints: const BoxConstraints(minHeight: 150),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.accentBlue.withOpacity(0.3),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.blue.shade300, width: 2),
        boxShadow: [
          BoxShadow(
            color: AppColors.accentBlue.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.water_drop_rounded,
                    size: 28, color: Colors.blue),
              ),
              const Spacer(),
              if (isAddingWater)
                const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.blue,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            "Water Intake",
            style: TextStyle(
              fontFamily: "Poppins",
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "$current / $goal glasses",
            style: const TextStyle(
              fontFamily: "Poppins",
              fontSize: 13,
              color: Colors.black87,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          // 🌊 Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: Colors.blue.shade100,
              valueColor: AlwaysStoppedAnimation<Color>(
                progress >= 1.0 ? Colors.green : Colors.blue.shade700,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "Tap to add",
            style: TextStyle(
              fontFamily: "Poppins",
              fontSize: 11,
              color: Colors.blue.shade900,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ================== SUMMARY CARDS ==================

// Helper function to build meal images with fallback
Widget _buildMealImage(String mealName, String imageUrl, String emoji) {
  if (imageUrl.isEmpty) {
    return Center(
      child: Text(
        emoji,
        style: const TextStyle(fontSize: 40),
      ),
    );
  }

  return Image.network(
    imageUrl,
    width: 88,
    height: 72,
    fit: BoxFit.cover,
    loadingBuilder: (context, child, loadingProgress) {
      if (loadingProgress == null) return child;
      return Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            value: loadingProgress.expectedTotalBytes != null
                ? loadingProgress.cumulativeBytesLoaded /
                    loadingProgress.expectedTotalBytes!
                : null,
          ),
        ),
      );
    },
    errorBuilder: (context, error, stackTrace) {
      return Center(
        child: Text(
          emoji,
          style: const TextStyle(fontSize: 40),
        ),
      );
    },
  );
}

Widget _summaryStatCard({
  required IconData icon,
  required String label,
  required String value,
  String? caption,
  required Color bg,
  bool isInteractive = false,
}) {
  return Container(
    constraints: const BoxConstraints(minHeight: 150),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: bg,
      borderRadius: BorderRadius.circular(20),
      border: isInteractive
          ? Border.all(color: Colors.blue.shade700, width: 2)
          : null,
      boxShadow: [
        BoxShadow(
          color: bg.withOpacity(0.3),
          blurRadius: 12,
          offset: const Offset(0, 6),
        ),
      ],
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 28, color: Colors.black87),
        ),
        const SizedBox(height: 12),
        Text(
          label,
          style: const TextStyle(
            fontFamily: "Poppins",
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: "Poppins",
            fontSize: 13,
            color: Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
        if (caption != null) ...[
          const SizedBox(height: 6),
          Text(
            caption,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: "Poppins",
              fontSize: 11,
              color: isInteractive ? Colors.blue.shade900 : Colors.black54,
              fontWeight: isInteractive ? FontWeight.w600 : FontWeight.normal,
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
  required String imageUrl,
  required String emoji,
  required VoidCallback onViewRecipe,
}) {
  return Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white,
          AppColors.background,
        ],
      ),
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: Colors.black.withOpacity(0.05), width: 1),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(.08),
          blurRadius: 20,
          offset: const Offset(0, 10),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header line
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    mealTitle,
                    style: const TextStyle(
                      fontFamily: "Poppins",
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Colors.black87,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "$calories kcal • ${proteinGrams}g protein",
                    style: const TextStyle(
                      fontFamily: "Poppins",
                      fontSize: 13,
                      color: Colors.black54,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.secondary.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.timer_outlined, size: 14, color: Colors.black87),
                  const SizedBox(width: 4),
                  Text(
                    "${prepMinutes} min",
                    style: const TextStyle(
                      fontFamily: "Poppins",
                      fontSize: 12,
                      color: Colors.black87,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        Row(
          children: [
            // Left: meal image with fallback
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: AppColors.background,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: _buildMealImage(dishName, imageUrl, emoji),
              ),
            ),
            const SizedBox(width: 16),

            // Right: dish info + button
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dishName,
                    style: const TextStyle(
                      fontFamily: "Poppins",
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: "Poppins",
                      fontSize: 13,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: onViewRecipe,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.navy,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        "View Recipe",
                        style: TextStyle(
                          fontFamily: "Poppins",
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
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
              _macroRow(
                  color: Colors.amber, label: "Carbs", percent: carbsPercent),
              const SizedBox(height: 6),
              _macroRow(
                  color: Colors.blue, label: "Fats", percent: fatsPercent),
              const SizedBox(height: 6),
              _macroRow(
                  color: Colors.teal,
                  label: "Protein",
                  percent: proteinPercent),
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

// ☑️ Enhanced grocery list organized by meal with sections
Widget _groceryListByMeal({
  required Meal breakfast,
  required Meal lunch,
  required Meal dinner,
  required Map<String, bool> checklist,
  required Function(String) onToggle,
}) {
  final breakfastChecked =
      breakfast.ingredients.where((item) => checklist[item] == true).length;
  final lunchChecked =
      lunch.ingredients.where((item) => checklist[item] == true).length;
  final dinnerChecked =
      dinner.ingredients.where((item) => checklist[item] == true).length;

  final totalItems = breakfast.ingredients.length +
      lunch.ingredients.length +
      dinner.ingredients.length;
  final totalChecked = breakfastChecked + lunchChecked + dinnerChecked;

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
        Row(
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
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: totalChecked == totalItems
                    ? Colors.green.shade50
                    : Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: totalChecked == totalItems
                      ? Colors.green.shade300
                      : Colors.blue.shade300,
                ),
              ),
              child: Text(
                "$totalChecked/$totalItems",
                style: TextStyle(
                  fontFamily: "Poppins",
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: totalChecked == totalItems
                      ? Colors.green.shade700
                      : Colors.blue.shade700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        const Text(
          "Organized by meal for easier shopping.",
          style: TextStyle(
            fontFamily: "Poppins",
            fontSize: 13,
            color: Colors.black54,
          ),
        ),
        const SizedBox(height: 16),

        // BREAKFAST SECTION
        _mealGrocerySection(
          mealEmoji: breakfast.emoji,
          mealName: "Breakfast: ${breakfast.name}",
          items: breakfast.ingredients,
          checkedCount: breakfastChecked,
          checklist: checklist,
          onToggle: onToggle,
        ),

        const SizedBox(height: 16),

        // LUNCH SECTION
        _mealGrocerySection(
          mealEmoji: lunch.emoji,
          mealName: "Lunch: ${lunch.name}",
          items: lunch.ingredients,
          checkedCount: lunchChecked,
          checklist: checklist,
          onToggle: onToggle,
        ),

        const SizedBox(height: 16),

        // DINNER SECTION
        _mealGrocerySection(
          mealEmoji: dinner.emoji,
          mealName: "Dinner: ${dinner.name}",
          items: dinner.ingredients,
          checkedCount: dinnerChecked,
          checklist: checklist,
          onToggle: onToggle,
        ),
      ],
    ),
  );
}

// Individual meal grocery section
Widget _mealGrocerySection({
  required String mealEmoji,
  required String mealName,
  required List<String> items,
  required int checkedCount,
  required Map<String, bool> checklist,
  required Function(String) onToggle,
}) {
  return Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: AppColors.background,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: Colors.black12, width: 1),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              mealEmoji,
              style: const TextStyle(fontSize: 22),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                mealName,
                style: const TextStyle(
                  fontFamily: "Poppins",
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
            ),
            Text(
              "$checkedCount/${items.length}",
              style: TextStyle(
                fontFamily: "Poppins",
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: checkedCount == items.length
                    ? Colors.green.shade700
                    : Colors.black54,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ...items.map((item) {
          final isChecked = checklist[item] ?? false;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 3),
            child: GestureDetector(
              onTap: () => onToggle(item),
              child: Row(
                children: [
                  Icon(
                    isChecked
                        ? Icons.check_box
                        : Icons.check_box_outline_blank,
                    size: 20,
                    color:
                        isChecked ? Colors.green.shade700 : Colors.black38,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      item,
                      style: TextStyle(
                        fontFamily: "Poppins",
                        fontSize: 13,
                        color: isChecked ? Colors.black54 : Colors.black87,
                        decoration: isChecked
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                        decorationColor: Colors.black54,
                        decorationThickness: 2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    ),
  );
}

// ================== MEAL RECIPE SCREEN ==================

class MealRecipeScreen extends StatelessWidget {
  final Meal meal;

  const MealRecipeScreen({super.key, required this.meal});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.navy,
        elevation: 0,
        title: Text(
          meal.name,
          style: const TextStyle(
            fontFamily: "Poppins",
            fontWeight: FontWeight.w600,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Meal image at top
            if (meal.imageUrl.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.network(
                  meal.imageUrl,
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: double.infinity,
                      height: 200,
                      color: AppColors.background,
                      child: Center(
                        child: Text(
                          meal.emoji,
                          style: const TextStyle(fontSize: 80),
                        ),
                      ),
                    );
                  },
                ),
              ),

            if (meal.imageUrl.isNotEmpty) const SizedBox(height: 20),

            // Top summary card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
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
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          meal.type,
                          style: const TextStyle(
                            fontFamily: "Poppins",
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Colors.black54,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          meal.name,
                          style: const TextStyle(
                            fontFamily: "Poppins",
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "${meal.calories} kcal • ${meal.proteinGrams}g protein",
                          style: const TextStyle(
                            fontFamily: "Poppins",
                            fontSize: 13,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Icon(Icons.timer_outlined, size: 20),
                      const SizedBox(height: 4),
                      Text(
                        "${meal.prepMinutes} min prep",
                        style: const TextStyle(
                          fontFamily: "Poppins",
                          fontSize: 13,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Overview
            Text(
              "Overview",
              style: textTheme.titleMedium?.copyWith(
                fontFamily: "Poppins",
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              meal.overview.isNotEmpty
                  ? meal.overview
                  : 'A balanced, healthy meal from your daily plan.',
              style: const TextStyle(
                fontFamily: "Poppins",
                fontSize: 14,
                color: Colors.black87,
              ),
            ),

            const SizedBox(height: 24),

            // Ingredients
            Text(
              "Ingredients",
              style: textTheme.titleMedium?.copyWith(
                fontFamily: "Poppins",
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            if (meal.ingredients.isEmpty)
              const Text(
                "Ingredients coming soon.",
                style: TextStyle(
                  fontFamily: "Poppins",
                  fontSize: 14,
                  color: Colors.black54,
                ),
              )
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: meal.ingredients
                    .map(
                      (ing) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "• ",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black87,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                ing,
                                style: const TextStyle(
                                  fontFamily: "Poppins",
                                  fontSize: 14,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
              ),

            const SizedBox(height: 24),

            // Steps
            Text(
              "Steps",
              style: textTheme.titleMedium?.copyWith(
                fontFamily: "Poppins",
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            if (meal.steps.isEmpty)
              const Text(
                "Steps coming soon.",
                style: TextStyle(
                  fontFamily: "Poppins",
                  fontSize: 14,
                  color: Colors.black54,
                ),
              )
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (int i = 0; i < meal.steps.length; i++)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Text(
                        "${i + 1}. ${meal.steps[i]}",
                        style: const TextStyle(
                          fontFamily: "Poppins",
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}