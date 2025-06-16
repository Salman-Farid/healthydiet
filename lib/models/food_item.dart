class FoodItem {
  final String name;
  final String category;
  final int calories;
  final String imageUrl;
  final String heroTag;
  final List<String> nutrients;
  final String description;

  FoodItem({
    required this.name,
    required this.category,
    required this.calories,
    required this.imageUrl,
    required this.heroTag,
    required this.nutrients,
    required this.description,
  });
}

class MealPlan {
  final String mealType;
  final List<FoodItem> foods;
  final int totalCalories;

  MealPlan({
    required this.mealType,
    required this.foods,
    required this.totalCalories,
  });
}