import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:athlynew/colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:athlynew/providers/user_provider.dart';
import 'package:athlynew/providers/workout_provider.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
    // Load data when profile opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WorkoutProvider>().loadWorkoutData();
      context.read<UserProvider>().refreshUserData();
    });
  }

  Future<void> _refreshData() async {
    await Future.wait([
      context.read<WorkoutProvider>().loadWorkoutData(),
      context.read<UserProvider>().refreshUserData(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(
              color: AppColors.textDark, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
        actions: [
          // Refresh button
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppColors.textDark),
            onPressed: _refreshData,
            tooltip: 'Refresh',
          ),
          IconButton(
            icon: const Icon(Icons.settings_rounded, color: AppColors.textDark),
            onPressed: () {
              // Handle Settings navigation
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          children: <Widget>[
            //  USER PROVIDER - For name and email 
            Consumer<UserProvider>(
              builder: (context, userProvider, child) {
                return _buildProfileHeader(context, userProvider);
              },
            ),
            const SizedBox(height: 24),

            // 2️ WORKOUT PROVIDER - For points & streak card
            Consumer<WorkoutProvider>(
              builder: (context, workoutProvider, child) {
                return _buildStatsCard(workoutProvider);
              },
            ),
            const SizedBox(height: 24),

            //  WORKOUT PROVIDER - For workout stats
            Consumer<WorkoutProvider>(
              builder: (context, workoutProvider, child) {
                return _buildWorkoutStatsCard(workoutProvider);
              },
            ),
            const SizedBox(height: 32),

            // 4. Action List (Settings/General)
            const Text(
              'General',
              style: TextStyle(
                color: AppColors.textDark,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            _buildActionList(),
            const SizedBox(height: 24),

            // 5. Logout Button
            _buildLogoutButton(context),
          ],
        ),
      ),
    );
  }

  // --- Widget Builders ---

  Widget _buildProfileHeader(BuildContext context, UserProvider userProvider) {
    final user = FirebaseAuth.instance.currentUser;
    
    if (user == null) {
      return const Center(child: Text('Not logged in'));
    }

    if (userProvider.isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(40.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    final name = userProvider.userName;
    final email = userProvider.userEmail;

    return Center(
      child: Column(
        children: [
          // User Avatar
          CircleAvatar(
            radius: 40,
            backgroundColor: AppColors.primary.withOpacity(0.1),
            child: Icon(
              Icons.person_rounded,
              size: 50,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 12),

          // User Name (dynamic from provider)
          Text(
            name,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),

          // User Email (dynamic from provider)
          Text(
            email,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textDark.withOpacity(0.8),
            ),
          ),

          const SizedBox(height: 16),

          // Edit Profile Button
          OutlinedButton.icon(
            onPressed: () {
              // Handle Edit Profile logic
            },
            icon: const Icon(Icons.edit_rounded, size: 18),
            label: const Text('Edit Profile'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.primary, width: 1.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard(WorkoutProvider workoutProvider) {
    if (workoutProvider.isLoading) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.navy,
            AppColors.accentBlue,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.navy.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'Your Progress',
            style: TextStyle(
              fontFamily: "Poppins",
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _PointsStatItem(
                  icon: Icons.star,
                  label: 'Total Points',
                  value: workoutProvider.totalPoints.toString(),
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _PointsStatItem(
                  icon: Icons.local_fire_department,
                  label: 'Streak',
                  value: '${workoutProvider.streakDays} days',
                  color: Colors.orange.shade400,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.info_outline, size: 16, color: Colors.white70),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    'Complete workouts daily to earn points!',
                    style: const TextStyle(
                      fontFamily: "Poppins",
                      fontSize: 12,
                      color: Colors.white70,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkoutStatsCard(WorkoutProvider workoutProvider) {
    if (workoutProvider.isLoading) {
      return Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: const Padding(
          padding: EdgeInsets.all(16.0),
          child: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    final totalWorkouts = workoutProvider.totalWorkouts;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _StatItem(
              value: totalWorkouts.toString(),
              label: 'Workouts',
              color: AppColors.primary,
            ),
            _StatItem(
              value: '${(totalWorkouts * 150).toString()}',
              label: 'kCal Burned',
              color: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionList() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          _ActionTile(
            icon: Icons.lock_rounded,
            title: 'Privacy & Security',
            onTap: () {},
          ),
          _ActionTile(
            icon: Icons.notifications_rounded,
            title: 'Notifications',
            onTap: () {},
          ),
          _ActionTile(
            icon: Icons.favorite_rounded,
            title: 'Favorite Workouts',
            onTap: () {},
          ),
          _ActionTile(
            icon: Icons.help_outline_rounded,
            title: 'Help Center',
            onTap: () {},
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return TextButton.icon(
      onPressed: () async {
        await FirebaseAuth.instance.signOut();
        if (context.mounted) {
          Navigator.pushNamedAndRemoveUntil(
              context, '/login', (route) => false);
        }
      },
      icon: const Icon(Icons.logout_rounded, color: Colors.red),
      label: const Text(
        'Log Out',
        style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600),
      ),
      style: TextButton.styleFrom(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      ),
    );
  }
}

// --- Helper Widgets ---

class _PointsStatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _PointsStatItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 28,
              color: color,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontFamily: "Poppins",
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontFamily: "Poppins",
              fontSize: 12,
              color: Colors.black54,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;
  final Color color;

  const _StatItem({
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textDark,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool isLast;

  const _ActionTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          leading: Icon(icon, color: AppColors.primary),
          title: Text(
            title,
            style: const TextStyle(
                color: AppColors.textDark, fontWeight: FontWeight.w500),
          ),
          trailing: const Icon(Icons.arrow_forward_ios_rounded,
              size: 16, color: AppColors.textDark),
          onTap: onTap,
        ),
        if (!isLast)
          Divider(
            height: 1,
            indent: 72,
            endIndent: 16,
            color: Colors.grey.shade200,
          ),
      ],
    );
  }
}