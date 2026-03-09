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

  DailyWorkout({ // a constructor 
    required this.day,
    required this.title,
    this.workoutId,
    required this.isRestDay,
    required this.description,
  });
}

class WorkoutPlanService {
  // get the user form the firebase 
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // 7-day workout plan
  static final List<DailyWorkout> weeklyPlan = [ // a list of a weekly plan that include the workouts for each day 
    // Day 1: Lower Body (Squats, Push-ups, Plank, Glute bridges)
    DailyWorkout( // each one is an object form the class DailyWorkout
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
  
// ----------------- getTodaysWorkout() method ------------------
  /// Get today's workout based on the user's start date
  static Future<DailyWorkout> getTodaysWorkout() async {
    final user = _auth.currentUser; // gets the currnlty liggin user 
    if (user == null) { // if no usr is logged 
      return weeklyPlan[0]; // Default to Day 1 - the first workout 
    }

    try {
      // fetch the user documernt (info) form firestore 
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      
      if (!userDoc.exists) { // the doc are not exist 
        // First time user, set start date to today
        await _firestore.collection('users').doc(user.uid).set({ // create a doc with the todays date 
          'planStartDate': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true)); //  don't overwrite existing fields
        return weeklyPlan[0]; //  Return Day 1 of the plan
      }

      // the else case 
      final data = userDoc.data(); // get the data in the user doc 
      final startTimestamp = data?['planStartDate'] as Timestamp?; // get the planStartDate feild and cast it to timestamp (so firebase accept it ) 
      
      if (startTimestamp == null) {
        // Set start date if missing
        await _firestore.collection('users').doc(user.uid).update({ // Add the start date now
          'planStartDate': FieldValue.serverTimestamp(),
        });
        return weeklyPlan[0]; // day one plan 
      }

      final startDate = startTimestamp.toDate(); // Convert Firebase Timestamp to Dart DateTime
      final today = DateTime.now(); // Get today's date
      final daysSinceStart = today.difference(startDate).inDays;// Calculate how many days have passed since the user started the plan
      
      // Get the day in the weekly cycle (0-6)
      final dayIndex = daysSinceStart % 7; // get position in 7-day cycle
      
      return weeklyPlan[dayIndex]; // return the correct workout for today

    } catch (e) { // of any axception happen 
      print('Error getting today\'s workout: $e');
      return weeklyPlan[0];
    }
  }

//-----------getTodaysWorkoutDetails() Method--------------
  /// Get the actual Workout object for today's plan
  static Workout? getTodaysWorkoutDetails(DailyWorkout dailyWorkout) {
    if (dailyWorkout.workoutId == null) return null; // Takes a DailyWorkout and returns the full Workout object (or null)

    // Search through all categories for the workout -- loop -- search all 
    for (final category in workoutCategories) {
      for (final workout in category.workouts) {
        if (workout.id == dailyWorkout.workoutId) {
          return workout;
        }
      }
    }
    return null;
  }

// -----------------completeWorkout() Method ----------------------
  /// Mark today's workout as complete and award points
  static Future<void> completeWorkout(String workoutLevel) async { // takes the workouts difficulty level as input
    final user = _auth.currentUser; // if no user logged in -> exist 
    if (user == null) return;

    final today = _getDateString(DateTime.now()); // tdy date as a string 
    
    // Calculate points based on level
    int points = 0;
    switch (workoutLevel) { // switch case to determain the points value 
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
      final workoutDoc = await userRef.collection('workouts').doc(today).get(); // Check if today's workout document already exists
      
      if (workoutDoc.exists && workoutDoc.data()?['completed'] == true) {
        // Already completed today
        return;
      }

      // Use batch write to update both collections atomically (success or fail ) all operations 
      final batch = _firestore.batch(); 
      
      // Mark workout as complete - Add to batch
      batch.set(
        userRef.collection('workouts').doc(today),
        {
          'completed': true,
          'timestamp': FieldValue.serverTimestamp(),
          'points': points,
          'level': workoutLevel,
        },
      );
      
      // Add points to user's total - Add to batch
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
    } catch (e) { // any exception 
      print('❌ Error completing workout: $e');
      rethrow;
    }
  }
// ---------------- streaks --------------------
  //----------------getCurrentStreak() Method---------------
  static Future<int> getCurrentStreak() async {
    //Returns streak count, or 0 if not logged in
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

      if (snapshot.docs.isEmpty) return 0; // No workouts recorded = 0 streak

      // else case 
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

      for (int i = 0; i < 365; i++) { // streal mush be complete for all days in a row - none stop 
        final dateStr = _getDateString(checkDate);
        
        if (completedDates.contains(dateStr)) {
          streak++; 
          // of not -> back to one (streak ended)
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
      if (!doc.exists) return 0; // Get current user, return 0 if not logged in
      
      final data = doc.data();//Fetch user document
      return (data?['totalPoints'] as int?) ?? 0;//Return 0 if document doesn't exist
    } catch (e) {
      print('❌ Error getting total points: $e');
      return 0;
    }
  }

  /// ------------isTodayWorkoutCompleted() Method------------
  static Future<bool> isTodayWorkoutCompleted() async { // Returns true/false, false if not logged in
    final user = _auth.currentUser;
    if (user == null) return false;

    final today = _getDateString(DateTime.now()); //Get today's date string
    
    try { // Fetch today's workout document
      final doc = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('workouts')
          .doc(today)
          .get();
      
      return doc.exists && (doc.data()?['completed'] == true); // true only if  Document exists & The completed field is true
    } catch (e) {
      print('❌ Error checking workout completion: $e');
      return false;
    }
  }

  static String _getDateString(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}