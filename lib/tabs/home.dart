// lib/home.dart
import 'package:flutter/material.dart';
import 'package:athlynew/colors.dart';
import 'package:athlynew/goalSetting.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:athlynew/services/workout_plan_service.dart';
import 'package:athlynew/tabs/workouts.dart';

class HomeScreen extends StatefulWidget {
  final GoalPreferences? prefs;
  const HomeScreen({super.key, this.prefs});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  int _streakDays = 0;
  int _totalPoints = 0;
  bool _isLoadingStreak = true;
  bool _isLoadingPoints = true;
  DailyWorkout? _todaysWorkout;
  bool _isTodayCompleted = false;
  
  // Hydration tracking
  int _hydrationCurrent = 0;
  int _hydrationGoal = 8;
  bool _isLoadingHydration = true;
  bool _isAddingWater = false; // Prevent spam taps
  
  // Animation controller for water tap
  late AnimationController _waterAnimController;
  late Animation<double> _waterScaleAnim;
  
  // Calories tracking
  int _caloriesCurrent = 0;
  int _caloriesGoal = 2200;  // Will be updated based on user goal

  @override
  void initState() {
    super.initState();
    _setCalorieGoal();  // Set calorie goal based on user's fitness goal
    _loadUserData();
    _loadHydration();
    _loadCalories();
    
    // Setup water tap animation
    _waterAnimController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _waterScaleAnim = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _waterAnimController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _waterAnimController.dispose();
    super.dispose();
  }

  void _setCalorieGoal() {
    final goal = widget.prefs?.goal ?? "Maintain Fitness";
    
    // Set calorie goal based on fitness goal
    switch (goal) {
      case "Build Muscle":
        _caloriesGoal = 2800;  // Higher calories for muscle building
        break;
      case "Lose Weight":
        _caloriesGoal = 1800;  // Lower calories for weight loss
        break;
      case "Improve Stamina":
        _caloriesGoal = 2400;  // Moderate-high for endurance
        break;
      case "Maintain Fitness":
      default:
        _caloriesGoal = 2200;  // Maintenance calories
        break;
    }
  }

  Future<void> _loadHydration() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() => _isLoadingHydration = false);
      return;
    }

    final today = _getDateString(DateTime.now());
    
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('hydration')
          .doc(today)
          .get();

      if (mounted) {
        setState(() {
          _hydrationCurrent = doc.data()?['cups'] ?? 0;
          _isLoadingHydration = false;
        });
      }
    } catch (e) {
      print('❌ Error loading hydration: $e');
      if (mounted) {
        setState(() => _isLoadingHydration = false);
      }
    }
  }

  Future<void> _addHydration() async {
    // Prevent spam taps
    if (_isAddingWater) return;
    
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    if (_hydrationCurrent >= _hydrationGoal) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🎉 Daily hydration goal reached!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    setState(() => _isAddingWater = true);
    
    // ✨ Play animation
    _waterAnimController.forward().then((_) {
      _waterAnimController.reverse();
    });

    final today = _getDateString(DateTime.now());
    final newCount = _hydrationCurrent + 1;

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('hydration')
          .doc(today)
          .set({
        'cups': newCount,
        'timestamp': FieldValue.serverTimestamp(),
      });

      setState(() {
        _hydrationCurrent = newCount;
      });

      if (newCount == _hydrationGoal) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('💧 Hydration goal completed!'),
            backgroundColor: Colors.blue,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      print('❌ Error adding hydration: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to update hydration'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      // Re-enable after 500ms debounce
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          setState(() => _isAddingWater = false);
        }
      });
    }
  }

  Future<void> _loadCalories() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      // Calculate calories based on completed workouts
      final workoutsSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('workouts')
          .where('completed', isEqualTo: true)
          .get();

      int totalCalories = 0;
      for (var doc in workoutsSnapshot.docs) {
        // Each workout burns approximately 150 calories
        totalCalories += 150;
      }

      if (mounted) {
        setState(() {
          _caloriesCurrent = totalCalories;
        });
      }
    } catch (e) {
      print('❌ Error loading calories: $e');
    }
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoadingStreak = true;
      _isLoadingPoints = true;
    });
    
    try {
      // Load streak, points, and today's workout in parallel
      final results = await Future.wait([
        WorkoutPlanService.getCurrentStreak(),
        WorkoutPlanService.getTotalPoints(),
        WorkoutPlanService.getTodaysWorkout(),
        WorkoutPlanService.isTodayWorkoutCompleted(),
      ]).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          print('⚠️ Timeout loading user data, using defaults');
          return [0, 0, WorkoutPlanService.weeklyPlan[0], false];
        },
      );
      
      if (mounted) {
        setState(() {
          _streakDays = results[0] as int;
          _totalPoints = results[1] as int;
          _todaysWorkout = results[2] as DailyWorkout;
          _isTodayCompleted = results[3] as bool;
          _isLoadingStreak = false;
          _isLoadingPoints = false;
        });
        
        // Reload calories after workout data is loaded
        _loadCalories();
      }
    } catch (e) {
      print('❌ Error loading user data: $e');
      if (mounted) {
        setState(() {
          _streakDays = 0;
          _totalPoints = 0;
          _todaysWorkout = WorkoutPlanService.weeklyPlan[0];
          _isTodayCompleted = false;
          _isLoadingStreak = false;
          _isLoadingPoints = false;
        });
      }
    }
  }

  String _getDateString(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final goal = widget.prefs?.goal ?? "Maintain Fitness";
    const dailyHighlight = "Remember to stretch!";

    final focusLabel = _focusBasedOnGoal(goal);
    final motivation = _motivationTip(goal);

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return _buildGuestHome(context, focusLabel, motivation, 0, 0, dailyHighlight);
    }

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
          return Scaffold(
            backgroundColor: AppColors.background,
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        String userName = 'User';
        if (snapshot.hasData && snapshot.data!.exists) {
          final data = snapshot.data!.data() as Map<String, dynamic>?;
          userName = data?['name'] ?? user.displayName ?? 'User';
        } else if (user.displayName != null && user.displayName!.isNotEmpty) {
          userName = user.displayName!;
        }

        final firstName = userName.split(' ')[0];

        return _buildHomeContent(
          context,
          firstName,
          focusLabel,
          motivation,
          _streakDays,
          _totalPoints,
          _isLoadingStreak,
          _isLoadingPoints,
          dailyHighlight,
        );
      },
    );
  }

  Widget _buildHomeContent(
    BuildContext context,
    String firstName,
    String focusLabel,
    String motivation,
    int streakDays,
    int totalPoints,
    bool isLoadingStreak,
    bool isLoadingPoints,
    String dailyHighlight,
  ) {
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
                // Header with name - IMPROVED
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Hey, $firstName!",
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textDark,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          // Streak
                          isLoadingStreak
                              ? const Row(
                                  children: [
                                    SizedBox(
                                      width: 14,
                                      height: 14,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      "Loading...",
                                      style: TextStyle(
                                        fontFamily: "Poppins",
                                        fontSize: 14,
                                        color: Colors.black54,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                )
                              : Text(
                                  streakDays > 0
                                      ? "$streakDays-day streak 🔥"
                                      : "Start your streak! 💪",
                                  style: const TextStyle(
                                    fontFamily: "Poppins",
                                    fontSize: 15,
                                    color: Colors.black54,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ],
                      ),
                    ),
                    // Points Badge - IMPROVED
                    if (!isLoadingPoints)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [AppColors.primary, Colors.orangeAccent.shade400],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.star_rounded, size: 20, color: Colors.white),
                            const SizedBox(width: 6),
                            Text(
                              "$totalPoints pts",
                              style: const TextStyle(
                                fontFamily: "Poppins",
                                fontSize: 14,
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                
                const SizedBox(height: 28),

                // Today's Workout Card
                _todayWorkoutCard(context),

                const SizedBox(height: 20),

                // Stats Row - IMPROVED (2 columns for better visibility)
                Row(
                  children: [
                    Expanded(
                      child: _statCard(
                        color: AppColors.accentBlue.withOpacity(0.3),
                        icon: Icons.local_fire_department_rounded,
                        label: "Calories",
                        value: "$_caloriesCurrent / $_caloriesGoal",
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: _addHydration,
                        child: AnimatedBuilder(
                          animation: _waterScaleAnim,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: _waterScaleAnim.value,
                              child: _isLoadingHydration
                                  ? Container(
                                      constraints: const BoxConstraints(
                                        minHeight: 150,
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 16),
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
                                    )
                                  : _buildHydrationCard(_hydrationCurrent / _hydrationGoal),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                _dailyHighlightCard(
                  icon: Icons.lightbulb_outline,
                  title: "Daily Highlight",
                  subtitle: dailyHighlight,
                ),

                const SizedBox(height: 28),

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

  Widget _todayWorkoutCard(BuildContext context) {
    if (_todaysWorkout == null) {
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
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    final workout = _todaysWorkout!;

    // Rest Day Card
    if (workout.isRestDay) {
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
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Today's Workout",
                    style: TextStyle(
                      fontFamily: "Poppins",
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.spa_outlined,
                        size: 20,
                        color: Colors.green.shade600,
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          workout.title,
                          style: TextStyle(
                            fontFamily: "Poppins",
                            fontSize: 14,
                            color: Colors.green.shade700,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    workout.description,
                    style: const TextStyle(
                      fontFamily: "Poppins",
                      fontSize: 12,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // Regular Workout Card - IMPROVED
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
          const Text(
            "Today's Workout",
            style: TextStyle(
              fontFamily: "Poppins",
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Colors.black87,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              // Workout Icon with gradient background
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.navy.withOpacity(0.1), AppColors.secondary.withOpacity(0.1)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.fitness_center_rounded,
                  size: 24,
                  color: AppColors.navy,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      workout.title,
                      style: const TextStyle(
                        fontFamily: "Poppins",
                        fontSize: 16,
                        color: Colors.black87,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      workout.description,
                      style: const TextStyle(
                        fontFamily: "Poppins",
                        fontSize: 13,
                        color: Colors.black54,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Action Button
          if (_isTodayCompleted)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.green.shade200, width: 2),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle_rounded, size: 20, color: Colors.green.shade700),
                  const SizedBox(width: 8),
                  Text(
                    "Completed",
                    style: TextStyle(
                      fontFamily: "Poppins",
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: Colors.green.shade700,
                    ),
                  ),
                ],
              ),
            )
          else
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  // Navigate to workout detail
                  final workoutDetails = WorkoutPlanService.getTodaysWorkoutDetails(workout);
                  
                  if (workoutDetails != null) {
                    // Navigate to existing workout detail screen
                    await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => WorkoutDetailScreen(
                          workout: workoutDetails,
                          isFromTodayPlan: true,
                        ),
                      ),
                    );
                    // Reload data after returning
                    _loadUserData();
                  } else {
                    // Show message for workouts without detail screen
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Complete: ${workout.description}'),
                          action: SnackBarAction(
                            label: 'Done',
                            onPressed: () async {
                              await WorkoutPlanService.completeWorkout('All levels');
                              _loadUserData();
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('🎉 Workout completed!'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              }
                            },
                          ),
                        ),
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.navy,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  "Start Workout",
                  style: TextStyle(
                    fontFamily: "Poppins",
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildGuestHome(
    BuildContext context,
    String focusLabel,
    String motivation,
    int streakDays,
    int totalPoints,
    String dailyHighlight,
  ) {
    return _buildHomeContent(
      context,
      'Guest',
      focusLabel,
      motivation,
      0,
      0,
      false,
      false,
      dailyHighlight,
    );
  }

  Widget _statCard({
    required Color color,
    required IconData icon,
    required String label,
    required String value,
    bool isInteractive = false,
  }) {
    return Container(
      constraints: const BoxConstraints(
        minHeight: 150,
      ),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
        border: isInteractive ? Border.all(color: Colors.blue.shade700, width: 2) : null,
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
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
          if (isInteractive) ...[
            const SizedBox(height: 6),
            Text(
              'Tap to add',
              style: TextStyle(
                fontFamily: "Poppins",
                fontSize: 11,
                color: Colors.blue.shade900,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _dailyHighlightCard({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.amber.shade50,
            Colors.orange.shade50,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.amber.shade200, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.amber.withOpacity(.15),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              icon,
              size: 28,
              color: Colors.amber.shade700,
            ),
          ),
          const SizedBox(width: 16),
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
                  style: TextStyle(
                    fontFamily: "Poppins",
                    fontSize: 14,
                    color: Colors.black.withOpacity(0.7),
                    fontWeight: FontWeight.w500,
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

  Widget _buildHydrationCard(double progress) {
    return Container(
      constraints: const BoxConstraints(
        minHeight: 150,
      ),
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
                child: const Icon(Icons.water_drop_rounded, size: 28, color: Colors.blue),
              ),
              const Spacer(),
              if (_isAddingWater)
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
            "$_hydrationCurrent / $_hydrationGoal glasses",
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