import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/constants.dart';
import '../models/exercise.dart';
import '../models/workout.dart';
import '../repositories/exercise_repository.dart';

class WorkoutController extends GetxController {
  late final ExerciseRepository? _repo = () {
    try {
      return ExerciseRepository(Supabase.instance.client);
    } catch (_) {
      return null;
    }
  }();

  final templates = <WorkoutTemplate>[].obs;
  final savedWorkouts = <WorkoutDraft>[].obs;
  final sessions = <WorkoutSessionRecord>[].obs;
  final draft = Rxn<WorkoutDraft>();
  final isLoading = true.obs;

  Box get _workoutsBox => Hive.box(AppConstants.workoutsBox);
  Box get _sessionsBox => Hive.box(AppConstants.sessionsBox);

  bool _boxOpen(String name) {
    try {
      return Hive.isBoxOpen(name);
    } catch (_) {
      return false;
    }
  }

  @override
  void onInit() {
    super.onInit();
    try {
      _loadLocal();
    } catch (e) {
      debugPrint('WorkoutController local load: $e');
    }
    bootstrap();
  }

  void _loadLocal() {
    if (_boxOpen(AppConstants.workoutsBox)) {
      final rawW = _workoutsBox.get('list');
      if (rawW is List) {
        savedWorkouts.assignAll(rawW
            .map((e) =>
                WorkoutDraft.fromMap((e as Map).cast<String, dynamic>()))
            .toList());
      }
    }
    if (_boxOpen(AppConstants.sessionsBox)) {
      final rawS = _sessionsBox.get('list');
      if (rawS is List) {
        sessions.assignAll(rawS
            .map((e) => WorkoutSessionRecord.fromMap(
                (e as Map).cast<String, dynamic>()))
            .toList()
          ..sort((a, b) => b.endedAt.compareTo(a.endedAt)));
      }
    }
  }

  Future<void> bootstrap() async {
    isLoading.value = true;
    try {
      final repo = _repo;
      if (repo == null) {
        if (templates.isEmpty) templates.assignAll(_fallbackTemplates());
        isLoading.value = false;
        return;
      }
      templates.assignAll(await repo.fetchTemplates());
      if (templates.isEmpty) {
        templates.assignAll(_fallbackTemplates());
      }
    } catch (_) {
      if (templates.isEmpty) {
        templates.assignAll(_fallbackTemplates());
      }
    } finally {
      isLoading.value = false;
    }
  }

  List<WorkoutTemplate> _fallbackTemplates() => const [
        WorkoutTemplate(
          id: 't_sixpack',
          slug: 'sixpack',
          name: 'For Six Packs',
          description: 'Abs & waist moves',
          focus: 'abs',
          level: 'beginner',
          estimatedMinutes: 25,
          accentColor: '#F59E0B',
          items: [],
        ),
        WorkoutTemplate(
          id: 't_arms',
          slug: 'arms',
          name: 'For Hand Muscles',
          description: 'Biceps & triceps',
          focus: 'arms',
          level: 'beginner',
          estimatedMinutes: 30,
          accentColor: '#8B5CF6',
          items: [],
        ),
        WorkoutTemplate(
          id: 't_chest',
          slug: 'chest',
          name: 'For Chest Muscles',
          description: 'Push for a bigger chest',
          focus: 'chest',
          level: 'beginner',
          estimatedMinutes: 30,
          accentColor: '#FF6B35',
          items: [],
        ),
        WorkoutTemplate(
          id: 't_legs',
          slug: 'legs',
          name: 'For Legs',
          description: 'Strong legs day',
          focus: 'legs',
          level: 'beginner',
          estimatedMinutes: 30,
          accentColor: '#34D399',
          items: [],
        ),
        WorkoutTemplate(
          id: 't_fullbody',
          slug: 'fullbody',
          name: 'Whole Body Workout',
          description: 'Good for busy days',
          focus: 'full',
          level: 'beginner',
          estimatedMinutes: 35,
          accentColor: '#0EA5E9',
          items: [],
        ),
        WorkoutTemplate(
          id: 't_fatburn',
          slug: 'fatburn',
          name: 'Burn Belly Fat',
          description: 'Cardio & sweat',
          focus: 'cardio',
          level: 'beginner',
          estimatedMinutes: 20,
          accentColor: '#EF4444',
          items: [],
        ),
        WorkoutTemplate(
          id: 't_beginner',
          slug: 'beginner',
          name: 'I Am New — Easy Start',
          description: 'Bodyweight, no gym gear',
          focus: 'full',
          level: 'beginner',
          estimatedMinutes: 20,
          accentColor: '#22C55E',
          items: [],
        ),
      ];

  Future<void> saveDraft(WorkoutDraft value) async {
    draft.value = value;
    final idx = savedWorkouts.indexWhere((e) => e.id == value.id);
    if (idx >= 0) {
      savedWorkouts[idx] = value;
    } else {
      savedWorkouts.insert(0, value);
    }
    await _persistWorkouts();
  }

  Future<void> deleteWorkout(String id) async {
    savedWorkouts.removeWhere((e) => e.id == id);
    await _persistWorkouts();
  }

  Future<void> _persistWorkouts() async {
    await _workoutsBox.put(
      'list',
      savedWorkouts.map((e) => e.toMap()).toList(),
    );
  }

  Future<void> addSession(WorkoutSessionRecord record) async {
    sessions.insert(0, record);
    await _sessionsBox.put(
      'list',
      sessions.map((e) => e.toMap()).toList(),
    );
  }

  WorkoutDraft draftFromTemplate(WorkoutTemplate template) {
    return template.items.isEmpty
        ? WorkoutDraft(
            name: template.name,
            description: template.description,
            templateSlug: template.slug,
          )
        : template.toDraft();
  }

  WorkoutItem itemFromExercise(
    Exercise e, {
    int sets = 3,
    int reps = 10,
    int rest = 60,
  }) {
    return WorkoutItem(
      exerciseId: e.id,
      exerciseName: e.name,
      bodyPart: e.bodyPart,
      equipment: e.equipment,
      thumbnailUrl: e.thumbnailUrl,
      targetSets: sets,
      targetReps: reps,
      restSeconds: rest,
    );
  }

  double get weeklyVolume {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    return sessions
        .where((s) => s.endedAt.isAfter(weekAgo))
        .fold<double>(0, (s, e) => s + e.totalVolume);
  }

  int get weeklySessions {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    return sessions.where((s) => s.endedAt.isAfter(weekAgo)).length;
  }

  int get weeklySets {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    return sessions
        .where((s) => s.endedAt.isAfter(weekAgo))
        .fold<int>(0, (s, e) => s + e.totalSets);
  }

  List<double> volumeLast7Days() {
    final out = List<double>.filled(7, 0);
    final now = DateTime.now();
    for (final s in sessions) {
      final d = s.endedAt;
      final diff = now.difference(DateTime(d.year, d.month, d.day)).inDays;
      if (diff >= 0 && diff < 7) {
        out[6 - diff] += s.totalVolume;
      }
    }
    return out;
  }
}
