import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/routes.dart';
import '../../core/constants.dart';
import '../../core/l10n.dart';
import '../../data/providers/exercise_controller.dart';
import '../../data/providers/settings_controller.dart';
import '../widgets/common.dart';
import '../widgets/hero_routes.dart';
import '../exercise_detail/exercise_detail_screen.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ExerciseController>();
    final settings = Get.find<SettingsController>();
    final lang = settings.language.value;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
              child: Text(
                AppStrings.get(lang, 'favourites'),
                style: Theme.of(context).textTheme.displayMedium,
              ),
            ),
            Expanded(
              child: Obx(() {
                final list = controller.favoriteExercises;
                if (list.isEmpty) {
                  return EmptyState(
                    icon: Icons.favorite_border_rounded,
                    title: AppStrings.get(lang, 'no_favourites'),
                    message: AppStrings.get(lang, 'tap_heart'),
                  );
                }
                return GridView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 128),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.82,
                  ),
                  itemCount: list.length,
                  itemBuilder: (context, i) {
                    final e = list[i];
                    final color = AppColors.forBodyPart(e.bodyPart);
                    return GestureDetector(
                      onTap: () {
                          Navigator.of(context).push(
                            HeroRoutes.build(ExerciseDetailScreen(exercise: e)),
                          );
                        },
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: color.withOpacity(0.35)),
                        ),
                        child: Stack(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(18)),
                                    child: SlowHero(
                                      tag: 'exercise-${e.id}',
                                      child: ExerciseThumb(
                                        url: e.thumbnailUrl,
                                        size: double.infinity,
                                        radius: 0,
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        e.name,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium
                                            ?.copyWith(fontSize: 13),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        AppStrings.bodyPartLabel(
                                            e.bodyPart, lang),
                                        style: TextStyle(
                                            color: color, fontSize: 11),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            Positioned(
                              top: 6,
                              right: 6,
                              child: IconButton(
                                onPressed: () =>
                                    controller.toggleFavorite(e.id),
                                icon: const Icon(Icons.favorite,
                                    color: AppColors.primary),
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
}
