import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/constants.dart';
import '../../core/l10n.dart';
import '../../data/providers/food_controller.dart';
import '../../data/providers/settings_controller.dart';
import 'food_detail_screen.dart';
import '../widgets/hero_routes.dart';

class FoodLibraryScreen extends StatefulWidget {
  const FoodLibraryScreen({super.key});

  @override
  State<FoodLibraryScreen> createState() => _FoodLibraryScreenState();
}

class _FoodLibraryScreenState extends State<FoodLibraryScreen> {
  final controller = Get.find<FoodController>();
  final settings = Get.find<SettingsController>();
  final _search = TextEditingController();

  String t(String key) => AppStrings.get(settings.language.value, key);

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
              child: Text(
                t('foods'),
                style: Theme.of(context).textTheme.displayMedium,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
              child: TextField(
                controller: _search,
                onChanged: controller.onSearchChanged,
                decoration: InputDecoration(
                  hintText: t('search_foods'),
                  prefixIcon: const Icon(Icons.search_rounded,
                      color: AppColors.muted),
                  suffixIcon: Obx(() {
                    final hasText = controller.searchQuery.value.isNotEmpty ||
                        _search.text.isNotEmpty;
                    if (!hasText) return const SizedBox.shrink();
                    return IconButton(
                      onPressed: () {
                        _search.clear();
                        controller.onSearchChanged('');
                        setState(() {});
                      },
                      icon: const Icon(Icons.close_rounded,
                          color: AppColors.muted),
                    );
                  }),
                ),
              ),
            ),
            // Horizontal scrolling chip row (one row, full labels).
            SizedBox(
              height: 48,
              child: Obx(() {
                final lang = settings.language.value;
                return ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(
                          t('all'),
                          style: const TextStyle(fontSize: 13),
                        ),
                        selected: controller.selectedGoal.value == null,
                        onSelected: (_) => controller.setGoal(null),
                      ),
                    ),
                    ...controller.goals.map((g) {
                      final color = Color(
                        int.parse(g.colorHex.replaceFirst('#', '0xFF')),
                      );
                      final label = AppStrings.foodGoalLabel(g.slug, lang);
                      final selected = controller.selectedGoal.value == g.slug;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          avatar: Text(g.emoji),
                          selected: selected,
                          onSelected: (_) => controller.setGoal(g.slug),
                          label: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 140),
                            child: Text(
                              label,
                              maxLines: 1,
                              overflow: TextOverflow.visible,
                              softWrap: false,
                              style: TextStyle(
                                fontSize: 13,
                                color: selected
                                    ? color
                                    : const Color(0xFF151A24),
                                fontWeight: selected
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                              ),
                            ),
                          ),
                          backgroundColor: color.withValues(alpha: 0.08),
                          selectedColor: color.withValues(alpha: 0.22),
                          side: BorderSide(
                            color: selected ? color : AppColors.border,
                          ),
                        ),
                      );
                    }),
                  ],
                );
              }),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Obx(() => Text(
                          '${controller.filtered.length} ${t('foods').toLowerCase()}',
                          style: Theme.of(context).textTheme.bodyMedium,
                        )),
                  ),
                  Obx(() => DropdownButton<FoodSort>(
                        value: controller.sort.value,
                        underline: const SizedBox.shrink(),
                        dropdownColor: Colors.white,
                        items: [
                          DropdownMenuItem(
                              value: FoodSort.name,
                              child: Text(t('sort_name'))),
                          DropdownMenuItem(
                              value: FoodSort.protein,
                              child: Text(t('sort_protein'))),
                          DropdownMenuItem(
                              value: FoodSort.fiber,
                              child: Text(t('sort_fiber'))),
                          DropdownMenuItem(
                              value: FoodSort.vitaminC,
                              child: Text(t('sort_vitamin_c'))),
                        ],
                        onChanged: (v) {
                          if (v != null) controller.setSort(v);
                        },
                      )),
                ],
              ),
            ),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value && controller.foods.isEmpty) {
                  return const Center(
                    child:
                        CircularProgressIndicator(color: AppColors.primary),
                  );
                }
                final list = controller.filtered;
                if (list.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Text(t('no_foods'),
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium),
                    ),
                  );
                }
                return GridView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.72,
                  ),
                  itemCount: list.length,
                  itemBuilder: (context, i) {
                    final food = list[i];
                    final goal = controller.goalFor(food.goalSlug);
                    final color = Color(
                      int.parse((goal?.colorHex ?? '#C8F542')
                          .replaceFirst('#', '0xFF')),
                    );
                    final url = food.imageUrl;
                    return InkWell(
                      onTap: () {
                        Navigator.of(context).push(
                          HeroRoutes.build(FoodDetailScreen(food: food)),
                        );
                      },
                      borderRadius: BorderRadius.circular(18),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border:
                              Border.all(color: color.withValues(alpha: 0.35)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: SlowHero(
                                tag: 'food-${food.id}',
                                child: HeroNetworkImage(
                                  url: url,
                                  height: double.infinity,
                                  fit: BoxFit.cover,
                                  fallbackEmoji:
                                      foodGoalEmoji(food.goalSlug),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    food.name,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(fontSize: 13.5),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    food.dailyAmount.isEmpty
                                        ? '1 serving/day'
                                        : _normalizeDaily(food.dailyAmount),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          fontSize: 12,
                                          color: const Color(0xFF151A24),
                                          fontWeight: FontWeight.w600,
                                        ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${goal?.emoji ?? '🍎'} ${AppStrings.foodGoalLabel(food.goalSlug, settings.language.value)}',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: color,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  String _normalizeDaily(String value) {
    final v = value.trim();
    if (v.isEmpty) return '1 serving/day';
    final lower = v.toLowerCase();
    if (lower.contains('/day') ||
        lower.contains('/week') ||
        lower.contains('per day') ||
        lower.contains('2x') ||
        lower.contains('×')) {
      return v;
    }
    return '$v/day';
  }
}
