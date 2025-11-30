import 'package:flutter/material.dart';
import 'package:athlynew/colors.dart'; // your existing colors file
import 'package:url_launcher/url_launcher_string.dart'; // we'll use this for YouTube

// ---------- DATA MODELS ----------

class WorkoutCategory {
  final String id;
  final String name;
  final IconData icon;
  final List<Workout> workouts;

  WorkoutCategory({
    required this.id,
    required this.name,
    required this.icon,
    required this.workouts,
  });
}

class Workout {
  final String id;
  final String name;
  final String level;      // e.g. Beginner / Intermediate
  final String duration;   // e.g. "10 min"
  final String youtubeUrl;
  final String description;

  Workout({
    required this.id,
    required this.name,
    required this.level,
    required this.duration,
    required this.youtubeUrl,
    required this.description,
  });
}

// Sample dummy data (you can edit these later)
final List<WorkoutCategory> _categories = [
  WorkoutCategory(
    id: 'upper',
    name: 'Upper Body',
    icon: Icons.fitness_center_rounded,
    workouts: [
      Workout(
        id: 'pushups',
        name: 'Push-Ups',
        level: 'Beginner',
        duration: '10 min',
        youtubeUrl: 'https://www.youtube.com/watch?v=IODxDxX7oi4',
        description:
            'A classic bodyweight exercise that targets chest, shoulders, and triceps. '
            'Keep your core tight and back straight throughout the movement.',
      ),
      Workout(
        id: 'dumbbell_press',
        name: 'Dumbbell Chest Press',
        level: 'Intermediate',
        duration: '12 min',
        youtubeUrl: 'https://www.youtube.com/watch?v=VmB1G1K7v94',
        description:
            'Targets your chest and triceps. Press the dumbbells up while keeping your feet planted '
            'and lower slowly with control.',
      ),
    ],
  ),
  WorkoutCategory(
    id: 'lower',
    name: 'Lower Body',
    icon: Icons.directions_run_rounded,
    workouts: [
      Workout(
        id: 'squats',
        name: 'Bodyweight Squats',
        level: 'Beginner',
        duration: '8 min',
        youtubeUrl: 'https://www.youtube.com/watch?v=aclHkVaku9U',
        description:
            'Squats strengthen your quads, glutes, and hamstrings. Keep your chest up and knees '
            'tracking over your toes.',
      ),
      Workout(
        id: 'lunges',
        name: 'Walking Lunges',
        level: 'Intermediate',
        duration: '10 min',
        youtubeUrl: 'https://www.youtube.com/watch?v=QOVaHwm-Q6U',
        description:
            'Lunges work your legs and improve balance. Step forward, drop your back knee, then push '
            'through the front heel to stand.',
      ),
    ],
  ),
  WorkoutCategory(
    id: 'core',
    name: 'Core',
    icon: Icons.self_improvement_rounded,
    workouts: [
      Workout(
        id: 'plank',
        name: 'Plank Hold',
        level: 'All levels',
        duration: '5 min',
        youtubeUrl: 'https://www.youtube.com/watch?v=pSHjTRCQxIw',
        description:
            'Static core exercise that trains your entire midsection. Keep your body in a straight line '
            'from head to heels.',
      ),
    ],
  ),
];

// ---------- WORKOUTS SCREEN ----------

class WorkoutsScreen extends StatelessWidget {
  const WorkoutsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.background,
        centerTitle: true,
        title: Text(
          'Workouts',
          style: textTheme.titleLarge?.copyWith(
            color: AppColors.textDark,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        itemCount: _categories.length,
        separatorBuilder: (_, __) => const SizedBox(height: 24),
        itemBuilder: (context, index) {
          final cat = _categories[index];
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
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(category.icon, color: AppColors.accentBlue, size: 22),
            const SizedBox(width: 8),
            Text(
              category.name,
              style: textTheme.titleMedium?.copyWith(
                color: AppColors.textDark,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 150,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: category.workouts.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final workout = category.workouts[index];
              return _WorkoutCard(workout: workout);
            },
          ),
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
    final textTheme = Theme.of(context).textTheme;

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => WorkoutDetailScreen(workout: workout),
          ),
        );
      },
      child: Container(
        width: 200,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              blurRadius: 10,
              offset: const Offset(0, 6),
              color: Colors.black.withOpacity(0.04),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Little "tag" row
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.accentBlue.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    workout.level,
                    style: textTheme.labelSmall?.copyWith(
                      color: AppColors.accentBlue,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const Spacer(),
                Row(
                  children: [
                    const Icon(Icons.timer_outlined, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      workout.duration,
                      style: textTheme.labelSmall?.copyWith(
                        color: AppColors.textDark,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const Spacer(),
            Text(
              workout.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: textTheme.titleSmall?.copyWith(
                color: AppColors.textDark,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Tap to view tutorial',
              style: textTheme.labelSmall?.copyWith(
                color: AppColors.textDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------- WORKOUT DETAIL SCREEN ----------

class WorkoutDetailScreen extends StatelessWidget {
  final Workout workout;

  const WorkoutDetailScreen({super.key, required this.workout});

  Future<void> _openYoutube() async {
    if (await canLaunchUrlString(workout.youtubeUrl)) {
      await launchUrlString(workout.youtubeUrl,
          mode: LaunchMode.externalApplication);
    }
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
          workout.name,
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
            // Fake video thumbnail area
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
                  label: Text('Level: ${workout.level}'),
                  backgroundColor: AppColors.primary,
                ),
                const SizedBox(width: 8),
                Chip(
                  label: Text('Duration: ${workout.duration}'),
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
              workout.description,
              style: textTheme.bodyMedium?.copyWith(
                color: AppColors.textDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
