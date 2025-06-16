import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/diet_controller.dart';

class StatsCard extends StatelessWidget {
  final DietController controller = Get.find<DietController>();

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: 'stats_card',
      child: Material(
        color: Colors.transparent,
        child: FadeTransition(
          opacity: controller.slowFadeAnimation,
          child: ScaleTransition(
            scale: controller.scaleAnimation,
            child: Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFFFE0B2), Color(0xFFFFCC80)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.orange.withOpacity(0.1),
                    spreadRadius: 0.5,
                    blurRadius: 2,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(Icons.local_fire_department,
                            color: Color(0xFFFF6F00), size: 20),
                      ),
                      SizedBox(width: 10),
                      Text(
                        'Daily Calories',
                        style: TextStyle(
                          color: Color(0xFFFF6F00),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Obx(() => FadeTransition(
                    opacity: controller.ultraSlowFadeAnimation,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AnimatedSwitcher(
                          duration: Duration(milliseconds: 1000),
                          child: Text(
                            '${controller.dailyCalories.value}',
                            key: ValueKey(controller.dailyCalories.value),
                            style: TextStyle(
                              color: Color(0xFFFF6F00),
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'of ${controller.targetCalories.value} target',
                          style: TextStyle(
                            color: Color(0xFFFF8A65),
                            fontSize: 12,
                          ),
                        ),
                        SizedBox(height: 12),
                        Container(
                          height: 6,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.4),
                            borderRadius: BorderRadius.circular(3),
                          ),
                          child: FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: (controller.dailyCalories.value /
                                controller.targetCalories.value).clamp(0.0, 1.0),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Color(0xFFFF6F00),
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}