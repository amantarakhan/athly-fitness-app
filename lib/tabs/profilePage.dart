import 'package:flutter/material.dart';
import 'package:athlynew/colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:athlynew/services/workout_plan_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> with AutomaticKeepAliveClientMixin {
  int _totalWorkouts = 0;
  bool _isLoadingWorkouts = true;
  
  // Key to force ProfileStatsCard to rebuild
  Key _statsCardKey = UniqueKey();

  @override
  bool get wantKeepAlive => false; // Don't keep state alive, allow refresh

  @override
  void initState() {
    super.initState();
    _loadWorkoutStats();
  }

  // This ensures data refreshes when tab is visible
  @override
  void didUpdateWidget(ProfilePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    _refreshData();
  }

  void _refreshData() {
    setState(() {
      _statsCardKey = UniqueKey(); // Force ProfileStatsCard to rebuild
    });
    _loadWorkoutStats();
  }

  Future<void> _loadWorkoutStats() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (mounted) {
        setState(() {
          _isLoadingWorkouts = false;
        });
      }
      return;
    }

    try {
      final workoutsSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('workouts')
          .where('completed', isEqualTo: true)
          .get();

      if (mounted) {
        setState(() {
          _totalWorkouts = workoutsSnapshot.docs.length;
          _isLoadingWorkouts = false;
        });
      }
    } catch (e) {
      print('❌ Error loading workout stats: $e');
      if (mounted) {
        setState(() {
          _isLoadingWorkouts = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
        actions: [
          // Add refresh button
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
        onRefresh: () async {
          _refreshData();
          // Wait a bit for the data to load
          await Future.delayed(const Duration(milliseconds: 500));
        },
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          children: <Widget>[
            // 1. User Profile Header
            _buildProfileHeader(context),
            const SizedBox(height: 24),

            // 2. Points & Streak Card with unique key to force rebuild
            ProfileStatsCard(key: _statsCardKey),
            const SizedBox(height: 24),

            // 3. Original Stats/Metrics Section
            _buildStatsCard(),
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

  Widget _buildProfileHeader(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser!;
    final uid = user.uid;

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('users').doc(uid).snapshots(),
      builder: (context, snapshot) {
        final data = snapshot.data?.data() as Map<String, dynamic>?;

        final name = (data?['name'] ?? user.displayName ?? 'User') as String;
        final email = (data?['email'] ?? user.email ?? '') as String;

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

              // User Name (dynamic)
              Text(
                name,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),

              // User Email (dynamic)
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
      },
    );
  }

  Widget _buildStatsCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _isLoadingWorkouts
            ? const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _StatItem(
                    value: _totalWorkouts.toString(),
                    label: 'Workouts',
                    color: AppColors.primary,
                  ),
                  _StatItem(
                    value: '${(_totalWorkouts * 150).toString()}',
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
        // After sign out → go to login screen
        if (context.mounted) {
          Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
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

// --- Points & Streak Card Widget ---

class ProfileStatsCard extends StatefulWidget {
  const ProfileStatsCard({super.key});

  @override
  State<ProfileStatsCard> createState() => _ProfileStatsCardState();
}

class _ProfileStatsCardState extends State<ProfileStatsCard> {
  int _totalPoints = 0;
  int _streak = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    if (!mounted) return;
    
    setState(() => _isLoading = true);
    
    try {
      print('🔄 ProfileStatsCard: Loading stats...');
      
      final results = await Future.wait([
        WorkoutPlanService.getTotalPoints(),
        WorkoutPlanService.getCurrentStreak(),
      ]).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          print('⚠️ ProfileStatsCard: Timeout loading stats');
          return [0, 0];
        },
      );

      if (mounted) {
        final points = results[0] as int;
        final streak = results[1] as int;
        
        print('✅ ProfileStatsCard: Loaded - Points: $points, Streak: $streak');
        
        setState(() {
          _totalPoints = points;
          _streak = streak;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('❌ ProfileStatsCard Error loading stats: $e');
      if (mounted) {
        setState(() {
          _totalPoints = 0;
          _streak = 0;
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
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
                  value: _totalPoints.toString(),
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _PointsStatItem(
                  icon: Icons.local_fire_department,
                  label: 'Streak',
                  value: '$_streak days',
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
}

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

// --- Original Helper Widgets ---

class _StatItem extends StatelessWidget {
  final String value;
  final String label;
  final Color color;

  const _StatItem({required this.value, required this.label, required this.color});

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
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          leading: Icon(icon, color: AppColors.primary),
          title: Text(
            title,
            style: const TextStyle(color: AppColors.textDark, fontWeight: FontWeight.w500),
          ),
          trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: AppColors.textDark),
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