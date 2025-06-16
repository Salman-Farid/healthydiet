import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/diet_controller.dart';

class WaterTracker extends StatelessWidget {
  final DietController controller = Get.find<DietController>();

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: 'water_tracker',
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
                  colors: [Color(0xFFE3F2FD), Color(0xFFBBDEFB)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.1),
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
                        child: Icon(Icons.water_drop, color: Color(0xFF1976D2), size: 20),
                      ),
                      SizedBox(width: 10),
                      Text(
                        'Water Intake',
                        style: TextStyle(
                          color: Color(0xFF1976D2),
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
                          duration: Duration(milliseconds: 800),
                          child: Text(
                            '${controller.waterIntake.value}',
                            key: ValueKey(controller.waterIntake.value),
                            style: TextStyle(
                              color: Color(0xFF1976D2),
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'of ${controller.targetWater.value} glasses',
                          style: TextStyle(
                            color: Color(0xFF42A5F5),
                            fontSize: 12,
                          ),
                        ),
                        SizedBox(height: 12),
                        Row(
                          children: [
                            GestureDetector(
                              onTap: controller.removeWater, // Instant response
                              child: Container(
                                padding: EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.4),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(Icons.remove, color: Color(0xFF1976D2), size: 14),
                              ),
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: Container(
                                height: 6,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.4),
                                  borderRadius: BorderRadius.circular(3),
                                ),
                                child: FractionallySizedBox(
                                  alignment: Alignment.centerLeft,
                                  widthFactor: (controller.waterIntake.value /
                                      controller.targetWater.value).clamp(0.0, 1.0),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Color(0xFF1976D2),
                                      borderRadius: BorderRadius.circular(3),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 10),
                            GestureDetector(
                              onTap: controller.addWater, // Instant response
                              child: Container(
                                padding: EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.4),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(Icons.add, color: Color(0xFF1976D2), size: 14),
                              ),
                            ),
                          ],
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