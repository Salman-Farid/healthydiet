import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/l10n.dart';
import '../../data/models/food.dart';
import '../../data/providers/food_controller.dart';
import '../../data/providers/settings_controller.dart';
import '../widgets/common.dart';
import '../widgets/hero_routes.dart';

class FoodDetailScreen extends StatefulWidget {
  const FoodDetailScreen({super.key, required this.food});

  final FoodItem food;

  @override
  State<FoodDetailScreen> createState() => _FoodDetailScreenState();
}

class _FoodDetailScreenState extends State<FoodDetailScreen> {
  late FoodItem food = widget.food;
  final controller = Get.find<FoodController>();
  final settings = Get.find<SettingsController>();

  String t(String key) => AppStrings.get(settings.language.value, key);

  @override
  void initState() {
    super.initState();
    // Never touch GetX Rx lists during the first build.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _load();
    });
  }

  Future<void> _load() async {
    final enriched = await controller.enrich(widget.food);
    if (!mounted) return;
    setState(() => food = enriched);
  }

  @override
  Widget build(BuildContext context) {
    final goal = controller.goalFor(food.goalSlug);
    final lang = settings.language.value;
    final url = food.imageUrl;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF151A24),
        elevation: 0,
        title: Text(food.name),
      ),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Full image on pure white — same HeroNetworkImage type as grid.
          SlowHero(
            tag: 'food-${food.id}',
            child: HeroNetworkImage(
              url: url,
              height: 280,
              fit: BoxFit.contain,
              fallbackEmoji: foodGoalEmoji(food.goalSlug),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(food.name,
                    style: Theme.of(context).textTheme.displayMedium),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    MuscleChip(
                      label:
                          '${goal?.emoji ?? '🍎'} ${AppStrings.foodGoalLabel(food.goalSlug, lang)}',
                      primary: true,
                    ),
                    if (food.dailyAmount.isNotEmpty)
                      MuscleChip(label: food.dailyAmount),
                  ],
                ),
                const SizedBox(height: 20),
                Text(t('why_helps'),
                    style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 10),
                Text(
                  _detailedBenefits(food),
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge
                      ?.copyWith(height: 1.55),
                ),
                if (food.keyNutrients.isNotEmpty) ...[
                  const SizedBox(height: 18),
                  Text(t('key_nutrients'),
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: food.keyNutrients
                        .map((n) => Chip(label: Text(n)))
                        .toList(),
                  ),
                ],
                const SizedBox(height: 20),
                Text(t('nutrition_usda'),
                    style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 8),
                if (food.nutrients.isEmpty)
                  Text(t('loading_nutrients'),
                      style: Theme.of(context).textTheme.bodyMedium)
                else
                  Column(
                    children: [
                      for (final n in food.nutrients)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(_shortNutrient(n.name),
                                    style:
                                        Theme.of(context).textTheme.bodyLarge),
                              ),
                              Text(
                                n.display,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.copyWith(fontWeight: FontWeight.w700),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                const SizedBox(height: 12),
                Text(
                  food.dailyAmount.isEmpty
                      ? ''
                      : '${t('daily_amount_hint')}: ${food.dailyAmount}',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _shortNutrient(String name) {
    switch (name) {
      case 'Carbohydrate, by difference':
        return 'Carbs';
      case 'Total lipid (fat)':
        return 'Fat';
      case 'Fiber, total dietary':
        return 'Fiber';
      case 'Vitamin C, total ascorbic acid':
        return 'Vitamin C';
      case 'Vitamin D (D2 + D3)':
        return 'Vitamin D';
      case 'Vitamin E (alpha-tocopherol)':
        return 'Vitamin E';
      case 'Vitamin K (phylloquinone)':
        return 'Vitamin K';
      default:
        return name;
    }
  }

  /// Longer, user-friendly benefits copy.
  String _detailedBenefits(FoodItem food) {
    final base = food.why.trim();
    final extra = _extraBenefits[food.name.toLowerCase()] ?? '';
    final nutrients = food.keyNutrients.join(', ');
    final goal = AppStrings.foodGoalLabel(food.goalSlug, lang);
    final parts = <String>[
      if (base.isNotEmpty) base,
      if (extra.isNotEmpty) extra,
      'Best known for supporting $goal health. Key nutrients: ${nutrients.isEmpty ? 'see nutrition panel' : nutrients}.',
      if (food.dailyAmount.isNotEmpty)
        'Practical daily amount: ${food.dailyAmount}.',
    ];
    return parts.join('\n\n');
  }

  String get lang => settings.language.value;

  static const _extraBenefits = {
    'walnuts':
        'Walnuts are one of the richest plant sources of alpha-linolenic acid (ALA), an omega-3 fat linked with better cognitive performance. Regular small portions may help maintain healthy cholesterol and support memory as part of a balanced diet.',
    'salmon':
        'Salmon provides high-quality protein plus EPA/DHA omega-3 fatty acids. These fats support heart rhythm, reduce exercise-related inflammation, and are important structural fats in the brain and retina.',
    'eggs':
        'Eggs are a complete protein with leucine for muscle repair, choline for brain function, and lutein/zeaxanthin that accumulate in the eyes. They also supply B12 and vitamin D.',
    'spinach':
        'Spinach is dense in nitrates, magnesium, folate, and carotenoids. Nitrates can support healthy blood pressure, while lutein supports macular health. Cook lightly or pair with a little fat to absorb fat-soluble vitamins.',
    'oats':
        'Oats are rich in beta-glucan soluble fiber, which can help manage cholesterol and provide steady energy without big sugar spikes. They also supply magnesium and B vitamins for daily stamina.',
    'blueberries':
        'Blueberries are packed with anthocyanins — antioxidants associated with slower cognitive decline. They are low calorie, high fiber, and easy to add to breakfast for a brain-friendly start.',
    'dark chocolate':
        'Cocoa flavanols may support blood flow to the brain and healthy blood pressure. Choose high-cocoa (70%+) chocolate and keep portions small because of sugar and calories.',
    'carrots':
        'Carrots are famous for beta-carotene, which the body converts to vitamin A — essential for night vision and tear film health. A little healthy fat at the same meal improves absorption.',
    'sweet potato':
        'Sweet potatoes are loaded with beta-carotene and complex carbohydrates. They support vision, immune function, and sustained energy, plus potassium for muscle function.',
    'avocado':
        'Avocado supplies monounsaturated fats, vitamin E, and potassium. These nutrients help skin moisture, reduce dryness, and support absorption of other fat-soluble vitamins from your meal.',
    'orange':
        'Oranges are a classic vitamin C source that supports collagen formation, immune cells, and healthy blood vessels in skin and eyes. Whole fruit also gives fiber for steadier blood sugar.',
    'tomato':
        'Tomatoes provide lycopene, a carotenoid linked with skin resilience against UV stress. Cooking tomatoes with a little oil improves lycopene absorption.',
    'green tea':
        'Green tea catechins act as antioxidants and may support metabolism and skin health. 2–3 cups daily is a practical range for most people.',
    'milk':
        'Milk delivers calcium, vitamin D, and protein in an easily absorbed form — a core bone-building combination. Choose fortified options if you need extra vitamin D.',
    'yogurt':
        'Yogurt combines protein, calcium, and live cultures. Probiotics support gut balance, which is closely connected to immunity and digestion comfort.',
    'greek yogurt':
        'Greek yogurt is thicker and higher in protein than regular yogurt, making it useful after training. Casein protein digests slowly and can support overnight muscle recovery.',
    'lentils':
        'Lentils offer plant protein, iron, and soluble fiber. They support muscle repair, digestion regularity, and long-lasting energy without heavy fat.',
    'chicken breast':
        'Chicken breast is lean, high-quality protein ideal for muscle building and recovery. It pairs easily with carbs and vegetables for balanced post-workout meals.',
    'brown rice':
        'Brown rice is a whole-grain carb source with more fiber and magnesium than white rice — useful fuel for training days.',
    'banana':
        'Bananas give quick carbohydrates plus potassium, making them practical before or after workouts to support energy and muscle function.',
    'almonds':
        'Almonds provide vitamin E, magnesium, and healthy fats. Small handfuls can support heart health and help you stay full between meals.',
    'olive oil':
        'Extra-virgin olive oil is rich in monounsaturated fat and polyphenols, widely used in heart-healthy eating patterns. Use it for cooking or dressings in place of saturated fats.',
    'garlic':
        'Garlic contains allicin and other sulfur compounds studied for immune and cardiovascular support. It works best lightly crushed and rested before cooking.',
    'broccoli':
        'Broccoli supplies vitamin K, vitamin C, fiber, and calcium — a strong bone and immunity package. Steam briefly to keep nutrients.',
    'cheese':
        'Cheese concentrates calcium and protein. Enjoy in moderate portions; pick lower-sodium types if you watch blood pressure.',
    'sardines':
        'Sardines with soft edible bones are unusually high in calcium and vitamin D, plus omega-3s for heart and brain support.',
  };
}
