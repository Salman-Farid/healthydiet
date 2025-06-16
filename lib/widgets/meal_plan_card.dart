import 'package:flutter/material.dart';
import '../models/food_item.dart';

class MealPlanCard extends StatelessWidget {
  final MealPlan mealPlan;
  final bool detailed;

  const MealPlanCard({
    Key? key,
    required this.mealPlan,
    this.detailed = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            spreadRadius: 0.5,
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    _getMealColor().withOpacity(0.08),
                    _getMealColor().withOpacity(0.04),
                  ],
                ),
              ),
              child: Row(
                children: [
                  Hero(
                    tag: '${mealPlan.mealType}_icon',
                    child: Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [_getMealColor().withOpacity(0.2), _getMealColor().withOpacity(0.15)],
                        ),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: _getMealColor().withOpacity(0.1),
                            spreadRadius: 0.5,
                            blurRadius: 2,
                            offset: Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Icon(
                        _getMealIcon(),
                        color: _getMealColor(),
                        size: 22,
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          mealPlan.mealType,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF424242),
                          ),
                        ),
                        SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.local_fire_department,
                                color: Color(0xFFFF8A65), size: 14),
                            SizedBox(width: 4),
                            Text(
                              '${mealPlan.totalCalories} calories',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (detailed) ...[
              Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: mealPlan.foods.asMap().entries.map((entry) {
                    int index = entry.key;
                    FoodItem food = entry.value;
                    return Container(
                      margin: EdgeInsets.only(bottom: index < mealPlan.foods.length - 1 ? 12 : 0),
                      padding: EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[200]!, width: 0.5),
                      ),
                      child: Row(
                        children: [
                          Hero(
                            tag: food.heroTag,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.network(
                                food.imageUrl,
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                                loadingBuilder: (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Container(
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[300],
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Center(
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation(_getMealColor()),
                                      ),
                                    ),
                                  );
                                },
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      color: _getMealColor().withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Icon(
                                      Icons.restaurant,
                                      color: _getMealColor(),
                                      size: 24,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  food.name,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF424242),
                                    fontSize: 14,
                                  ),
                                ),
                                SizedBox(height: 3),
                                Text(
                                  '${food.calories} cal • ${food.nutrients.take(2).join(', ')}',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getMealColor() {
    switch (mealPlan.mealType.toLowerCase()) {
      case 'breakfast':
        return Color(0xFFFFB74D);
      case 'lunch':
        return Color(0xFF81C784);
      case 'dinner':
        return Color(0xFFBA68C8);
      default:
        return Color(0xFF64B5F6);
    }
  }

  IconData _getMealIcon() {
    switch (mealPlan.mealType.toLowerCase()) {
      case 'breakfast':
        return Icons.wb_sunny;
      case 'lunch':
        return Icons.wb_cloudy;
      case 'dinner':
        return Icons.nights_stay;
      default:
        return Icons.restaurant;
    }
  }
}