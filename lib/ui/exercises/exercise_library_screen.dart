import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/constants.dart';
import '../../core/l10n.dart';
import '../../data/providers/exercise_controller.dart';
import '../../data/providers/settings_controller.dart';
import '../exercise_detail/exercise_detail_screen.dart';
import '../widgets/common.dart';
import '../widgets/hero_routes.dart';

/// Dashboard = exercise library. Real chip counts + continuous shimmer scroll.
class ExerciseLibraryScreen extends StatefulWidget {
  const ExerciseLibraryScreen({super.key});

  @override
  State<ExerciseLibraryScreen> createState() => _ExerciseLibraryScreenState();
}

class _ExerciseLibraryScreenState extends State<ExerciseLibraryScreen> {
  final controller = Get.find<ExerciseController>();
  final settings = Get.find<SettingsController>();
  final _search = TextEditingController();

  String t(String key) => AppStrings.get(settings.language.value, key);

  @override
  void initState() {
    super.initState();
    final args = Get.arguments;
    if (args is Map) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (args['bodyPart'] != null) {
          controller.setBodyPart(args['bodyPart'] as String?);
        }
        if (args['equipment'] != null) {
          controller.setEquipment(args['equipment'] as String?);
        }
        if (args['query'] != null) {
          _search.text = args['query'] as String;
          controller.onSearchChanged(_search.text);
        }
      });
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        controller.clearFilters();
      });
    }
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lang = settings.language.value;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
              child: Obx(() {
                final locked = controller.isSectionLocked;
                final title = locked && controller.lockedLabel.value.isNotEmpty
                    ? controller.lockedLabel.value
                    : t('exercises');
                return Row(
                  children: [
                    Expanded(
                      child: Text(title,
                          style: Theme.of(context).textTheme.displayMedium),
                    ),
                    if (locked)
                      TextButton(
                        onPressed: () => controller.unlockSection(),
                        child: Text(t('all'),
                            style:
                                const TextStyle(color: AppColors.primary)),
                      ),
                  ],
                );
              }),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
              child: TextField(
                controller: _search,
                onChanged: controller.onSearchChanged,
                decoration: InputDecoration(
                  hintText: t('search_hint'),
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
            // Real catalog counts on every chip.
            SizedBox(
              height: 44,
              child: Obx(() {
                if (controller.isSectionLocked) {
                  final label = controller.lockedLabel.value.isEmpty
                      ? t('exercises')
                      : controller.lockedLabel.value;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Chip(
                        avatar: const Text('🔒'),
                        label: Text('$label · ${controller.filtered.length}'),
                        backgroundColor: AppColors.primarySoft,
                        side: const BorderSide(color: AppColors.primary),
                      ),
                    ),
                  );
                }
                return ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(
                            '${t('all')} ${controller.filtered.length}'),
                        selected: controller.selectedBodyPart.value == null,
                        onSelected: (_) => controller.setBodyPart(null),
                      ),
                    ),
                    ...controller.bodyParts.map((p) {
                      final count = controller.countForSlug(p.slug);
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          avatar: Text(p.emoji),
                          label: Text(
                            '${AppStrings.bodyPartLabel(p.slug, lang)} $count',
                          ),
                          selected: controller.selectedBodyPart.value == p.slug,
                          onSelected: (_) => controller.setBodyPart(p.slug),
                        ),
                      );
                    }),
                  ],
                );
              }),
            ),
            Expanded(
              child: Obx(() {
                final list = controller.visibleFiltered;
                final loading =
                    controller.isLoading.value && list.isEmpty;
                if (loading) {
                  return GridView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 128),
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 0.82,
                    ),
                    itemCount: 6,
                    itemBuilder: (_, __) => Container(
                      decoration: BoxDecoration(
                        color: AppColors.surfaceAlt,
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                  );
                }
                if (list.isEmpty) {
                  return EmptyState(
                    icon: Icons.search_off_rounded,
                    title: t('exercises'),
                    message: t('search_hint'),
                  );
                }

                final moreAvailable = controller.hasMore(list);
                final showFooter =
                    moreAvailable || controller.isLoadingMore.value;
                final pairs = (list.length + 1) ~/ 2;
                final rows = showFooter ? pairs + 1 : pairs;

                return NotificationListener<ScrollNotification>(
                  onNotification: (n) {
                    if (n.metrics.pixels >= n.metrics.maxScrollExtent - 420) {
                      controller.loadMore();
                    }
                    return false;
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 128),
                    itemCount: rows,
                    itemBuilder: (context, rowIndex) {
                      if (rowIndex >= pairs) {
                        return const _FooterShimmer();
                      }
                      final i = rowIndex * 2;
                      final left = list[i];
                      final right =
                          i + 1 < list.length ? list[i + 1] : null;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: _Card(exercise: left, lang: lang),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: right == null
                                  ? const SizedBox.shrink()
                                  : _Card(exercise: right, lang: lang),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class _FooterShimmer extends StatelessWidget {
  const _FooterShimmer();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 2, bottom: 8),
      child: Column(
        children: List.generate(
          2,
          (_) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                _shimmerBox(),
                const SizedBox(width: 12),
                _shimmerBox(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _shimmerBox() {
    return Expanded(
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          color: AppColors.surfaceAlt,
          borderRadius: BorderRadius.circular(18),
        ),
        child: const Center(
          child: SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.primary,
            ),
          ),
        ),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.exercise, required this.lang});

  final dynamic exercise;
  final String lang;

  @override
  Widget build(BuildContext context) {
    final e = exercise;
    final color = AppColors.forBodyPart(e.bodyPart as String);
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          HeroRoutes.build(ExerciseDetailScreen(exercise: e)),
        );
      },
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: color.withOpacity(0.35)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: SlowHero(
                tag: 'exercise-${e.id}',
                child: HeroNetworkImage(
                  url: e.thumbnailUrl as String,
                  height: double.infinity,
                  fit: BoxFit.cover,
                  fallbackEmoji: '🏋️',
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    e.name as String,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    AppStrings.bodyPartLabel(e.bodyPart as String, lang),
                    style: TextStyle(color: color, fontSize: 11),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
