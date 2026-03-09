
import 'package:flutter/material.dart';

class WorkoutCategory { // a class that define workouts catagories 
  final String id;
  final String name;
  final IconData icon;
  final List<Workout> workouts;

  const WorkoutCategory({ // constructor 
    required this.id,
    required this.name,
    required this.icon,
    required this.workouts,
  });
}

class Workout { // a class that define workouts attributes 
// each workout objects mush have there attriblutes 
  final String id;
  final String name;
  final String level;      // e.g. Beginner / Intermediate
  final String duration;   // e.g. "10 min"
  final String youtubeUrl;
  final String description;

  const Workout({ // constructor  
    required this.id,
    required this.name,
    required this.level,
    required this.duration,
    required this.youtubeUrl,
    required this.description,
  });
}
