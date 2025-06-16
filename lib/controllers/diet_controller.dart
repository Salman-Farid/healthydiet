import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/food_item.dart';

class DietController extends GetxController with GetTickerProviderStateMixin {
  var selectedTab = 0.obs;
  var dailyCalories = 0.obs;
  var targetCalories = 2000.obs;
  var waterIntake = 0.obs;
  var targetWater = 8.obs;

  late AnimationController slowFadeController;
  late AnimationController slideController;
  late AnimationController scaleController;
  late AnimationController staggerController;

  late Animation<double> slowFadeAnimation;
  late Animation<double> ultraSlowFadeAnimation;
  late Animation<Offset> slideAnimation;
  late Animation<double> scaleAnimation;
  late Animation<double> staggeredFadeAnimation;

  var foodItems = <FoodItem>[].obs;
  var mealPlans = <MealPlan>[].obs;
  var isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();

    // Ultra slow motion fade controller (3 seconds)
    slowFadeController = AnimationController(
      duration: Duration(milliseconds: 3000),
      vsync: this,
    );

    // Slide animation controller (2.5 seconds)
    slideController = AnimationController(
      duration: Duration(milliseconds: 2500),
      vsync: this,
    );

    // Scale animation controller (2 seconds)
    scaleController = AnimationController(
      duration: Duration(milliseconds: 2000),
      vsync: this,
    );

    // Stagger controller for sequential animations
    staggerController = AnimationController(
      duration: Duration(milliseconds: 4000),
      vsync: this,
    );

    // Ultra slow fade in/out animation
    slowFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: slowFadeController,
      curve: Curves.easeInOutSine,
    ));

    // Even slower fade for special elements
    ultraSlowFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: slowFadeController,
      curve: Interval(0.2, 1.0, curve: Curves.easeInOutQuart),
    ));

    // Gentle slide animation
    slideAnimation = Tween<Offset>(
      begin: Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: slideController,
      curve: Curves.easeOutCubic,
    ));

    // Soft scale animation
    scaleAnimation = Tween<double>(
      begin: 0.9,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: scaleController,
      curve: Curves.easeOutBack,
    ));

    // Staggered fade animation for lists
    staggeredFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: staggerController,
      curve: Curves.easeInOutSine,
    ));

    initializeData();
    _startSlowAnimations();
  }

  void _startSlowAnimations() async {
    // Start loading screen
    await Future.delayed(Duration(milliseconds: 200));

    // Begin slow motion animations
    slowFadeController.forward();

    await Future.delayed(Duration(milliseconds: 500));
    slideController.forward();

    await Future.delayed(Duration(milliseconds: 300));
    scaleController.forward();

    await Future.delayed(Duration(milliseconds: 200));
    staggerController.forward();

    // End loading after animations start
    await Future.delayed(Duration(milliseconds: 1500));
    isLoading.value = false;
  }

  void initializeData() {
    foodItems.value = [
      FoodItem(
        name: 'Avocado Toast',
        category: 'Breakfast',
        calories: 320,
        imageUrl: 'https://plus.unsplash.com/premium_photo-1701713781708-4d52f56c3c98?q=80&w=2070&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D', // use turn0image2
        heroTag: 'avocado_toast',
        nutrients: ['Healthy Fats', 'Fiber', 'Potassium'],
        description: 'Nutrient-rich breakfast with fresh avocado on artisan bread',
      ),
      FoodItem(
        name: 'Grilled Salmon',
        category: 'Lunch',
        calories: 280,
        imageUrl: 'https://images.unsplash.com/photo-1467003909585-2f8a72700288?w=400&h=300&fit=crop',
        heroTag: 'grilled_salmon',
        nutrients: ['Omega-3', 'Protein', 'Vitamin D'],
        description: 'Heart‑healthy grilled salmon with herbs and lemon',
      ),
      FoodItem(
        name: 'Quinoa Buddha Bowl',
        category: 'Dinner',
        calories: 350,
        imageUrl: 'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=400&h=300&fit=crop',
        heroTag: 'quinoa_bowl',
        nutrients: ['Complete Protein', 'Fiber', 'Iron'],
        description: 'Colorful quinoa bowl with fresh vegetables and tahini',
      ),
      FoodItem(
        name: 'Greek Yogurt Parfait',
        category: 'Snack',
        calories: 150,
        imageUrl: 'https://images.unsplash.com/photo-1488477181946-6428a0291777?w=400&h=300&fit=crop',
        heroTag: 'greek_yogurt',
        nutrients: ['Protein', 'Probiotics', 'Calcium'],
        description: 'Creamy Greek yogurt with berries and granola',
      ),
      FoodItem(
        name: 'Mixed Berry Smoothie',
        category: 'Snack',
        calories: 120,
        imageUrl: 'https://images.unsplash.com/photo-1630823183901-0b3207fa9f1b?q=80&w=1936&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
        heroTag: 'berry_smoothie',
        nutrients: ['Antioxidants', 'Vitamin C', 'Fiber'],
        description: 'Refreshing smoothie packed with mixed berries',
      ),
      FoodItem(
        name: 'Kale Caesar Salad',
        category: 'Lunch',
        calories: 180,
        imageUrl: 'https://images.unsplash.com/photo-1512058564366-18510be2db19?w=400&h=300&fit=crop',
        heroTag: 'kale_salad',
        nutrients: ['Vitamin K', 'Folate', 'Iron'],
        description: 'Fresh kale salad with light Caesar dressing',
      ),
      FoodItem(
        name: 'Chia Pudding',
        category: 'Breakfast',
        calories: 200,
        imageUrl: 'https://simpleveganblog.com/wp-content/uploads/2023/01/how-to-make-chia-pudding-square.jpg',
        heroTag: 'chia_pudding',
        nutrients: ['Omega-3', 'Fiber', 'Protein'],
        description: 'Overnight chia pudding with coconut milk and vanilla',
      ),
      FoodItem(
        name: 'Herb Grilled Chicken',
        category: 'Dinner',
        calories: 250,
        imageUrl: 'https://images.unsplash.com/photo-1594221708779-94832f4320d1?w=400&h=300&fit=crop',
        heroTag: 'grilled_chicken',
        nutrients: ['Lean Protein', 'B Vitamins', 'Selenium'],
        description: 'Lean grilled chicken breast with fresh herbs',
      ),
    ];


    mealPlans.value = [
      MealPlan(
        mealType: 'Breakfast',
        foods: [foodItems[0], foodItems[6]],
        totalCalories: 520,
      ),
      MealPlan(
        mealType: 'Lunch',
        foods: [foodItems[1], foodItems[5]],
        totalCalories: 460,
      ),
      MealPlan(
        mealType: 'Dinner',
        foods: [foodItems[2], foodItems[7]],
        totalCalories: 600,
      ),
    ];

    calculateDailyCalories();
  }

  void calculateDailyCalories() {
    dailyCalories.value = mealPlans.fold(0, (sum, meal) => sum + meal.totalCalories);
  }

  void addWater() {
    if (waterIntake.value < targetWater.value) {
      waterIntake.value++;
    }
  }

  void removeWater() {
    if (waterIntake.value > 0) {
      waterIntake.value--;
    }
  }

  // Instant tab change without animation delay
  void changeTab(int index) {
    selectedTab.value = index;
  }

  // Slow fade transition for content only
  void triggerContentFade() {
    slowFadeController.reset();
    slowFadeController.forward();
  }

  @override
  void onClose() {
    slowFadeController.dispose();
    slideController.dispose();
    scaleController.dispose();
    staggerController.dispose();
    super.onClose();
  }
}