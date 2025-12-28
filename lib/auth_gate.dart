import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'AppShell.dart';
import 'main.dart'; // For WelcomeScreen
import 'goalSetting.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool isLoading = true;
  Widget? targetScreen;

  @override
  void initState() {
    super.initState();
    checkAuthState();
  }

  Future<void> checkAuthState() async {
    print('\n🔵 AuthGate: Checking auth state...');
    
    await Future.delayed(const Duration(seconds: 1)); // optional splash delay
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      print('❌ No user logged in → WelcomeScreen');
      setState(() {
        targetScreen = const WelcomeScreen();
        isLoading = false;
      });
      return;
    }

    print('✅ User logged in: ${user.uid}');
    print('   Email: ${user.email}');
    print('   DisplayName: ${user.displayName}');

    // Check if user has completed goal setting
    try {
      print('🔵 Checking if user has preferences in Firestore...');
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (doc.exists) {
        final data = doc.data();
        final hasGoalPrefs = data?.containsKey('goal') ?? false;
        
        print('📄 User document exists');
        print('   Has goal preferences: $hasGoalPrefs');

        if (hasGoalPrefs) {
          print('✅ User has completed onboarding → AppShell');
          setState(() {
            targetScreen = const AppShell();
            isLoading = false;
          });
        } else {
          print('⚠️ User needs to set goals → GoalSettingScreen');
          setState(() {
            targetScreen = const GoalSettingScreen();
            isLoading = false;
          });
        }
      } else {
        print('⚠️ User document does not exist → GoalSettingScreen');
        setState(() {
          targetScreen = const GoalSettingScreen();
          isLoading = false;
        });
      }
    } catch (e) {
      print('❌ Error checking Firestore: $e');
      // If Firestore check fails, default to GoalSettingScreen
      setState(() {
        targetScreen = const GoalSettingScreen();
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    
    return targetScreen ?? const WelcomeScreen();
  }
}