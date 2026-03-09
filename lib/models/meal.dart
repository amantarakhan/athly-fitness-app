
// define data structure 
class Meal { // a meal class 
  final String id;
  final String name;
  final String type;        // "Breakfast" / "Lunch" / "Dinner"
  final int calories;
  final int proteinGrams;
  final int prepMinutes;

  /// Short 1–2 sentence description for cards.
  final String overview;

  /// Ingredients shown as a bullet list on the recipe screen.
  final List<String> ingredients;

  /// Step-by-step instructions for the recipe screen.
  final List<String> steps;

  /// URL to meal image (or emoji as fallback)
  final String imageUrl;

  /// Emoji representation for quick fallback
  final String emoji;

  const Meal({ // a constructor 
    required this.id,
    required this.name,
    required this.type,
    required this.calories,
    required this.proteinGrams,
    required this.prepMinutes,

    // 👇 these are optional 
    this.overview = '',
    this.ingredients = const [],
    this.steps = const [],
    this.imageUrl = '',
    this.emoji = '🍽️', // default food emoji
  });
}

//Groups all meals for a specific day 
class DailyMealPlan {
  final DateTime date;
  final Meal breakfast;
  final Meal lunch;
  final Meal dinner;

  const DailyMealPlan({ // a constructor 
    required this.date,
    required this.breakfast,
    required this.lunch,
    required this.dinner,
  });
}