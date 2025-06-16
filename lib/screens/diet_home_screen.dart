import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/diet_controller.dart';
import '../models/food_item.dart';
import '../widgets/stats_card.dart';
import '../widgets/meal_plan_card.dart';
import '../widgets/food_item_card.dart';
import '../widgets/water_tracker.dart';
import '../screens/food_detail_screen.dart';

class DietHomeScreen extends StatelessWidget {
  final DietController controller = Get.put(DietController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFAFAFA),
      body: SafeArea(
        child: Column(
          children: [
            _buildAnimatedHeader(),
            _buildAnimatedTabBar(),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return _buildLoadingScreen();
                }

                return _buildTabContent();
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FadeTransition(
            opacity: controller.slowFadeAnimation,
            child: Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFFFE0B2), Color(0xFFFFCC80)],
                ),
                borderRadius: BorderRadius.circular(35),
                boxShadow: [
                  BoxShadow(
                    color: Colors.orange.withOpacity(0.1),
                    spreadRadius: 0.5,
                    blurRadius: 2,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
              child: Icon(Icons.restaurant, color: Color(0xFFFF8A65), size: 35),
            ),
          ),
          SizedBox(height: 20),
          FadeTransition(
            opacity: controller.ultraSlowFadeAnimation,
            child: Text(
              'Preparing your healthy journey...',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedHeader() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 0.5,
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FadeTransition(
            opacity: controller.slowFadeAnimation,
            child: SlideTransition(
              position: controller.slideAnimation,
              child: Row(
                children: [
                  Hero(
                    tag: 'app_logo',
                    child: Container(
                      width: 45,
                      height: 45,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(22.5),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.orange.withOpacity(0.1),
                            spreadRadius: 0.5,
                            blurRadius: 2,
                            offset: Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Icon(Icons.eco, color: Color(0xFFFF8A65), size: 26),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hello, User! 👋',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFFFF8A65),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Healthy Diet Planner',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFFF6F00),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 8),
          FadeTransition(
            opacity: controller.ultraSlowFadeAnimation,
            child: Text(
              '2025-06-15 05:36:11 UTC • Track your nutrition journey',
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFFFF8A65).withOpacity(0.8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedTabBar() {
    return FadeTransition(
      opacity: controller.slowFadeAnimation,
      child: ScaleTransition(
        scale: controller.scaleAnimation,
        child: Container(
          margin: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.08),
                spreadRadius: 0.5,
                blurRadius: 2,
                offset: Offset(0, 1),
              ),
            ],
          ),
          child: Obx(() => Row(
            children: [
              _buildTabItem('Overview', 0, Icons.dashboard_outlined),
              _buildTabItem('Meals', 1, Icons.restaurant_outlined),
              _buildTabItem('Foods', 2, Icons.eco_outlined),
            ],
          )),
        ),
      ),
    );
  }

  Widget _buildTabItem(String title, int index, IconData icon) {
    bool isSelected = controller.selectedTab.value == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => controller.changeTab(index), // Instant response
        child: AnimatedContainer(
          duration: Duration(milliseconds: 150), // Fast visual feedback only
          curve: Curves.easeOut,
          padding: EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            gradient: isSelected ? LinearGradient(
              colors: [Color(0xFFFFE0B2), Color(0xFFFFCC80)],
            ) : null,
            borderRadius: BorderRadius.circular(25),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isSelected ? Color(0xFFFF6F00) : Color(0xFFFFCC80),
                size: 18,
              ),
              SizedBox(width: 6),
              Text(
                title,
                style: TextStyle(
                  color: isSelected ? Color(0xFFFF6F00) : Color(0xFFFFCC80),
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    // Content animations are slow motion, but tab switching is instant
    return FadeTransition(
      opacity: controller.slowFadeAnimation,
      child: SlideTransition(
        position: controller.slideAnimation,
        child: _getTabContent(),
      ),
    );
  }

  Widget _getTabContent() {
    switch (controller.selectedTab.value) {
      case 0:
        return _buildOverviewTab();
      case 1:
        return _buildMealsTab();
      case 2:
        return _buildFoodsTab();
      default:
        return _buildOverviewTab();
    }
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SlideTransition(
            position: controller.slideAnimation,
            child: Row(
              children: [
                Expanded(child: StatsCard()),
                SizedBox(width: 16),
                Expanded(child: WaterTracker()),
              ],
            ),
          ),
          SizedBox(height: 24),
          FadeTransition(
            opacity: controller.ultraSlowFadeAnimation,
            child: Text(
              'Today\'s Meals',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF424242),
              ),
            ),
          ),
          SizedBox(height: 16),
          Obx(() => Column(
            children: controller.mealPlans.asMap().entries.map((entry) {
              int index = entry.key;
              MealPlan meal = entry.value;
              return FadeTransition(
                opacity: Tween<double>(
                  begin: 0.0,
                  end: 1.0,
                ).animate(CurvedAnimation(
                  parent: controller.staggerController,
                  curve: Interval(
                    index * 0.2,
                    1.0,
                    curve: Curves.easeInOutSine,
                  ),
                )),
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: Offset(0, 0.2),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(
                    parent: controller.staggerController,
                    curve: Interval(
                      index * 0.15,
                      1.0,
                      curve: Curves.easeOutCubic,
                    ),
                  )),
                  child: MealPlanCard(mealPlan: meal),
                ),
              );
            }).toList(),
          )),
        ],
      ),
    );
  }

  Widget _buildMealsTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FadeTransition(
            opacity: controller.slowFadeAnimation,
            child: Text(
              'Meal Plans',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF424242),
              ),
            ),
          ),
          SizedBox(height: 16),
          Obx(() => Column(
            children: controller.mealPlans.asMap().entries.map((entry) {
              int index = entry.key;
              MealPlan meal = entry.value;
              return FadeTransition(
                opacity: Tween<double>(
                  begin: 0.0,
                  end: 1.0,
                ).animate(CurvedAnimation(
                  parent: controller.staggerController,
                  curve: Interval(
                    index * 0.25,
                    1.0,
                    curve: Curves.easeInOutSine,
                  ),
                )),
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: Offset(-0.2, 0),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(
                    parent: controller.staggerController,
                    curve: Interval(
                      index * 0.2,
                      1.0,
                      curve: Curves.easeOutCubic,
                    ),
                  )),
                  child: MealPlanCard(mealPlan: meal, detailed: true),
                ),
              );
            }).toList(),
          )),
        ],
      ),
    );
  }

  Widget _buildFoodsTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FadeTransition(
            opacity: controller.slowFadeAnimation,
            child: Text(
              'Healthy Foods',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF424242),
              ),
            ),
          ),
          SizedBox(height: 16),
          Obx(() => GridView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.78,
            ),
            itemCount: controller.foodItems.length,
            itemBuilder: (context, index) {
              return FadeTransition(
                opacity: Tween<double>(
                  begin: 0.0,
                  end: 1.0,
                ).animate(CurvedAnimation(
                  parent: controller.staggerController,
                  curve: Interval(
                    index * 0.1,
                    1.0,
                    curve: Curves.easeInOutSine,
                  ),
                )),
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: Offset(0, 0.3),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(
                    parent: controller.staggerController,
                    curve: Interval(
                      index * 0.08,
                      1.0,
                      curve: Curves.easeOutCubic,
                    ),
                  )),
                  child: GestureDetector(
                    onTap: () => Get.to( // Instant navigation
                          () => FoodDetailScreen(foodItem: controller.foodItems[index]),
                      transition: Transition.fadeIn,
                      duration: Duration(milliseconds: 400),
                    ),
                    child: FoodItemCard(foodItem: controller.foodItems[index]),
                  ),
                ),
              );
            },
          )),
        ],
      ),
    );
  }
}