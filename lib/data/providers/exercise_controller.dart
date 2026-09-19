import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/constants.dart';
import '../models/exercise.dart';
import '../repositories/exercise_repository.dart';

class ExerciseController extends GetxController {
  ExerciseRepository? _repo;

  ExerciseRepository? get _repository {
    if (_repo != null) return _repo;
    try {
      _repo = ExerciseRepository(Supabase.instance.client);
      return _repo;
    } catch (e) {
      debugPrint('Exercise repo unavailable: $e');
      return null;
    }
  }

  final exercises = <Exercise>[].obs;
  final filtered = <Exercise>[].obs;
  final bodyParts = <BodyPartInfo>[].obs;
  final equipment = <EquipmentInfo>[].obs;
  final targets = <String>[].obs;
  final favorites = <String>{}.obs;

  final isLoading = true.obs;
  final isRefreshing = false.obs;
  final searchQuery = ''.obs;
  final selectedBodyPart = RxnString();
  final selectedEquipment = RxnString();
  final selectedTarget = RxnString();

  /// When set, ONLY these body parts / equipment are shown (Train tab sections).
  final lockedBodyParts = <String>{}.obs;
  final lockedEquipment = RxnString();
  final lockedLabel = ''.obs;

  final scrollLimit = 60.obs;
  final isLoadingMore = false.obs;

  bool get isSectionLocked =>
      lockedBodyParts.isNotEmpty || lockedEquipment.value != null;

  /// Real library totals (exercise-dataset). Updated when full catalog loads.
  static const _catalogCounts = <String, int>{
    'chest': 163,
    'back': 203,
    'shoulders': 143,
    'upper arms': 292,
    'lower arms': 37,
    'waist': 169,
    'upper legs': 227,
    'lower legs': 59,
    'cardio': 29,
    'neck': 2,
  };

  static const _defaultParts = <BodyPartInfo>[
    BodyPartInfo(slug: 'chest', label: 'chest', emoji: '🫁', colorHex: '#FF6B35'),
    BodyPartInfo(slug: 'back', label: 'back', emoji: '🔙', colorHex: '#0EA5E9'),
    BodyPartInfo(slug: 'shoulders', label: 'shoulders', emoji: '💪', colorHex: '#22C55E'),
    BodyPartInfo(slug: 'upper arms', label: 'upper arms', emoji: '💪', colorHex: '#8B5CF6'),
    BodyPartInfo(slug: 'waist', label: 'waist', emoji: '🎯', colorHex: '#F59E0B'),
    BodyPartInfo(slug: 'upper legs', label: 'upper legs', emoji: '🦵', colorHex: '#14B8A6'),
    BodyPartInfo(slug: 'lower legs', label: 'lower legs', emoji: '🦶', colorHex: '#3B82F6'),
    BodyPartInfo(slug: 'cardio', label: 'cardio', emoji: '❤️', colorHex: '#EF4444'),
    BodyPartInfo(slug: 'lower arms', label: 'lower arms', emoji: '✊', colorHex: '#EC4899'),
    BodyPartInfo(slug: 'neck', label: 'neck', emoji: '🧣', colorHex: '#64748B'),
  ];

  int countForSlug(String slug) {
    for (final p in bodyParts) {
      if (p.slug == slug && p.count > 0) return p.count;
    }
    return _catalogCounts[slug] ?? 0;
  }

  void _seedDefaultBodyParts() {
    if (bodyParts.isNotEmpty) return;
    bodyParts.assignAll(_defaultParts.map((p) {
      final c = _catalogCounts[p.slug] ?? p.count;
      return BodyPartInfo(
        slug: p.slug,
        label: p.label,
        emoji: p.emoji,
        colorHex: p.colorHex,
        count: c,
      );
    }).toList());
  }

  void _applyLiveCounts() {
    final counts = <String, int>{};
    for (final e in exercises) {
      final k = e.bodyPart.toLowerCase();
      counts[k] = (counts[k] ?? 0) + 1;
    }
    // Prefer live counts when they look like a full catalog (>= ~200 items).
    final useLive = exercises.length >= 200;
    final updated = bodyParts.map((p) {
      final live = useLive ? (counts[p.slug.toLowerCase()] ?? 0) : 0;
      final display = live > 0 ? live : (_catalogCounts[p.slug] ?? p.count);
      return BodyPartInfo(
        slug: p.slug,
        label: p.label,
        emoji: p.emoji,
        colorHex: p.colorHex,
        count: display,
      );
    }).toList();
    bodyParts.assignAll(updated);
  }

  void lockToSection({
    List<String>? bodyParts,
    String? equipment,
    String label = '',
  }) {
    lockedBodyParts.assignAll(bodyParts ?? const []);
    lockedEquipment.value = equipment;
    lockedLabel.value = label;
    searchQuery.value = '';
    selectedBodyPart.value = null;
    selectedEquipment.value = equipment;
    selectedTarget.value = null;
    applyFilters();
  }

  void unlockSection({bool clearFilters = true}) {
    lockedBodyParts.clear();
    lockedEquipment.value = null;
    lockedLabel.value = '';
    if (clearFilters) {
      this.clearFilters();
    } else {
      applyFilters();
    }
  }

  Box get _favBox => Hive.box(AppConstants.favoritesBox);

  @override
  void onInit() {
    super.onInit();
    _loadFavorites();
    bootstrap();
  }

  void _loadFavorites() {
    final raw = _favBox.get('ids');
    if (raw is List) {
      favorites.addAll(raw.map((e) => e.toString()));
    }
  }

  Future<void> bootstrap() async {
    isLoading.value = true;
    _seedDefaultBodyParts();

    final repo = _repository;
    if (repo == null) {
      _applyLiveCounts();
      isLoading.value = false;
      return;
    }

    try {
      final cached = await repo.loadFromCacheOnly();
      if (cached.isNotEmpty) {
        exercises.assignAll(cached);
        applyFilters();
        _applyLiveCounts();
        isLoading.value = false;
      }
    } catch (_) {}

    try {
      final first = await repo.fetchFirstPage(limit: 80);
      if (first.isNotEmpty) {
        if (exercises.length < first.length) {
          exercises.assignAll(first);
        } else {
          final have = exercises.map((e) => e.id).toSet();
          final extra = first.where((e) => !have.contains(e.id)).toList();
          if (extra.isNotEmpty) exercises.addAll(extra);
        }
        applyFilters();
        _applyLiveCounts();
        isLoading.value = false;
      }
    } catch (e) {
      debugPrint('first page: $e');
    } finally {
      if (exercises.isNotEmpty) isLoading.value = false;
    }

    Future(() async {
      try {
        final all = await repo.loadAllCachedOrRemote();
        if (all.isNotEmpty) {
          exercises.assignAll(all);
          applyFilters();
          _applyLiveCounts();
        }
        await _loadMeta();
      } catch (e) {
        debugPrint('background load: $e');
        _applyLiveCounts();
      } finally {
        isLoading.value = false;
        _applyLiveCounts();
      }
    });
  }

  void _loadMetaLocal() {
    final counts = <String, int>{};
    for (final e in exercises) {
      counts[e.bodyPart] = (counts[e.bodyPart] ?? 0) + 1;
    }
    if (bodyParts.isEmpty && counts.isNotEmpty) {
      bodyParts.assignAll(counts.entries
          .map((e) => BodyPartInfo(
                slug: e.key,
                label: e.key,
                emoji: '💪',
                colorHex: '#FF6B35',
                count: e.value,
              ))
          .toList()
        ..sort((a, b) => b.count.compareTo(a.count)));
    }
    if (exercises.isNotEmpty) applyFilters();
  }

  Future<void> _loadMeta() async {
    final repo = _repository;
    if (repo == null) {
      _loadMetaLocal();
      return;
    }
    try {
      final parts = await repo.fetchBodyParts();
      bodyParts.assignAll(parts);
    } catch (_) {
      final counts = <String, int>{};
      for (final e in exercises) {
        counts[e.bodyPart] = (counts[e.bodyPart] ?? 0) + 1;
      }
      bodyParts.assignAll(counts.entries
          .map((e) => BodyPartInfo(
                slug: e.key,
                label: e.key,
                emoji: '💪',
                colorHex: '#FF6B35',
                count: e.value,
              ))
          .toList()
        ..sort((a, b) => b.count.compareTo(a.count)));
    }

    try {
      equipment.assignAll(await repo.fetchEquipment());
    } catch (_) {
      final counts = <String, int>{};
      for (final e in exercises) {
        counts[e.equipment] = (counts[e.equipment] ?? 0) + 1;
      }
      equipment.assignAll(counts.entries
          .map((e) => EquipmentInfo(
                slug: e.key,
                label: e.key,
                icon: 'fitness_center',
                count: e.value,
              ))
          .toList()
        ..sort((a, b) => b.count.compareTo(a.count)));
    }

    try {
      targets.assignAll(await repo.fetchTargets());
    } catch (_) {
      final set = exercises
          .map((e) => e.target)
          .where((t) => t.isNotEmpty)
          .toSet();
      targets.assignAll(set.toList()..sort());
    }
  }

  @override
  Future<void> refresh() async {
    isRefreshing.value = true;
    try {
      final repo = _repository;
      if (repo == null) return;
      await repo.refreshCache();
      exercises.assignAll(await repo.loadAllCachedOrRemote());
      applyFilters();
      await _loadMeta();
    } finally {
      isRefreshing.value = false;
    }
  }

  void onSearchChanged(String value) {
    searchQuery.value = value.trim();
    applyFilters();
  }

  void setBodyPart(String? value) {
    selectedBodyPart.value = value;
    applyFilters();
  }

  void setEquipment(String? value) {
    selectedEquipment.value = value;
    applyFilters();
  }

  void setTarget(String? value) {
    selectedTarget.value = value;
    applyFilters();
  }

  void clearFilters() {
    // If Train section is locked, only clear search — keep section-only list.
    if (isSectionLocked) {
      searchQuery.value = '';
      selectedTarget.value = null;
      applyFilters();
      return;
    }
    searchQuery.value = '';
    selectedBodyPart.value = null;
    selectedEquipment.value = null;
    selectedTarget.value = null;
    applyFilters();
  }

  void applyFilters() {
    final q = searchQuery.value.trim().toLowerCase();
    final lockedParts =
        lockedBodyParts.map((e) => e.toLowerCase()).toSet();
    final lockedEq = lockedEquipment.value?.toLowerCase();
    final bp = selectedBodyPart.value?.toLowerCase();
    final eq = selectedEquipment.value?.toLowerCase();
    final tg = selectedTarget.value?.toLowerCase();

    final list = exercises.where((e) {
      final body = e.bodyPart.toLowerCase();
      final equip = e.equipment.toLowerCase();
      final target = e.target.toLowerCase();
      final muscle = e.muscleGroup.toLowerCase();
      final name = e.name.toLowerCase();

      // Train section lock — never show exercises outside the section.
      if (lockedParts.isNotEmpty && !lockedParts.contains(body)) {
        return false;
      }
      if (lockedEq != null && lockedEq.isNotEmpty && equip != lockedEq) {
        return false;
      }
      if (lockedParts.isEmpty && bp != null && bp.isNotEmpty && body != bp) {
        return false;
      }
      if (lockedEq == null && eq != null && eq.isNotEmpty && equip != eq) {
        return false;
      }
      if (tg != null && tg.isNotEmpty && target != tg) return false;
      if (q.isEmpty) return true;
      return name.contains(q) ||
          equip.contains(q) ||
          target.contains(q) ||
          muscle.contains(q) ||
          body.contains(q);
    }).toList();

    filtered.assignAll(list);
    // Keep list long enough for instant scroll after first paint.
    if (scrollLimit.value < 60) scrollLimit.value = 60;
  }

  List<Exercise> get visibleFiltered {
    final seen = <String>{};
    final out = <Exercise>[];
    for (final e in filtered) {
      if (!seen.add(e.id)) continue; // unique Hero tags
      out.add(e);
      if (out.length >= scrollLimit.value) break;
    }
    return out;
  }

  bool hasMore(List visible) =>
      scrollLimit.value < filtered.length ||
      (exercises.length < 200 && _repository != null);

  Future<void> loadMore() async {
    if (isLoadingMore.value) return;
    if (scrollLimit.value >= filtered.length) {
      // Try pull more from network once near the end.
      if (exercises.length < 200 && _repository != null) {
        isLoadingMore.value = true;
        try {
          final more = await _repository!.fetchFirstPage(limit: 200);
          if (more.isNotEmpty) {
            final have = exercises.map((e) => e.id).toSet();
            final extra = more.where((e) => !have.contains(e.id)).toList();
            if (extra.isNotEmpty) {
              exercises.addAll(extra);
              applyFilters();
              _applyLiveCounts();
            }
          }
        } catch (_) {}
        isLoadingMore.value = false;
      }
      return;
    }
    isLoadingMore.value = true;
    // Simulated small delay so shimmer is visible on fast devices.
    await Future<void>.delayed(const Duration(milliseconds: 180));
    scrollLimit.value += 60;
    isLoadingMore.value = false;
  }

  List<Exercise> byBodyPart(String bodyPart) =>
      exercises.where((e) => e.bodyPart == bodyPart).toList();

  bool isFavorite(String id) => favorites.contains(id);

  void toggleFavorite(String id) {
    if (favorites.contains(id)) {
      favorites.remove(id);
    } else {
      favorites.add(id);
    }
    _favBox.put('ids', favorites.toList());
  }

  List<Exercise> get favoriteExercises =>
      exercises.where((e) => favorites.contains(e.id)).toList();

  List<Exercise> popularExercises({int take = 8}) {
    final preferred = ['barbell', 'dumbbell', 'body weight', 'cable'];
    final list = <Exercise>[];
    for (final eq in preferred) {
      final match = exercises
          .where((e) =>
              e.equipment == eq &&
              e.target.isNotEmpty &&
              !list.any((x) => x.id == e.id))
          .take(2);
      list.addAll(match);
      if (list.length >= take) break;
    }
    if (list.length < take) {
      list.addAll(exercises.take(take - list.length));
    }
    return list.take(take).toList();
  }
}
