import 'package:athlynew/colors.dart';
import 'package:flutter/material.dart';

// Import your custom timer view files
import 'classic_timer_view.dart';
import 'interval_timer_view.dart';
import 'circuit_timer_view.dart';

class TimerScreen extends StatelessWidget {
  const TimerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3, // Classic, Interval, Circuit
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.navy,
          foregroundColor: Colors.white,
          elevation: 0,
          automaticallyImplyLeading: false,
          centerTitle: true,
          title: const Text(
            'Workout Timers',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 25,
            ),
          ),
          bottom: TabBar(
            indicatorColor: AppColors.primary,
            indicatorWeight: 3,
            indicatorSize: TabBarIndicatorSize.tab,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white.withOpacity(0.6), // Cleaner contrast
            labelStyle: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 13,
              letterSpacing: 0.5,
            ),
            unselectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 13,
            ),
            tabs: const [
              Tab(
                icon: Icon(Icons.watch_later_outlined, size: 22),
                text: 'Classic',
              ),
              Tab(
                icon: Icon(Icons.repeat, size: 22),
                text: 'Interval',
              ),
              Tab(
                icon: Icon(Icons.list_alt, size: 22),
                text: 'Circuit',
              ),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            ClassicTimerView(),
            IntervalTimerView(),
            CircuitTimerView(),
          ],
        ),
      ),
    );
  }
}