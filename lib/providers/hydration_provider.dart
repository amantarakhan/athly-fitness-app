import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// all the hydation logic is here 
class HydrationProvider with ChangeNotifier {
  int _currentCups = 0;
  final int _goalCups = 8;
  bool _isLoading = true;
  bool _isAdding = false; // Prevents spam taps

  int get currentCups => _currentCups;
  int get goalCups => _goalCups;
  bool get isLoading => _isLoading;
  bool get isAdding => _isAdding;
  double get progress => _currentCups / _goalCups;

// Load today's hydration
  Future<void> loadHydration() async {
    final user = FirebaseAuth.instance.currentUser; // Load from Firestore..
    if (user == null) {  
      _isLoading = false;
      notifyListeners(); // update all pages using it (home , mealplanner) 
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

      _currentCups = doc.data()?['cups'] ?? 0; // get the data from firestore 
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print('Error loading hydration: $e');
      _isLoading = false;
      notifyListeners();
    }
  }
// Add one cup of water
  Future<bool> addCup() async {
    if (_isAdding || _currentCups >= _goalCups) return false;

    _isAdding = true;
    notifyListeners();// Show loading spinner

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _isAdding = false;
      notifyListeners();
      return false;
    }

    final today = _getDateString(DateTime.now());
    final newCount = _currentCups + 1;

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

      // Save to Firestore the new value 
      _currentCups = newCount;
      _isAdding = false;
      notifyListeners();
      return true;
    } catch (e) {
      print('Error adding hydration: $e');
      _isAdding = false;
      notifyListeners(); // Update UI in all 
      return false;
    }
  }

  String _getDateString(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}