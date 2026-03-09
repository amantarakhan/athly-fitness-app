import 'package:flutter/material.dart';
import 'package:athlynew/services/workout_plan_service.dart';

// all the workouts logic is here (if the user completed the workout appear completed when he opens it from the workouts screen ) 
class WorkoutProvider with ChangeNotifier {
  int _streakDays = 0;
  int _totalPoints = 0;
  int _totalWorkouts = 0;
  DailyWorkout? _todaysWorkout;
  bool _isTodayCompleted = false;
  bool _isLoading = true;

  int get streakDays => _streakDays;
  int get totalPoints => _totalPoints;
  int get totalWorkouts => _totalWorkouts;
  DailyWorkout? get todaysWorkout => _todaysWorkout;
  bool get isTodayCompleted => _isTodayCompleted;
  bool get isLoading => _isLoading;

// Load all workout data
  Future<void> loadWorkoutData() async {
    _isLoading = true;
    notifyListeners();

    try {
      final results = await Future.wait([ 
        WorkoutPlanService.getCurrentStreak(),
        WorkoutPlanService.getTotalPoints(),
        WorkoutPlanService.getTodaysWorkout(),
        WorkoutPlanService.isTodayWorkoutCompleted(),
      ]);
      // Calls WorkoutPlanService methods to get the values 
      _streakDays = results[0] as int;
      _totalPoints = results[1] as int;
      _todaysWorkout = results[2] as DailyWorkout;
      _isTodayCompleted = results[3] as bool;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print('Error loading workout data: $e');
      _isLoading = false;
      notifyListeners();
    }
  }
 // when a user Complete a workout
  Future<void> completeWorkout(String level) async {
    await WorkoutPlanService.completeWorkout(level);
    await loadWorkoutData(); //  Refresh everything
    // notifyListeners() called in loadWorkoutData()
  }
}