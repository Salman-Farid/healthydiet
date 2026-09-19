import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';

class WorkoutItem extends Equatable {
  const WorkoutItem({
    required this.exerciseId,
    required this.exerciseName,
    required this.bodyPart,
    required this.equipment,
    required this.thumbnailUrl,
    this.targetSets = 3,
    this.targetReps = 10,
    this.restSeconds = 60,
    this.targetWeight = 0,
  });

  final String exerciseId;
  final String exerciseName;
  final String bodyPart;
  final String equipment;
  final String thumbnailUrl;
  final int targetSets;
  final int targetReps;
  final int restSeconds;
  final double targetWeight;

  WorkoutItem copyWith({
    int? targetSets,
    int? targetReps,
    int? restSeconds,
    double? targetWeight,
  }) {
    return WorkoutItem(
      exerciseId: exerciseId,
      exerciseName: exerciseName,
      bodyPart: bodyPart,
      equipment: equipment,
      thumbnailUrl: thumbnailUrl,
      targetSets: targetSets ?? this.targetSets,
      targetReps: targetReps ?? this.targetReps,
      restSeconds: restSeconds ?? this.restSeconds,
      targetWeight: targetWeight ?? this.targetWeight,
    );
  }

  Map<String, dynamic> toMap() => {
        'exerciseId': exerciseId,
        'exerciseName': exerciseName,
        'bodyPart': bodyPart,
        'equipment': equipment,
        'thumbnailUrl': thumbnailUrl,
        'targetSets': targetSets,
        'targetReps': targetReps,
        'restSeconds': restSeconds,
        'targetWeight': targetWeight,
      };

  factory WorkoutItem.fromMap(Map<String, dynamic> map) => WorkoutItem(
        exerciseId: map['exerciseId']?.toString() ?? '',
        exerciseName: map['exerciseName']?.toString() ?? '',
        bodyPart: map['bodyPart']?.toString() ?? '',
        equipment: map['equipment']?.toString() ?? '',
        thumbnailUrl: map['thumbnailUrl']?.toString() ?? '',
        targetSets: (map['targetSets'] as num?)?.toInt() ?? 3,
        targetReps: (map['targetReps'] as num?)?.toInt() ?? 10,
        restSeconds: (map['restSeconds'] as num?)?.toInt() ?? 60,
        targetWeight: (map['targetWeight'] as num?)?.toDouble() ?? 0,
      );

  @override
  List<Object?> get props => [exerciseId, targetSets, targetReps];
}

class WorkoutDraft extends Equatable {
  WorkoutDraft({
    String? id,
    required this.name,
    this.description = '',
    this.items = const [],
    this.templateSlug,
  }) : id = id ?? const Uuid().v4();

  final String id;
  final String name;
  final String description;
  final List<WorkoutItem> items;
  final String? templateSlug;

  factory WorkoutDraft.empty() =>
      WorkoutDraft(name: 'Custom Workout', description: '');

  factory WorkoutDraft.fromMap(Map<String, dynamic> map) {
    final rawItems = (map['items'] as List?) ?? const [];
    return WorkoutDraft(
      id: map['id']?.toString(),
      name: map['name']?.toString() ?? 'Workout',
      description: map['description']?.toString() ?? '',
      templateSlug: map['templateSlug']?.toString(),
      items: rawItems
          .map((e) => WorkoutItem.fromMap((e as Map).cast<String, dynamic>()))
          .toList(),
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'description': description,
        'templateSlug': templateSlug,
        'items': items.map((e) => e.toMap()).toList(),
      };

  WorkoutDraft copyWith({
    String? name,
    String? description,
    List<WorkoutItem>? items,
    String? templateSlug,
  }) {
    return WorkoutDraft(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      items: items ?? this.items,
      templateSlug: templateSlug ?? this.templateSlug,
    );
  }

  int get totalSets => items.fold(0, (s, e) => s + e.targetSets);
  int get estimatedMinutes =>
      items.isEmpty ? 0 : (items.length * 8 + totalSets * 2).clamp(10, 90);

  @override
  List<Object?> get props => [id, name, items.length];
}

class WorkoutTemplate extends Equatable {
  const WorkoutTemplate({
    required this.id,
    required this.slug,
    required this.name,
    required this.description,
    required this.focus,
    required this.level,
    required this.estimatedMinutes,
    required this.accentColor,
    required this.items,
  });

  final String id;
  final String slug;
  final String name;
  final String description;
  final String focus;
  final String level;
  final int estimatedMinutes;
  final String accentColor;
  final List<WorkoutItem> items;

  factory WorkoutTemplate.fromMap(
    Map<String, dynamic> map, {
    List<WorkoutItem> items = const [],
  }) {
    return WorkoutTemplate(
      id: map['id']?.toString() ?? '',
      slug: map['slug']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      description: map['description']?.toString() ?? '',
      focus: map['focus']?.toString() ?? '',
      level: map['level']?.toString() ?? 'intermediate',
      estimatedMinutes: (map['estimated_minutes'] as num?)?.toInt() ?? 45,
      accentColor: map['accent_color']?.toString() ?? '#C8F542',
      items: items,
    );
  }

  WorkoutDraft toDraft() => WorkoutDraft(
        name: name,
        description: description,
        templateSlug: slug,
        items: items,
      );

  @override
  List<Object?> get props => [id, slug];
}

class SetLog extends Equatable {
  const SetLog({
    required this.exerciseId,
    required this.exerciseName,
    required this.setIndex,
    required this.weight,
    required this.reps,
  });

  final String exerciseId;
  final String exerciseName;
  final int setIndex;
  final double weight;
  final int reps;

  double get volume => weight * reps;

  Map<String, dynamic> toMap() => {
        'exerciseId': exerciseId,
        'exerciseName': exerciseName,
        'setIndex': setIndex,
        'weight': weight,
        'reps': reps,
      };

  factory SetLog.fromMap(Map<String, dynamic> map) => SetLog(
        exerciseId: map['exerciseId']?.toString() ?? '',
        exerciseName: map['exerciseName']?.toString() ?? '',
        setIndex: (map['setIndex'] as num?)?.toInt() ?? 0,
        weight: (map['weight'] as num?)?.toDouble() ?? 0,
        reps: (map['reps'] as num?)?.toInt() ?? 0,
      );

  @override
  List<Object?> get props => [exerciseId, setIndex, weight, reps];
}

class WorkoutSessionRecord extends Equatable {
  const WorkoutSessionRecord({
    required this.id,
    required this.workoutName,
    required this.startedAt,
    required this.endedAt,
    required this.durationSeconds,
    required this.sets,
  });

  final String id;
  final String workoutName;
  final DateTime startedAt;
  final DateTime endedAt;
  final int durationSeconds;
  final List<SetLog> sets;

  int get totalReps => sets.fold(0, (s, e) => s + e.reps);
  double get totalVolume => sets.fold(0, (s, e) => s + e.volume);
  int get totalSets => sets.length;

  Map<String, dynamic> toMap() => {
        'id': id,
        'workoutName': workoutName,
        'startedAt': startedAt.toIso8601String(),
        'endedAt': endedAt.toIso8601String(),
        'durationSeconds': durationSeconds,
        'sets': sets.map((e) => e.toMap()).toList(),
      };

  factory WorkoutSessionRecord.fromMap(Map<String, dynamic> map) {
    final rawSets = (map['sets'] as List?) ?? const [];
    return WorkoutSessionRecord(
      id: map['id']?.toString() ?? '',
      workoutName: map['workoutName']?.toString() ?? 'Workout',
      startedAt:
          DateTime.tryParse(map['startedAt']?.toString() ?? '') ?? DateTime.now(),
      endedAt:
          DateTime.tryParse(map['endedAt']?.toString() ?? '') ?? DateTime.now(),
      durationSeconds: (map['durationSeconds'] as num?)?.toInt() ?? 0,
      sets: rawSets
          .map((e) => SetLog.fromMap((e as Map).cast<String, dynamic>()))
          .toList(),
    );
  }

  @override
  List<Object?> get props => [id];
}
