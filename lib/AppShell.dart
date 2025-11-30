

import 'package:athlynew/tabs/mealPlanner.dart';
import 'package:athlynew/tabs/workouts.dart';
import 'package:flutter/material.dart';
import 'package:athlynew/colors.dart';
import 'package:athlynew/tabs/home.dart';
import 'package:athlynew/goalSetting.dart';
import 'package:athlynew/tabs/profilePage.dart';
import 'package:athlynew/tabs/Timer/Timer.dart';




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
      const ProfilePage(),
    ];

    return Scaffold(
      body: IndexedStack(index: _index, children: pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppColors.navy, // or your primary color
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.fitness_center_rounded), label: "Workouts"),
          BottomNavigationBarItem(icon: Icon(Icons.timer_rounded), label: "Timer"),
          BottomNavigationBarItem(icon: Icon(Icons.restaurant_menu_rounded), label: "Meal Plan"),
          BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: "Profile"),
        ],
      ),
    );
  }
}

/// Call this from any onPressed in your UI to log out.


class _Placeholder extends StatelessWidget {
  final String title;
  const _Placeholder(this.title, {super.key});
  @override
  Widget build(BuildContext context) =>
      Center(child: Text(title, style: const TextStyle(fontSize: 22)));
}
