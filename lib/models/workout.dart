
import 'package:flutter/material.dart';

class WorkoutCategory {
  final String id;
  final String name;
  final IconData icon;
  final List<Workout> workouts;

  const WorkoutCategory({
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

  const Workout({
    required this.id,
    required this.name,
    required this.level,
    required this.duration,
    required this.youtubeUrl,
    required this.description,
  });
}
