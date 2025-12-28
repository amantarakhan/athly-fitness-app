import 'package:flutter/material.dart';
import 'package:athlynew/colors.dart';
import 'package:athlynew/goalSetting.dart';

// Import all your tab screens
import 'package:athlynew/tabs/home.dart';
import 'package:athlynew/tabs/workouts.dart';
import 'package:athlynew/tabs/Timer/Timer.dart';
import 'package:athlynew/tabs/mealPlanner.dart';
import 'package:athlynew/tabs/profilePage.dart';

class AppShell extends StatefulWidget {
  final GoalPreferences? prefs; // received from GoalSetting
  const AppShell({super.key, this.prefs});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      HomeScreen(prefs: widget.prefs),
      const WorkoutsScreen(),
      const TimerScreen(),
      const MealPlanScreen(),
      ProfilePage(),  // ✅ Removed 'const' because ProfilePage uses StreamBuilder
    ];

    return Scaffold(
      body: IndexedStack(index: _index, children: pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppColors.navy,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        elevation: 8,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.fitness_center_rounded),
            label: "Workouts",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.timer_rounded),
            label: "Timer",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant_menu_rounded),
            label: "Meal Plan",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_rounded),
            label: "Profile",
          ),
        ],
      ),
    );
  }
}