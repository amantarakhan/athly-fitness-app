import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// all the user info (name / email ) is here 
//UserProvider - Manages User Authentication & Profile
class UserProvider with ChangeNotifier {
  User? _currentUser; // Firebase Auth user
  Map<String, dynamic>? _userData;  // Firestore user document
  bool _isLoading = true;

  User? get currentUser => _currentUser;
  Map<String, dynamic>? get userData => _userData;
  bool get isLoading => _isLoading;
  // Getters
  String get userName => _userData?['name'] ?? _currentUser?.displayName ?? 'User'; // reading from the firestore 
  String get userEmail => _userData?['email'] ?? _currentUser?.email ?? '';


  UserProvider() {
    _initUser();
  }
// Automatically listens to auth changes
  void _initUser() {
    FirebaseAuth.instance.authStateChanges().listen((user) {
      _currentUser = user;
      if (user != null) { // first time 
        _loadUserData(); // Load from Firestore
      } else {
        _userData = null;
        _isLoading = false;
        notifyListeners(); // update the screens (home , profile ) 
      }
    });
  }

  Future<void> _loadUserData() async {
    if (_currentUser == null) return;
    
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(_currentUser!.uid)
          .get();
      
      _userData = doc.data();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print('Error loading user data: $e');
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshUserData() async {
    await _loadUserData();
  }
}