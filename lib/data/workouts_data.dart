// lib/data/workouts_data.dart
import 'package:flutter/material.dart';
import 'package:athlynew/models/workout.dart';

final List<WorkoutCategory> workoutCategories = [
  // ---------- UPPER BODY ----------
  WorkoutCategory(
    id: 'upper',
    name: 'Upper Body',
    icon: Icons.fitness_center_rounded,
    workouts: const [
      Workout(
        id: 'ub_pushups_intro',
        name: 'Upper Body Strength for Push-Ups',
        level: 'Beginner',
        duration: '12 min',
        youtubeUrl:
            'https://www.fitnessblender.com/videos/upper-body-workout-to-build-strength-for-push-ups-tips-on-how-to-do-more-push-ups',
        description:
            'Short upper body routine that builds strength for better push-ups.',
      ),
      Workout(
        id: 'ub_at_home_strength',
        name: 'At Home Upper Body Strength Workout',
        level: 'Intermediate',
        duration: '25 min',
        youtubeUrl: 'https://www.youtube.com/watch?v=Yxjxec_EhGQ',
        description:
            'Dumbbell workout hitting chest, shoulders, back, and arms.',
      ),
      Workout(
        id: 'ub_no_equipment',
        name: 'No Equipment Upper Body & Abs',
        level: 'All levels',
        duration: '20 min',
        youtubeUrl: 'https://www.youtube.com/watch?v=cpvqSFuo2sw',
        description:
            'Bodyweight-only upper body and abs circuit.',
      ),
      Workout(
        id: 'ub_bored_easily',
        name: 'Bored Easily Upper Body',
        level: 'Intermediate',
        duration: '30 min',
        youtubeUrl: 'https://www.youtube.com/watch?v=IoSucrcM_GU',
        description:
            'Upper body workout with lots of variety to keep it fun.',
      ),
      Workout(
        id: 'ub_quick_strength',
        name: 'Quick Upper Body Strength (Light Weights)',
        level: 'Beginner',
        duration: '10 min',
        youtubeUrl: 'https://www.youtube.com/watch?v=W4ci-v9malU',
        description:
            'Fast upper body session using light weights.',
      ),
      Workout(
        id: 'ub_push_chest_shoulders_triceps',
        name: 'Upper Body Strength Push',
        level: 'Intermediate',
        duration: '32 min',
        youtubeUrl:
            'https://www.fitnessblender.com/videos/upper-body-strength-push-chest-shoulders-triceps-build-muscle-and-endurance',
        description:
            'Push-focused chest, shoulders, and triceps workout.',
      ),
      Workout(
        id: 'ub_pull_back_biceps',
        name: 'Upper Body Pull (Back & Biceps)',
        level: 'Intermediate',
        duration: '28 min',
        youtubeUrl: 'https://www.youtube.com/watch?v=Z_2d7QjZtX8',
        description:
            'Pull-focused routine targeting back and biceps.',
      ),
      Workout(
        id: 'ub_strength_burnout',
        name: 'Upper Body Strength Burnout',
        level: 'Advanced',
        duration: '35 min',
        youtubeUrl: 'https://www.youtube.com/watch?v=R9pZC9zF9aI',
        description:
            'Challenging upper body workout ending with an intense burnout.',
      ),
    ],
  ),

  // ---------- LOWER BODY ----------
  WorkoutCategory(
    id: 'lower',
    name: 'Lower Body',
    icon: Icons.directions_run_rounded,
    workouts: const [
      Workout(
        id: 'lb_glute_activation',
        name: 'Lower Body Strength + Glute Activation',
        level: 'Beginner',
        duration: '24 min',
        youtubeUrl: 'https://www.youtube.com/watch?v=BWdu2bFevjQ',
        description:
            'Warm-up, glute activation, and strength sets.',
      ),
      Workout(
        id: 'lb_sweaty_strength',
        name: 'Sweaty Lower Body Strength Workout',
        level: 'Intermediate',
        duration: '32 min',
        youtubeUrl: 'https://www.youtube.com/watch?v=vg16oq6H0LU',
        description:
            'Strength training with cardio intervals.',
      ),
      Workout(
        id: 'lb_dumbbell_legs',
        name: 'Lower Body Dumbbell Strength',
        level: 'Intermediate',
        duration: '28 min',
        youtubeUrl: 'https://www.youtube.com/watch?v=8Xz2Thr60DE',
        description:
            'Leg workout featuring squats, lunges, and power moves.',
      ),
      Workout(
        id: 'lb_butt_thigh_glute',
        name: 'Butt & Thigh Workout with Glute Focus',
        level: 'All levels',
        duration: '40 min',
        youtubeUrl: 'https://www.youtube.com/watch?v=lhJkJqNRXI8',
        description:
            'Extended lower body session focusing on glutes.',
      ),
      Workout(
        id: 'lb_fat_burning',
        name: 'Fat Burning Butt & Thigh Strength',
        level: 'Intermediate',
        duration: '35 min',
        youtubeUrl: 'https://www.youtube.com/watch?v=NljaynACdxA',
        description:
            'Strength workout that also burns calories.',
      ),
      Workout(
        id: 'lb_power_circuits',
        name: 'Lower Body Strength & Power Circuits',
        level: 'Intermediate',
        duration: '30 min',
        youtubeUrl: 'https://www.youtube.com/watch?v=SSwa0zpBId4',
        description:
            'Strength and power circuits for legs.',
      ),
      Workout(
        id: 'lb_no_equipment',
        name: 'No Equipment Lower Body',
        level: 'Beginner',
        duration: '20 min',
        youtubeUrl: 'https://www.youtube.com/watch?v=V6xgY8GzZ4U',
        description:
            'Bodyweight-only lower body workout.',
      ),
      Workout(
        id: 'lb_leg_burner',
        name: 'Leg Day Burner',
        level: 'Advanced',
        duration: '45 min',
        youtubeUrl: 'https://www.youtube.com/watch?v=0z5u6fC5yT8',
        description:
            'Intense leg day workout for strength and endurance.',
      ),
    ],
  ),

  // ---------- CORE ----------
  WorkoutCategory(
    id: 'core',
    name: 'Core',
    icon: Icons.self_improvement_rounded,
    workouts: const [
      Workout(
        id: 'core_15_min_abs',
        name: '15 Minute Abs Workout',
        level: 'All levels',
        duration: '15 min',
        youtubeUrl: 'https://www.youtube.com/watch?v=0yZDVWab_dI',
        description:
            'Floor-based abs routine with no equipment.',
      ),
      Workout(
        id: 'core_bodyweight_strength',
        name: 'Bodyweight Core Strength Workout',
        level: 'Intermediate',
        duration: '30 min',
        youtubeUrl: 'https://www.youtube.com/watch?v=yaiGFYw_1rw',
        description:
            'Steady-paced core strength workout.',
      ),
      Workout(
        id: 'core_10_min_abs_obliques',
        name: '10 Minute Abs & Obliques',
        level: 'Beginner',
        duration: '10 min',
        youtubeUrl: 'https://www.youtube.com/watch?v=RpfNMbM7jIc',
        description:
            'Quick abs and obliques finisher.',
      ),
      Workout(
        id: 'core_short_sweet_burner',
        name: 'Short & Sweet Core Burner',
        level: 'Intermediate',
        duration: '18 min',
        youtubeUrl: 'https://www.youtube.com/watch?v=tFPV0iBffXk',
        description:
            'Fast-paced core workout with variety.',
      ),
      Workout(
        id: 'core_no_equipment_beginners',
        name: 'No Equipment Core Workout (Beginners)',
        level: 'Beginner',
        duration: '20 min',
        youtubeUrl: 'https://www.youtube.com/watch?v=JW8WbfLJdtk',
        description:
            'Gentle beginner-friendly core routine.',
      ),
      Workout(
        id: 'core_plank_focus',
        name: 'Plank Focus Core Workout',
        level: 'Intermediate',
        duration: '22 min',
        youtubeUrl: 'https://www.youtube.com/watch?v=pSHjTRCQxIw',
        description:
            'Core workout emphasizing planks and stability.',
      ),
      Workout(
        id: 'core_stability_strength',
        name: 'Core Stability & Strength',
        level: 'Intermediate',
        duration: '25 min',
        youtubeUrl: 'https://www.youtube.com/watch?v=Q8e7TgUeDgU',
        description:
            'Improve balance and core control.',
      ),
      Workout(
        id: 'core_advanced_burn',
        name: 'Advanced Core Burn',
        level: 'Advanced',
        duration: '35 min',
        youtubeUrl: 'https://www.youtube.com/watch?v=2pLT-olgUJs',
        description:
            'High-intensity core workout for experienced athletes.',
      ),
    ],
  ),
];
