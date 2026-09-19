import 'dart:convert';

import 'package:hive/hive.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/constants.dart';
import '../models/exercise.dart';
import '../models/workout.dart';

class ExerciseRepository {
  ExerciseRepository(this._client);

  final SupabaseClient _client;
  final _cache = Hive.box(AppConstants.cacheBox);

  static const _cacheKey = 'exercises_v1';
  static const _templatesKey = 'templates_v1';

  /// Light columns for instant first paint (no instruction blobs).
  static const _lightSelect =
      'id,name,category,body_part,equipment,target,muscle_group,media_id,image_path,gif_path,secondary_muscles,attribution';

  /// Fast first screen — small page, light fields only.
  Future<List<Exercise>> fetchFirstPage({int limit = 60}) async {
    final rows = await _client
        .from('exercises')
        .select(_lightSelect)
        .order('name', ascending: true)
        .limit(limit);
    return rows
        .map((e) => Exercise.fromMap((e as Map).cast<String, dynamic>()))
        .toList();
  }

  /// Hive cache only — no network.
  Future<List<Exercise>> loadFromCacheOnly() async {
    try {
      final cached = _cache.get(_cacheKey);
      if (cached is! String || cached.isEmpty) return const [];
      final list = (jsonDecode(cached) as List)
          .map((e) => Exercise.fromMap((e as Map).cast<String, dynamic>()))
          .toList();
      return list;
    } catch (_) {
      return const [];
    }
  }

  Future<List<Exercise>> fetchExercises({
    String? query,
    String? bodyPart,
    String? equipment,
    String? target,
    int limit = 500,
    int offset = 0,
  }) async {
    var q = _client.from('exercises').select(_lightSelect);
    if (bodyPart != null && bodyPart.isNotEmpty) {
      q = q.eq('body_part', bodyPart);
    }
    if (equipment != null && equipment.isNotEmpty) {
      q = q.eq('equipment', equipment);
    }
    if (target != null && target.isNotEmpty) {
      q = q.eq('target', target);
    }
    if (query != null && query.trim().isNotEmpty) {
      // Case-insensitive ILIKE search on the server.
      final safe = query
          .trim()
          .replaceAll('%', '')
          .replaceAll(',', ' ')
          .replaceAll("'", '');
      q = q.or(
        'name.ilike.%$safe%,target.ilike.%$safe%,equipment.ilike.%$safe%,muscle_group.ilike.%$safe%',
      );
    }

    final rows = await q
        .order('name', ascending: true)
        .range(offset, offset + limit - 1);

    return rows
        .map((e) => Exercise.fromMap((e as Map).cast<String, dynamic>()))
        .toList();
  }

  Future<List<Exercise>> loadAllCachedOrRemote() async {
    // Prefer cache first for callers that want the full set.
    final cached = await loadFromCacheOnly();
    if (cached.isNotEmpty) return cached;

    final all = <Exercise>[];
    // Full column set only when hydrating cache (needed for instructions).
    const pageSize = 200;
    var offset = 0;
    while (true) {
      final rows = await _client
          .from('exercises')
          .select()
          .order('name', ascending: true)
          .range(offset, offset + pageSize - 1);
      final page = rows
          .map((e) => Exercise.fromMap((e as Map).cast<String, dynamic>()))
          .toList();
      all.addAll(page);
      if (page.length < pageSize) break;
      offset += pageSize;
      if (offset > 5000) break;
    }

    await _cache.put(
      _cacheKey,
      jsonEncode(all.map((e) => e.toMap()).toList()),
    );
    return all;
  }

  Future<void> refreshCache() async {
    await _cache.delete(_cacheKey);
    await loadAllCachedOrRemote();
  }

  Future<List<BodyPartInfo>> fetchBodyParts() async {
    final rows = await _client.from('body_parts').select().order('sort_order');
    final counts = <String, int>{};
    try {
      final agg = await _client.from('exercises').select('body_part').limit(5000);
      for (final r in agg) {
        final p = r['body_part']?.toString() ?? '';
        counts[p] = (counts[p] ?? 0) + 1;
      }
    } catch (_) {}

    return rows.map((e) {
      final map = (e as Map).cast<String, dynamic>();
      map['count'] = counts[map['slug']?.toString()] ?? 0;
      return BodyPartInfo.fromMap(map);
    }).toList();
  }

  Future<List<EquipmentInfo>> fetchEquipment() async {
    final rows =
        await _client.from('equipment_types').select().order('sort_order');
    return rows
        .map((e) => EquipmentInfo.fromMap((e as Map).cast<String, dynamic>()))
        .toList();
  }

  Future<List<WorkoutTemplate>> fetchTemplates() async {
    try {
      final tplRows = await _client
          .from('workout_templates')
          .select()
          .order('sort_order', ascending: true);
      final itemRows = await _client
          .from('workout_template_exercises')
          .select('*, exercises(*)')
          .order('position', ascending: true);

      final byTemplate = <String, List<WorkoutItem>>{};
      for (final row in itemRows) {
        final map = (row as Map).cast<String, dynamic>();
        final tid = map['template_id']?.toString() ?? '';
        final ex = map['exercises'];
        if (ex is! Map) continue;
        final exercise = Exercise.fromMap(ex.cast<String, dynamic>());
        byTemplate.putIfAbsent(tid, () => []).add(
              WorkoutItem(
                exerciseId: exercise.id,
                exerciseName: exercise.name,
                bodyPart: exercise.bodyPart,
                equipment: exercise.equipment,
                thumbnailUrl: exercise.thumbnailUrl,
                targetSets: (map['default_sets'] as num?)?.toInt() ?? 3,
                targetReps: (map['default_reps'] as num?)?.toInt() ?? 10,
                restSeconds:
                    (map['default_rest_seconds'] as num?)?.toInt() ?? 60,
              ),
            );
      }

      final templates = tplRows.map((e) {
        final map = (e as Map).cast<String, dynamic>();
        return WorkoutTemplate.fromMap(
          map,
          items: byTemplate[map['id']?.toString()] ?? const [],
        );
      }).toList();

      await _cache.put(
        _templatesKey,
        jsonEncode(templates
            .map((t) => {
                  ...t.toDraft().toMap(),
                  'slug': t.slug,
                  'focus': t.focus,
                  'level': t.level,
                  'estimatedMinutes': t.estimatedMinutes,
                  'accentColor': t.accentColor,
                  'id': t.id,
                  'description': t.description,
                })
            .toList()),
      );
      return templates;
    } catch (_) {
      final cached = _cache.get(_templatesKey);
      if (cached is String) {
        try {
          return (jsonDecode(cached) as List).map((e) {
            final map = (e as Map).cast<String, dynamic>();
            final draft = WorkoutDraft.fromMap(map);
            return WorkoutTemplate(
              id: map['id']?.toString() ?? draft.id,
              slug: map['slug']?.toString() ?? draft.templateSlug ?? '',
              name: draft.name,
              description: draft.description,
              focus: map['focus']?.toString() ?? '',
              level: map['level']?.toString() ?? 'beginner',
              estimatedMinutes:
                  (map['estimatedMinutes'] as num?)?.toInt() ?? 40,
              accentColor: map['accentColor']?.toString() ?? '#C8F542',
              items: draft.items,
            );
          }).toList();
        } catch (_) {
          return const [];
        }
      }
      return const [];
    }
  }

  Future<List<String>> fetchTargets() async {
    final rows = await _client.from('exercises').select('target').limit(2000);
    final set = <String>{};
    for (final r in rows) {
      final t = r['target']?.toString();
      if (t != null && t.isNotEmpty) set.add(t);
    }
    return set.toList()..sort();
  }
}
