import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/food.dart';
import '../repositories/food_repository.dart';

enum FoodSort { name, protein, fiber, vitaminC }

class FoodController extends GetxController {
  FoodRepository? _repo;

  FoodRepository? get _repository {
    if (_repo != null) return _repo;
    try {
      _repo = FoodRepository(Supabase.instance.client);
      return _repo;
    } catch (_) {
      return null;
    }
  }

  final goals = <FoodGoal>[].obs;
  final foods = <FoodItem>[].obs;
  final filtered = <FoodItem>[].obs;
  final isLoading = true.obs;
  final selectedGoal = RxnString();
  final searchQuery = ''.obs;
  final sort = FoodSort.name.obs;

  /// Heart first, then Skin — then the rest.
  static const _fallbackGoals = <FoodGoal>[
    FoodGoal(slug: 'heart', label: 'Heart', emoji: '❤️', colorHex: '#EF4444', sortOrder: 1),
    FoodGoal(slug: 'skin', label: 'Skin', emoji: '✨', colorHex: '#F472B6', sortOrder: 2),
    FoodGoal(slug: 'eye', label: 'Eye', emoji: '👁️', colorHex: '#0EA5E9', sortOrder: 3),
    FoodGoal(slug: 'brain', label: 'Brain', emoji: '🧠', colorHex: '#A78BFA', sortOrder: 4),
    FoodGoal(slug: 'bones', label: 'Bones', emoji: '🦴', colorHex: '#F59E0B', sortOrder: 5),
    FoodGoal(slug: 'immunity', label: 'Immunity', emoji: '🛡️', colorHex: '#22C55E', sortOrder: 6),
    FoodGoal(slug: 'energy', label: 'Energy', emoji: '⚡', colorHex: '#FBBF24', sortOrder: 7),
    FoodGoal(slug: 'muscle', label: 'Muscle', emoji: '💪', colorHex: '#8B5CF6', sortOrder: 8),
    FoodGoal(slug: 'digestion', label: 'Digestion', emoji: '🌿', colorHex: '#34D399', sortOrder: 9),
    FoodGoal(slug: 'hair', label: 'Hair', emoji: '💇', colorHex: '#60A5FA', sortOrder: 10),
  ];

  @override
  void onInit() {
    super.onInit();
    bootstrap();
  }

  Future<void> bootstrap() async {
    isLoading.value = true;
    try {
      final repo = _repository;
      if (repo != null) {
        var g = await repo.fetchGoals();
        // Force chip order: heart, skin first
        g.sort((a, b) {
          const order = [
            'heart',
            'skin',
            'eye',
            'brain',
            'bones',
            'immunity',
            'energy',
            'muscle',
            'digestion',
            'hair',
          ];
          final ai = order.indexOf(a.slug);
          final bi = order.indexOf(b.slug);
          if (ai >= 0 && bi >= 0) return ai.compareTo(bi);
          if (ai >= 0) return -1;
          if (bi >= 0) return 1;
          return a.sortOrder.compareTo(b.sortOrder);
        });
        goals.assignAll(g);
        foods.assignAll(await repo.fetchFoods());
      }
      if (goals.isEmpty) goals.assignAll(_fallbackGoals);
      applyFilters();
      // Load real images in background (do not block UI).
      unawaitedEnrichVisible();
    } catch (_) {
      if (goals.isEmpty) goals.assignAll(_fallbackGoals);
      applyFilters();
    } finally {
      isLoading.value = false;
    }
  }

  void unawaitedEnrichVisible() {
    // Enrich AFTER the current frame so Obx is never rebuilt mid-build.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final list = filtered.toList();
      for (final f in list) {
        if (f.imageUrl != null && f.imageUrl!.isNotEmpty) continue;
        enrich(f);
      }
    });
  }

  /// Loads USDA / image data. Never mutates Rx lists synchronously.
  Future<FoodItem> enrich(FoodItem food) async {
    final repo = _repository;
    if (repo == null) return food;
    var updated = food;
    if (updated.imageUrl == null || updated.imageUrl!.isEmpty) {
      final img = await repo.imageUrlFor(food);
      if (img != null) updated = updated.copyWith(imageUrl: img);
    }
    if (updated.nutrients.isEmpty) {
      final nutrients = await repo.nutrientsFor(food);
      if (nutrients.isNotEmpty) {
        updated = updated.copyWith(nutrients: nutrients);
      }
    }

    final idx = foods.indexWhere((e) => e.id == food.id);
    if (idx >= 0) {
      final changed = updated.imageUrl != food.imageUrl ||
          updated.nutrients.length != food.nutrients.length;
      if (changed) {
        // Defer GetX notify until after build/layout.
        scheduleMicrotask(() {
          final i = foods.indexWhere((e) => e.id == food.id);
          if (i >= 0) {
            foods[i] = updated;
            // Do NOT applyFilters() here — that rebuilds the grid under a live Hero.
          }
        });
      }
    }
    return updated;
  }

  void setGoal(String? slug) {
    selectedGoal.value = slug;
    applyFilters();
    unawaitedEnrichVisible();
  }

  void onSearchChanged(String value) {
    searchQuery.value = value.trim();
    applyFilters();
  }

  void setSort(FoodSort value) {
    sort.value = value;
    applyFilters();
  }

  void clearFilters() {
    selectedGoal.value = null;
    searchQuery.value = '';
    sort.value = FoodSort.name;
    applyFilters();
  }

  bool _matchesQuery(FoodItem f, String qLower) {
    if (qLower.isEmpty) return true;
    if (f.name.toLowerCase().contains(qLower)) return true;
    if (f.why.toLowerCase().contains(qLower)) return true;
    if (f.dailyAmount.toLowerCase().contains(qLower)) return true;
    if (f.goalSlug.toLowerCase().contains(qLower)) return true;
    for (final n in f.keyNutrients) {
      if (n.toLowerCase().contains(qLower)) return true;
    }
    return false;
  }

  void applyFilters() {
    final q = searchQuery.value.trim().toLowerCase();
    final goal = selectedGoal.value?.toLowerCase();

    final seen = <String>{};
    final list = <FoodItem>[];
    for (final f in foods) {
      if (goal != null &&
          goal.isNotEmpty &&
          f.goalSlug.toLowerCase() != goal) {
        continue;
      }
      if (!_matchesQuery(f, q)) continue;
      final key = '${f.goalSlug}|${f.name.toLowerCase().trim()}';
      if (!seen.add(key)) continue;
      list.add(f);
    }

    switch (sort.value) {
      case FoodSort.name:
        list.sort(
            (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
      case FoodSort.protein:
        list.sort((a, b) => _nutrientScore(b, 'Protein')
            .compareTo(_nutrientScore(a, 'Protein')));
      case FoodSort.fiber:
        list.sort((a, b) =>
            _nutrientScore(b, 'fiber').compareTo(_nutrientScore(a, 'fiber')));
      case FoodSort.vitaminC:
        list.sort((a, b) => _nutrientScore(b, 'vitamin c')
            .compareTo(_nutrientScore(a, 'vitamin c')));
    }
    filtered.assignAll(list);
  }

  double _nutrientScore(FoodItem f, String keyHint) {
    for (final n in f.nutrients) {
      if (n.name.toLowerCase().contains(keyHint.toLowerCase())) {
        return n.amount.toDouble();
      }
    }
    final hit = f.keyNutrients
        .any((k) => k.toLowerCase().contains(keyHint.toLowerCase()));
    return hit ? 1 : 0;
  }

  FoodGoal? goalFor(String slug) {
    for (final g in goals) {
      if (g.slug == slug) return g;
    }
    return null;
  }
}
