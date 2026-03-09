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

// this file is just a container for all the primary screen in the app 
class _AppShellState extends State<AppShell> {
  int _index = 0; // this represnt which tab is currantly selected 
  // 0 = home  , 1 = workouts ,  2= timer , 3 = meals , 4 = profile 

  @override
  Widget build(BuildContext context) {
    // a list of all screens 
    final pages = <Widget>[
      HomeScreen(prefs: widget.prefs), // not const -> changes from user to another 
      const WorkoutsScreen(),
      const TimerScreen(),
      const MealPlanScreen(),
      ProfilePage(), // not const -> changes from user to another 
    ];

    return Scaffold(
      body: IndexedStack(index: _index, children: pages), // the body is one screen at the time based on the index 

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index, // teh active tab 
        onTap: (i) => setState(() => _index = i),
        //When the user taps a tab,
        // the bottom navigation bar updates the selected index using setState,
        // which rebuilds the widget and causes the IndexedStack to display the corresponding page.
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppColors.navy,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        elevation: 8,
        items: const [ // navigations items 
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: "Home", // index 0 
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.fitness_center_rounded),
            label: "Workouts",// index 1
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.timer_rounded),
            label: "Timer",// index 2
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant_menu_rounded),
            label: "Meal Plan",// index 3
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_rounded),
            label: "Profile",// index 4
          ),
        ],
      ),
    );
  }
}