// lib/workouts.dart
import 'package:flutter/material.dart';
import 'package:athlynew/colors.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:athlynew/models/workout.dart';
import 'package:athlynew/data/workouts_data.dart';
import 'package:athlynew/services/workout_plan_service.dart';

// ---------- WORKOUTS SCREEN ----------

class WorkoutsScreen extends StatelessWidget {
  const WorkoutsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.navy,
        centerTitle: true,
        title: const Text(
          'Workouts',
          style: TextStyle(
            fontFamily: "Poppins",
            fontWeight: FontWeight.bold,
            fontSize: 25,
            color: Colors.white,
          ),
        ),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, kBottomNavigationBarHeight + 24),
        itemCount: workoutCategories.length,
        separatorBuilder: (_, __) => const SizedBox(height: 32),
        itemBuilder: (context, index) {
          final cat = workoutCategories[index];
          return _WorkoutCategorySection(category: cat);
        },
      ),
    );
  }
}

// ---------- CATEGORY SECTION (title + horizontal cards) ----------

class _WorkoutCategorySection extends StatelessWidget {
  final WorkoutCategory category;

  const _WorkoutCategorySection({required this.category});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Category Header
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.navy.withOpacity(0.1),
                AppColors.secondary.withOpacity(0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(category.icon, color: AppColors.navy, size: 24),
              ),
              const SizedBox(width: 12),
              Text(
                category.name,
                style: const TextStyle(
                  fontFamily: "Poppins",
                  fontSize: 20,
                  color: Colors.black87,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Grid of workouts
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.75,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: category.workouts.length,
          itemBuilder: (context, index) {
            final workout = category.workouts[index];
            return _WorkoutCard(workout: workout);
          },
        ),
      ],
    );
  }
}

// ---------- SINGLE WORKOUT CARD ----------

class _WorkoutCard extends StatelessWidget {
  final Workout workout;

  const _WorkoutCard({required this.workout});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => WorkoutDetailScreen(
              workout: workout,
              isFromTodayPlan: false,
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              AppColors.background,
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.black.withOpacity(0.05), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.08),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Level badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                gradient: _getLevelGradient(workout.level),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: _getLevelColor(workout.level).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Text(
                workout.level,
                style: const TextStyle(
                  fontFamily: "Poppins",
                  fontSize: 11,
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            const Spacer(),
            // Workout name
            Text(
              workout.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: "Poppins",
                fontSize: 15,
                color: Colors.black87,
                fontWeight: FontWeight.w700,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            // Duration
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.navy.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.timer_outlined,
                    size: 16,
                    color: AppColors.navy,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  workout.duration,
                  style: const TextStyle(
                    fontFamily: "Poppins",
                    fontSize: 13,
                    color: Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Tap to view text
            Text(
              'Tap to view tutorial',
              style: TextStyle(
                fontFamily: "Poppins",
                fontSize: 11,
                color: Colors.black.withOpacity(0.5),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getLevelColor(String level) {
    switch (level.toLowerCase()) {
      case 'beginner':
        return Colors.green;
      case 'intermediate':
        return Colors.orange;
      case 'advanced':
        return Colors.red;
      default:
        return AppColors.primary;
    }
  }

  LinearGradient _getLevelGradient(String level) {
    final color = _getLevelColor(level);
    return LinearGradient(
      colors: [color, color.withOpacity(0.8)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }
}

// ---------- WORKOUT DETAIL SCREEN ----------

class WorkoutDetailScreen extends StatefulWidget {
  final Workout workout;
  final bool isFromTodayPlan;

  const WorkoutDetailScreen({
    super.key,
    required this.workout,
    this.isFromTodayPlan = false,
  });

  @override
  State<WorkoutDetailScreen> createState() => _WorkoutDetailScreenState();
}

class _WorkoutDetailScreenState extends State<WorkoutDetailScreen> {
  bool _isCompleting = false;
  bool _isCompleted = false;

  @override
  void initState() {
    super.initState();
    if (widget.isFromTodayPlan) {
      _checkIfCompleted();
    }
  }

  Future<void> _checkIfCompleted() async {
    final completed = await WorkoutPlanService.isTodayWorkoutCompleted();
    if (mounted) {
      setState(() {
        _isCompleted = completed;
      });
    }
  }

  Future<void> _openYoutube() async {
    if (await canLaunchUrlString(widget.workout.youtubeUrl)) {
      await launchUrlString(widget.workout.youtubeUrl,
          mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _completeWorkout() async {
    if (_isCompleting || _isCompleted) return;

    setState(() {
      _isCompleting = true;
    });

    try {
      await WorkoutPlanService.completeWorkout(widget.workout.level);
      
      if (mounted) {
        setState(() {
          _isCompleted = true;
          _isCompleting = false;
        });

        // Calculate points earned
        int points = 0;
        switch (widget.workout.level) {
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

        // Show success dialog
        _showSuccessDialog(points);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isCompleting = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error completing workout: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showSuccessDialog(int points) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Success Icon
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check_circle,
                    size: 60,
                    color: Colors.green.shade600,
                  ),
                ),
                const SizedBox(height: 20),
                
                // Congratulations Text
                const Text(
                  'Workout Complete!',
                  style: TextStyle(
                    fontFamily: "Poppins",
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                
                // Points Earned
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star, size: 20, color: Colors.black87),
                      const SizedBox(width: 8),
                      Text(
                        '+$points points earned!',
                        style: const TextStyle(
                          fontFamily: "Poppins",
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                
                // Message
                const Text(
                  'Great job! Your streak has been updated.',
                  style: TextStyle(
                    fontFamily: "Poppins",
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                
                // Go Home Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      // Close dialog and navigate back to home
                      Navigator.of(context).pop(); // Close dialog
                      Navigator.of(context).pop(); // Close workout detail
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.navy,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Go to Home',
                      style: TextStyle(
                        fontFamily: "Poppins",
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(
          widget.workout.name,
          style: textTheme.titleMedium?.copyWith(
            color: AppColors.textDark,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Video thumbnail area
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.accentBlue,
                      AppColors.navy,
                    ],
                  ),
                ),
                child: Center(
                  child: IconButton(
                    iconSize: 64,
                    icon: const Icon(
                      Icons.play_circle_fill_rounded,
                      color: Colors.white,
                    ),
                    onPressed: _openYoutube,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.center,
              child: TextButton.icon(
                onPressed: _openYoutube,
                icon: const Icon(Icons.ondemand_video_rounded),
                label: const Text('Open full tutorial on YouTube'),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Chip(
                  label: Text('Level: ${widget.workout.level}'),
                  backgroundColor: AppColors.primary,
                ),
                const SizedBox(width: 8),
                Chip(
                  label: Text('Duration: ${widget.workout.duration}'),
                  backgroundColor: AppColors.primary,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Overview',
              style: textTheme.titleMedium?.copyWith(
                color: AppColors.textDark,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.workout.description,
              style: textTheme.bodyMedium?.copyWith(
                color: AppColors.textDark,
              ),
            ),
            
            // Done Button (only show if from today's plan)
            if (widget.isFromTodayPlan) ...[
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isCompleted ? null : _completeWorkout,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isCompleted ? Colors.green.shade400 : AppColors.navy,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                    disabledBackgroundColor: Colors.green.shade400,
                    disabledForegroundColor: Colors.white,
                  ),
                  child: _isCompleting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _isCompleted ? Icons.check_circle : Icons.check_circle_outline,
                              size: 24,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _isCompleted ? 'Completed!' : 'Mark as Done',
                              style: const TextStyle(
                                fontFamily: "Poppins",
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 12),
              if (!_isCompleted)
                Text(
                  'Complete this workout to earn ${_getPoints(widget.workout.level)} points!',
                  style: const TextStyle(
                    fontFamily: "Poppins",
                    fontSize: 13,
                    color: Colors.black54,
                  ),
                  textAlign: TextAlign.center,
                ),
            ],
          ],
        ),
      ),
    );
  }

  int _getPoints(String level) {
    switch (level) {
      case 'Beginner':
        return 20;
      case 'Intermediate':
        return 60;
      case 'All levels':
        return 40;
      default:
        return 0;
    }
  }
}