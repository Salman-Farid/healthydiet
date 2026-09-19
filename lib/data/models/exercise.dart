import 'package:equatable/equatable.dart';

import '../../core/constants.dart';

class Exercise extends Equatable {
  const Exercise({
    required this.id,
    required this.name,
    required this.category,
    required this.bodyPart,
    required this.equipment,
    required this.target,
    required this.muscleGroup,
    required this.secondaryMuscles,
    required this.instructions,
    required this.instructionSteps,
    required this.mediaId,
    required this.imagePath,
    required this.gifPath,
    required this.attribution,
  });

  final String id;
  final String name;
  final String category;
  final String bodyPart;
  final String equipment;
  final String target;
  final String muscleGroup;
  final List<String> secondaryMuscles;
  final Map<String, String> instructions;
  final Map<String, List<String>> instructionSteps;
  final String mediaId;
  final String imagePath;
  final String gifPath;
  final String attribution;

  String get thumbnailUrl => AppConstants.mediaUrl(imagePath);
  String get gifUrl => AppConstants.mediaUrl(gifPath);

  String instructionFor(String lang) {
    return instructions[lang] ??
        instructions['en'] ??
        (instructions.isNotEmpty ? instructions.values.first : '');
  }

  List<String> stepsFor(String lang) {
    return instructionSteps[lang] ??
        instructionSteps['en'] ??
        (instructionSteps.isNotEmpty
            ? instructionSteps.values.first
            : <String>[]);
  }

  factory Exercise.fromMap(Map<String, dynamic> map) {
    final rawInstructions =
        (map['instructions'] as Map?)?.cast<String, dynamic>() ?? {};
    final rawSteps =
        (map['instruction_steps'] as Map?)?.cast<String, dynamic>() ?? {};

    return Exercise(
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      category: map['category']?.toString() ?? '',
      bodyPart: map['body_part']?.toString() ?? map['category']?.toString() ?? '',
      equipment: map['equipment']?.toString() ?? '',
      target: map['target']?.toString() ?? '',
      muscleGroup: map['muscle_group']?.toString() ?? '',
      secondaryMuscles: (map['secondary_muscles'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      instructions: rawInstructions.map(
        (k, v) => MapEntry(k, v?.toString() ?? ''),
      ),
      instructionSteps: rawSteps.map(
        (k, v) => MapEntry(
          k,
          (v as List?)?.map((e) => e.toString()).toList() ?? const [],
        ),
      ),
      mediaId: map['media_id']?.toString() ?? '',
      imagePath: map['image_path']?.toString() ??
          map['image']?.toString() ??
          '',
      gifPath:
          map['gif_path']?.toString() ?? map['gif_url']?.toString() ?? '',
      attribution: map['attribution']?.toString() ?? AppConstants.attribution,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'category': category,
        'body_part': bodyPart,
        'equipment': equipment,
        'target': target,
        'muscle_group': muscleGroup,
        'secondary_muscles': secondaryMuscles,
        'instructions': instructions,
        'instruction_steps': instructionSteps,
        'media_id': mediaId,
        'image_path': imagePath,
        'gif_path': gifPath,
        'attribution': attribution,
      };

  @override
  List<Object?> get props => [id, name, category, equipment, target];
}

class BodyPartInfo extends Equatable {
  const BodyPartInfo({
    required this.slug,
    required this.label,
    required this.emoji,
    required this.colorHex,
    this.count = 0,
  });

  final String slug;
  final String label;
  final String emoji;
  final String colorHex;
  final int count;

  factory BodyPartInfo.fromMap(Map<String, dynamic> map) => BodyPartInfo(
        slug: map['slug']?.toString() ?? '',
        label: map['label']?.toString() ?? '',
        emoji: map['emoji']?.toString() ?? '💪',
        colorHex: map['color_hex']?.toString() ?? '#C8F542',
        count: (map['count'] as num?)?.toInt() ?? 0,
      );

  @override
  List<Object?> get props => [slug];
}

class EquipmentInfo extends Equatable {
  const EquipmentInfo({
    required this.slug,
    required this.label,
    required this.icon,
    this.count = 0,
  });

  final String slug;
  final String label;
  final String icon;
  final int count;

  factory EquipmentInfo.fromMap(Map<String, dynamic> map) => EquipmentInfo(
        slug: map['slug']?.toString() ?? '',
        label: map['label']?.toString() ?? '',
        icon: map['icon']?.toString() ?? 'fitness_center',
        count: (map['count'] as num?)?.toInt() ?? 0,
      );

  @override
  List<Object?> get props => [slug];
}
