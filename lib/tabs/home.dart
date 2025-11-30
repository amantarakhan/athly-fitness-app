import 'package:flutter/material.dart';
import 'package:athlynew/colors.dart';
import 'package:athlynew/goalSetting.dart';

class HomeScreen extends StatelessWidget {
  final GoalPreferences? prefs;
  const HomeScreen({super.key, this.prefs});

  @override
  Widget build(BuildContext context) {
    // ------- TEMP STATIC DATA (later: from Firebase) -------
    final goal = prefs?.goal ?? "Maintain Fitness";
    const streakDays = 7;

    const caloriesCurrent = 950;
    const caloriesGoal = 2200;

    const hydrationCurrent = 4;
    const hydrationGoal = 8;

    const dailyHighlight = "Remember to stretch!";
    // -------------------------------------------------------

    final focusLabel = _focusBasedOnGoal(goal);
    final motivation = _motivationTip(goal);

    return Scaffold(
      backgroundColor: AppColors.background,
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
                // 👋 Greeting
                const Text(
                  "Hey, John!",
                  style: TextStyle(
                    fontFamily: "Poppins",
                    fontWeight: FontWeight.w800,
                    fontSize: 28,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "$streakDays-day streak – keep going! 🔥",
                  style: const TextStyle(
                    fontFamily: "Poppins",
                    fontSize: 14,
                    color: Colors.black54,
                    fontWeight: FontWeight.w500,
                  ),
                ),
          
                const SizedBox(height: 24),
          
                // 🧡 Today's Workout card
                _todayWorkoutCard(
                  context,
                  title: "Today's Workout",
                  focusLabel: focusLabel,
                  duration: "35 mins",
                  onStart: () {
                    // TODO: Navigate to today's workout
                  },
                ),
          
                const SizedBox(height: 24),
          
                // 📊 Stats row (Calories / Hydration / Motivation)
                Row(
                  children: [
                    Expanded(
                      child: _statCard(
                        color: AppColors.accentBlue,
                        icon: Icons.local_fire_department_outlined,
                        label: "Calories",
                        value: "$caloriesCurrent / $caloriesGoal",
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _statCard(
                        color: AppColors.secondary,
                        icon: Icons.water_drop_outlined,
                        label: "Hydration",
                        value: "$hydrationCurrent / $hydrationGoal",
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _statCard(
                        color: Colors.amberAccent.shade100,
                        icon: Icons.star_border_rounded,
                        label: "Motivation",
                        value: motivation,
                      ),
                    ),
                  ],
                ),
          
                const SizedBox(height: 24),
          
                // 💡 Daily Highlight
                _dailyHighlightCard(
                  icon: Icons.lightbulb_outline,
                  title: "Daily Highlight",
                  subtitle: dailyHighlight,
                ),
          
                const SizedBox(height: 28),
          
                // ✅ Recommended section
                const Text(
                  "Recommended For You",
                  style: TextStyle(
                    fontFamily: "Poppins",
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
          
                SizedBox(
                  height: 150,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _recommendedWorkoutCard(
                        title: "Full Body",
                        subtitle: "20 mins",
                        icon: Icons.fitness_center_rounded,
                      ),
                      _recommendedWorkoutCard(
                        title: "Mobility",
                        subtitle: "Warmup · 5 mins",
                        icon: Icons.accessibility_new_rounded,
                      ),
                      _recommendedWorkoutCard(
                        title: "Core Strength",
                        subtitle: "10 mins",
                        icon: Icons.self_improvement_rounded,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ============ UI HELPERS ============

  Widget _todayWorkoutCard(
    BuildContext context, {
    required String title,
    required String focusLabel,
    required String duration,
    required VoidCallback onStart,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
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
          // Left side: text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: "Poppins",
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.fitness_center_rounded,
                      size: 20,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        "$focusLabel · $duration",
                        style: const TextStyle(
                          fontFamily: "Poppins",
                          fontSize: 14,
                          color: Colors.black87,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Right side: Start button
          ElevatedButton(
            onPressed: onStart,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(999),
              ),
              elevation: 0,
            ),
            child: const Text(
              "Start",
              style: TextStyle(
                fontFamily: "Poppins",
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statCard({
    required Color color,
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      constraints: const BoxConstraints(
      minHeight: 140, // 👈 tweak this number if you want taller/shorter
    ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 22, color: Colors.black87),
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(
                fontFamily: "Poppins",
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: "Poppins",
                fontSize: 12,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dailyHighlightCard({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
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
          Icon(
            icon,
            size: 26,
            color: Colors.amber.shade700,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: "Poppins",
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontFamily: "Poppins",
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _recommendedWorkoutCard({
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    return Container(
      width: 150,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black12.withOpacity(.05),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Placeholder "illustration"
          Expanded(
            child: Center(
              child: Icon(
                icon,
                size: 40,
                color: AppColors.navy,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontFamily: "Poppins",
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: const TextStyle(
              fontFamily: "Poppins",
              fontSize: 12,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  // ============ LOGIC HELPERS ============

  static String _focusBasedOnGoal(String goal) {
    switch (goal) {
      case "Build Muscle":
        return "Strength Day";
      case "Lose Weight":
        return "Fat Burn";
      case "Improve Stamina":
        return "Cardio Focus";
      case "Maintain Fitness":
      default:
        return "Balanced Workout";
    }
  }

  static String _motivationTip(String goal) {
    switch (goal) {
      case "Build Muscle":
        return "Increase protein today!";
      case "Lose Weight":
        return "Try a long walk!";
      case "Improve Stamina":
        return "Do intervals today!";
      case "Maintain Fitness":
      default:
        return "Stay consistent today!";
    }
  }
}
