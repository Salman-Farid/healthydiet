import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/routes.dart';
import '../../core/constants.dart';
import '../../core/l10n.dart';
import '../../data/providers/exercise_controller.dart';
import '../../data/providers/settings_controller.dart';
import '../../data/providers/workout_controller.dart';
import '../widgets/common.dart';

/// Train tab — tap a section → ONLY that section's exercises from 1324.
class WorkoutListScreen extends StatelessWidget {
  const WorkoutListScreen({super.key});

  /// Lock library to one training section (strict filter).
  static void openSection(ExerciseController ex, String slug, String lang) {
    final key = AppStrings.normalizeSlug(slug);
    final label = AppStrings.templateName(key, lang);
    switch (key) {
      case 'sixpack':
        ex.lockToSection(bodyParts: const ['waist'], label: label);
      case 'chest':
        ex.lockToSection(bodyParts: const ['chest'], label: label);
      case 'arms':
        ex.lockToSection(
          bodyParts: const ['upper arms', 'lower arms'],
          label: label,
        );
      case 'legs':
        ex.lockToSection(
          bodyParts: const ['upper legs', 'lower legs'],
          label: label,
        );
      case 'fatburn':
        ex.lockToSection(bodyParts: const ['cardio'], label: label);
      case 'beginner':
        ex.lockToSection(equipment: 'body weight', label: label);
      case 'fullbody':
      default:
        // Whole body = every exercise in the catalog (still “this section”).
        ex.lockToSection(bodyParts: const [], equipment: null, label: label);
        ex.lockedLabel.value = label;
        // Empty locks + no equipment → all 1324, only when section is full body.
        ex.applyFilters();
    }
    Get.toNamed(AppRoutes.library);
  }

  @override
  Widget build(BuildContext context) {
    final workouts = Get.find<WorkoutController>();
    final exercises = Get.find<ExerciseController>();
    final lang = Get.isRegistered<SettingsController>()
        ? Get.find<SettingsController>().language.value
        : 'en';

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Obx(() {
          final tpls = workouts.templates;
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 128),
            children: [
              Text(
                AppStrings.get(lang, 'train'),
                style: Theme.of(context).textTheme.displayMedium,
              ),
              const SizedBox(height: 6),
              Text(
                AppStrings.get(lang, 'train_subtitle'),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              if (tpls.isEmpty)
                EmptyState(
                  icon: Icons.directions_run_rounded,
                  title: AppStrings.get(lang, 'train'),
                  message: AppStrings.get(lang, 'exercises'),
                )
              else
                ...tpls.map((t) {
                  final color = Color(
                    int.parse(t.accentColor.replaceFirst('#', '0xFF')),
                  );
                  final slug = AppStrings.normalizeSlug(t.slug);
                  final label = AppStrings.templateName(slug, lang);
                  final hint = AppStrings.templateHint(slug, lang);
                  final emoji = AppStrings.templateEmoji(slug);
                  final count = _countFor(exercises, slug);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _TrainCard(
                      emoji: emoji,
                      title: label,
                      subtitle:
                          '$hint · $count ${AppStrings.get(lang, 'exercises')}',
                      color: color,
                      onTap: () => openSection(exercises, t.slug, lang),
                    ),
                  );
                }),
            ],
          );
        }),
      ),
    );
  }

  /// Count ONLY exercises that belong to this section.
  int _countFor(ExerciseController ex, String slug) {
    switch (slug) {
      case 'sixpack':
        return ex.exercises.where((e) => e.bodyPart == 'waist').length;
      case 'chest':
        return ex.exercises.where((e) => e.bodyPart == 'chest').length;
      case 'arms':
        return ex.exercises
            .where((e) =>
                e.bodyPart == 'upper arms' || e.bodyPart == 'lower arms')
            .length;
      case 'legs':
        return ex.exercises
            .where((e) =>
                e.bodyPart == 'upper legs' || e.bodyPart == 'lower legs')
            .length;
      case 'fatburn':
        return ex.exercises.where((e) => e.bodyPart == 'cardio').length;
      case 'beginner':
        return ex.exercises.where((e) => e.equipment == 'body weight').length;
      default:
        return ex.exercises.length;
    }
  }
}

class _TrainCard extends StatelessWidget {
  const _TrainCard({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  final String emoji;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: color.withOpacity(0.45)),
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(emoji, style: const TextStyle(fontSize: 26)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 4),
                  Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.muted),
          ],
        ),
      ),
    );
  }
}
