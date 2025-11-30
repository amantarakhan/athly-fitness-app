import 'package:flutter/material.dart';
import '../colors.dart';
import '../AppShell.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});


 
  void handleLogOut(BuildContext context) {

    Navigator.pushNamedAndRemoveUntil(context, '/welcome', (route) => false);

 
  
}


  @override
  Widget build(BuildContext context) {
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
          IconButton(
            icon: const Icon(Icons.settings_rounded, color: AppColors.textDark),
            onPressed: () {
              // Handle Settings navigation
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        children: <Widget>[
          // 1. User Profile Header
          _buildProfileHeader(context),
          const SizedBox(height: 24),

          // 2. Stats/Metrics Section
          _buildStatsCard(),
          const SizedBox(height: 32),

          // 3. Action List (Settings/General)
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

          // 4. Logout Button
          _buildLogoutButton(context),
        ],
      ),
    );
  }

  // --- Widget Builders ---

  Widget _buildProfileHeader(BuildContext context) {
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
          // User Name
          const Text(
            'Jane Doe',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          // User Handle/Email
          const Text(
            'janedoe@fitnessapp.com',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textDark,
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

  Widget _buildStatsCard() {
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
            _StatItem(value: '42', label: 'Workouts', color: AppColors.primary),
            _StatItem(value: '38', label: 'Days Streak', color: AppColors.primary),
            _StatItem(value: '1.2k', label: 'kCal Burned', color: AppColors.primary),
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

  

  


Widget _buildLogoutButton(context) {
    return TextButton.icon(
       onPressed: () => handleLogOut(context),// <--- This line calls the function passed from AppShell
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
  } }

// --- Helper Widgets ---

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
            indent: 72, // Aligns with the title text
            endIndent: 16,
            color: Colors.grey.shade200,
          ),
      ],
    );
  }
}

// --- Wrapper for quick testing ---
// Uncomment this main function to test the page in isolation.
/*
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fitness Profile',
      theme: ThemeData(
        primaryColor: kPrimaryColor,
        fontFamily: 'Roboto', // Replace with your actual font if needed
        useMaterial3: true,
      ),
      home: const ProfilePage(),
    );
  }
}
*/