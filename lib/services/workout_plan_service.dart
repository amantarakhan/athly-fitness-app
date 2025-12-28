// lib/services/workout_plan_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:athlynew/models/workout.dart';
import 'package:athlynew/data/workouts_data.dart';

class DailyWorkout {
  final String day;
  final String title;
  final String? workoutId; // null for rest days
  final bool isRestDay;
  final String description;

  DailyWorkout({
    required this.day,
    required this.title,
    this.workoutId,
    required this.isRestDay,
    required this.description,
  });
}

class WorkoutPlanService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // 7-day workout plan
  static final List<DailyWorkout> weeklyPlan = [
    // Day 1: Lower Body (Squats, Push-ups, Plank, Glute bridges)
    DailyWorkout(
      day: 'Day 1',
      title: 'Lower Body Strength',
      workoutId: 'lb_glute_activation', // From workouts_data.dart
      isRestDay: false,
      description: 'Squats, Push-ups, Plank, Glute bridges',
    ),
    // Day 2: Cardio
    DailyWorkout(
      day: 'Day 2',
      title: 'Cardio Day',
      workoutId: null, // Could add a cardio workout if you have one
      isRestDay: false,
      description: 'Brisk walking, jogging, or cycling - 30 mins',
    ),
    // Day 3: Stretching/Yoga
    DailyWorkout(
      day: 'Day 3',
      title: 'Recovery & Flexibility',
      workoutId: null,
      isRestDay: false,
      description: 'Stretching or yoga session',
    ),
    // Day 4: Upper Body
    DailyWorkout(
      day: 'Day 4',
      title: 'Upper Body Strength',
      workoutId: 'ub_pushups_intro', // From workouts_data.dart
      isRestDay: false,
      description: 'Shoulder press, Bicep curls, Tricep dips, Push-ups',
    ),
    // Day 5: Lower Body (different focus)
    DailyWorkout(
      day: 'Day 5',
      title: 'Lower Body Power',
      workoutId: 'lb_sweaty_strength', // From workouts_data.dart
      isRestDay: false,
      description: 'Lunges, Wall sit, Calf raises, Bicycle crunch',
    ),
    // Day 6: Light Cardio
    DailyWorkout(
      day: 'Day 6',
      title: 'Active Recovery',
      workoutId: null,
      isRestDay: false,
      description: 'Light cardio: dancing, swimming, hiking, or cycling',
    ),
    // Day 7: Rest
    DailyWorkout(
      day: 'Day 7',
      title: 'Rest Day',
      workoutId: null,
      isRestDay: true,
      description: 'Take a well-deserved rest and let your muscles recover',
    ),
  ];

  /// Get today's workout based on the user's start date
  static Future<DailyWorkout> getTodaysWorkout() async {
    final user = _auth.currentUser;
    if (user == null) {
      return weeklyPlan[0]; // Default to Day 1
    }

    try {
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      
      if (!userDoc.exists) {
        // First time user, set start date to today
        await _firestore.collection('users').doc(user.uid).set({
          'planStartDate': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
        return weeklyPlan[0];
      }

      final data = userDoc.data();
      final startTimestamp = data?['planStartDate'] as Timestamp?;
      
      if (startTimestamp == null) {
        // Set start date if missing
        await _firestore.collection('users').doc(user.uid).update({
          'planStartDate': FieldValue.serverTimestamp(),
        });
        return weeklyPlan[0];
      }

      final startDate = startTimestamp.toDate();
      final today = DateTime.now();
      final daysSinceStart = today.difference(startDate).inDays;
      
      // Get the day in the weekly cycle (0-6)
      final dayIndex = daysSinceStart % 7;
      
      return weeklyPlan[dayIndex];
    } catch (e) {
      print('Error getting today\'s workout: $e');
      return weeklyPlan[0];
    }
  }

  /// Get the actual Workout object for today's plan
  static Workout? getTodaysWorkoutDetails(DailyWorkout dailyWorkout) {
    if (dailyWorkout.workoutId == null) return null;

    // Search through all categories for the workout
    for (final category in workoutCategories) {
      for (final workout in category.workouts) {
        if (workout.id == dailyWorkout.workoutId) {
          return workout;
        }
      }
    }
    return null;
  }

  /// Mark today's workout as complete and award points
  static Future<void> completeWorkout(String workoutLevel) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final today = _getDateString(DateTime.now());
    
    // Calculate points based on level
    int points = 0;
    switch (workoutLevel) {
      case 'Beginner':
        points = 20;
        break;
      case 'Intermediate':
        points = 60;
        break;
      case 'All levels':
        points = 40;
        break;
    }

    try {
      final userRef = _firestore.collection('users').doc(user.uid);
      
      // Check if workout already completed today
      final workoutDoc = await userRef.collection('workouts').doc(today).get();
      
      if (workoutDoc.exists && workoutDoc.data()?['completed'] == true) {
        // Already completed today
        return;
      }

      // Use batch write to update both collections atomically
      final batch = _firestore.batch();
      
      // Mark workout as complete
      batch.set(
        userRef.collection('workouts').doc(today),
        {
          'completed': true,
          'timestamp': FieldValue.serverTimestamp(),
          'points': points,
          'level': workoutLevel,
        },
      );
      
      // Add points to user's total
      batch.set(
        userRef,
        {
          'totalPoints': FieldValue.increment(points),
          'lastWorkoutDate': today,
        },
        SetOptions(merge: true),
      );
      
      await batch.commit();
      print('✅ Workout completed! Awarded $points points');
    } catch (e) {
      print('❌ Error completing workout: $e');
      rethrow;
    }
  }

  /// Calculate current streak
  static Future<int> getCurrentStreak() async {
    final user = _auth.currentUser;
    if (user == null) return 0;

    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('workouts')
          .orderBy('timestamp', descending: true)
          .limit(365)
          .get();

      if (snapshot.docs.isEmpty) return 0;

      final completedDates = snapshot.docs
          .where((doc) => doc.data()['completed'] == true)
          .map((doc) => doc.id)
          .toList();

      if (completedDates.isEmpty) return 0;

      completedDates.sort((a, b) => b.compareTo(a));

      final now = DateTime.now();
      final today = _getDateString(now);
      final yesterday = _getDateString(now.subtract(const Duration(days: 1)));

      // Streak must include today or yesterday
      if (!completedDates.contains(today) && !completedDates.contains(yesterday)) {
        return 0;
      }

      int streak = 0;
      DateTime checkDate = now;

      for (int i = 0; i < 365; i++) {
        final dateStr = _getDateString(checkDate);
        
        if (completedDates.contains(dateStr)) {
          streak++;
          checkDate = checkDate.subtract(const Duration(days: 1));
        } else {
          break;
        }
      }

      return streak;
    } catch (e) {
      print('❌ Error calculating streak: $e');
      return 0;
    }
  }

  /// Get user's total points
  static Future<int> getTotalPoints() async {
    final user = _auth.currentUser;
    if (user == null) return 0;

    try {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (!doc.exists) return 0;
      
      final data = doc.data();
      return (data?['totalPoints'] as int?) ?? 0;
    } catch (e) {
      print('❌ Error getting total points: $e');
      return 0;
    }
  }

  /// Check if today's workout is already completed
  static Future<bool> isTodayWorkoutCompleted() async {
    final user = _auth.currentUser;
    if (user == null) return false;

    final today = _getDateString(DateTime.now());
    
    try {
      final doc = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('workouts')
          .doc(today)
          .get();
      
      return doc.exists && (doc.data()?['completed'] == true);
    } catch (e) {
      print('❌ Error checking workout completion: $e');
      return false;
    }
  }

  static String _getDateString(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}