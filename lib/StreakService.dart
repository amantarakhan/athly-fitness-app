import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class StreakService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Mark today as completed (call this when user finishes a workout)
  static Future<void> markTodayComplete() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final today = _getDateString(DateTime.now());
    
    print('🔵 Marking today ($today) as complete...');

    try {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('workouts')
          .doc(today)
          .set({
        'completed': true,
        'timestamp': FieldValue.serverTimestamp(),
      });
      
      print('✅ Today marked complete!');
    } catch (e) {
      print('❌ Error marking today complete: $e');
    }
  }

  /// Get the current streak (consecutive days with workouts)
  static Future<int> getCurrentStreak() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return 0;

    try {
      print('🔵 Calculating current streak...');

      // Get all workout completion records, sorted by date descending
      final snapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('workouts')
          .orderBy('timestamp', descending: true)
          .limit(365) // Last year max
          .get();

      if (snapshot.docs.isEmpty) {
        print('⚠️ No workout records found');
        return 0;
      }

      // Get completed dates
      final completedDates = snapshot.docs
          .where((doc) => doc.data()['completed'] == true)
          .map((doc) => doc.id) // doc.id is the date string (yyyy-MM-dd)
          .toList();

      if (completedDates.isEmpty) {
        print('⚠️ No completed workouts found');
        return 0;
      }

      print('📊 Found ${completedDates.length} completed workout days');

      // Calculate streak
      final streak = _calculateStreak(completedDates);
      print('✅ Current streak: $streak days');
      
      return streak;
    } catch (e) {
      print('❌ Error calculating streak: $e');
      return 0;
    }
  }

  /// Calculate streak from list of date strings
  static int _calculateStreak(List<String> completedDates) {
    if (completedDates.isEmpty) return 0;

    // Sort dates in descending order (most recent first)
    completedDates.sort((a, b) => b.compareTo(a));

    final now = DateTime.now();
    final today = _getDateString(now);
    final yesterday = _getDateString(now.subtract(const Duration(days: 1)));

    // Check if streak is still active (workout today or yesterday)
    if (!completedDates.contains(today) && !completedDates.contains(yesterday)) {
      print('⚠️ Streak broken - no workout today or yesterday');
      return 0;
    }

    // Count consecutive days
    int streak = 0;
    DateTime checkDate = now;

    // Start from today and go backwards
    for (int i = 0; i < 365; i++) {
      final dateStr = _getDateString(checkDate);
      
      if (completedDates.contains(dateStr)) {
        streak++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      } else {
        // Streak broken
        break;
      }
    }

    return streak;
  }

  /// Convert DateTime to date string (yyyy-MM-dd)
  static String _getDateString(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// Get total number of workouts completed
  static Future<int> getTotalWorkouts() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return 0;

    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('workouts')
          .where('completed', isEqualTo: true)
          .get();

      return snapshot.docs.length;
    } catch (e) {
      print('❌ Error getting total workouts: $e');
      return 0;
    }
  }

  /// Check if user has completed workout today
  static Future<bool> hasCompletedToday() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;

    final today = _getDateString(DateTime.now());

    try {
      final doc = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('workouts')
          .doc(today)
          .get();

      return doc.exists && doc.data()?['completed'] == true;
    } catch (e) {
      print('❌ Error checking today: $e');
      return false;
    }
  }
}