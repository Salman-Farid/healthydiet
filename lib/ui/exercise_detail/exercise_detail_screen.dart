import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/constants.dart';
import '../../core/l10n.dart';
import '../../data/models/exercise.dart';
import '../../data/providers/exercise_controller.dart';
import '../../data/providers/settings_controller.dart';
import '../widgets/common.dart';
import '../widgets/hero_routes.dart';

class ExerciseDetailScreen extends StatefulWidget {
  const ExerciseDetailScreen({
    super.key,
    required this.exercise,
    this.initialLanguage,
  });

  final Exercise exercise;
  final String? initialLanguage;

  @override
  State<ExerciseDetailScreen> createState() => _ExerciseDetailScreenState();
}

class _ExerciseDetailScreenState extends State<ExerciseDetailScreen> {
  late String _lang;
  final exercises = Get.find<ExerciseController>();
  final settings = Get.find<SettingsController>();

  String t(String key) => AppStrings.get(settings.language.value, key);

  @override
  void initState() {
    super.initState();
    _lang = widget.initialLanguage ?? settings.language.value;
    if (!AppConstants.instructionLanguages.containsKey(_lang)) {
      _lang = 'en';
    }
  }

  @override
  Widget build(BuildContext context) {
    final e = widget.exercise;
    final instruction = e.instructionFor(_lang);
    final steps = e.stepsFor(_lang);

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: Colors.white,
            foregroundColor: AppColors.ink,
            elevation: 0,
            pinned: true,
            expandedHeight:
                (MediaQuery.of(context).size.height * 0.62).clamp(280.0, 560.0),
            flexibleSpace: FlexibleSpaceBar(
              background: Padding(
                padding: const EdgeInsets.fromLTRB(12, 48, 12, 12),
                child: Center(
                  child: SlowHero(
                    tag: 'exercise-${e.id}',
                    child: HeroNetworkImage(
                      url: e.gifUrl.isNotEmpty ? e.gifUrl : e.thumbnailUrl,
                      height: double.infinity,
                      fit: BoxFit.contain,
                      fallbackEmoji: '🏋️',
                    ),
                  ),
                ),
              ),
            ),
            actions: [
              Obx(() {
                final fav = exercises.isFavorite(e.id);
                return IconButton(
                  onPressed: () => exercises.toggleFavorite(e.id),
                  icon: Icon(
                    fav ? Icons.favorite : Icons.favorite_border,
                    color: fav ? AppColors.primary : AppColors.ink,
                  ),
                );
              }),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(e.name,
                      style: Theme.of(context).textTheme.displayMedium),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      MuscleChip(
                        label: AppStrings.bodyPartLabel(
                            e.bodyPart, settings.language.value),
                        primary: true,
                      ),
                      MuscleChip(
                        label: AppStrings.equipmentLabel(
                            e.equipment, settings.language.value),
                      ),
                      if (e.target.isNotEmpty) MuscleChip(label: e.target),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: Text(t('instructions'),
                            style:
                                Theme.of(context).textTheme.headlineMedium),
                      ),
                      DropdownButton<String>(
                        value: _lang,
                        dropdownColor: Colors.white,
                        underline: const SizedBox.shrink(),
                        items: AppConstants.instructionLanguages.entries
                            .map(
                              (entry) => DropdownMenuItem(
                                value: entry.key,
                                child: Text(
                                  '${kLanguageFlags[entry.key] ?? ''} ${entry.value}',
                                  style:
                                      const TextStyle(color: AppColors.ink),
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (v) {
                          if (v == null) return;
                          setState(() => _lang = v);
                          settings.setLanguage(v);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  GlassCard(
                    color: Colors.white,
                    child: Text(
                      instruction.isEmpty
                          ? 'No instructions yet.'
                          : instruction,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                  if (steps.isNotEmpty) ...[
                    const SizedBox(height: 18),
                    Text(t('step_by_step'),
                        style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 8),
                    ...List.generate(steps.length, (i) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 28,
                              height: 28,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: AppColors.primarySoft,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '${i + 1}',
                                style: const TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(steps[i],
                                  style:
                                      Theme.of(context).textTheme.bodyLarge),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
