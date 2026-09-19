import 'package:equatable/equatable.dart';

class FoodGoal extends Equatable {
  const FoodGoal({
    required this.slug,
    required this.label,
    required this.emoji,
    required this.colorHex,
    this.sortOrder = 0,
  });

  final String slug;
  final String label;
  final String emoji;
  final String colorHex;
  final int sortOrder;

  factory FoodGoal.fromMap(Map<String, dynamic> map) => FoodGoal(
        slug: map['slug']?.toString() ?? '',
        label: map['label']?.toString() ?? '',
        emoji: map['emoji']?.toString() ?? '🍎',
        colorHex: map['color_hex']?.toString() ?? '#C8F542',
        sortOrder: (map['sort_order'] as num?)?.toInt() ?? 0,
      );

  @override
  List<Object?> get props => [slug];
}

class FoodNutrient extends Equatable {
  const FoodNutrient({
    required this.name,
    required this.amount,
    required this.unit,
    this.dailyValue,
  });

  final String name;
  final num amount;
  final String unit;
  final num? dailyValue;

  String get display {
    final amt = amount % 1 == 0 ? amount.toInt() : amount;
    final dv = dailyValue;
    final dvText =
        dv != null && dv > 0 ? ' (${dv.toStringAsFixed(0)}% DV)' : '';
    return '$amt$unit$dvText';
  }

  @override
  List<Object?> get props => [name, amount, unit];
}

class FoodItem extends Equatable {
  const FoodItem({
    required this.id,
    required this.name,
    required this.goalSlug,
    required this.why,
    required this.keyNutrients,
    required this.dailyAmount,
    required this.fdcQuery,
    required this.spoonQuery,
    required this.emoji,
    this.imageUrl,
    this.nutrients = const [],
  });

  final String id;
  final String name;
  final String goalSlug;
  final String why;
  final List<String> keyNutrients;
  final String dailyAmount;
  final String fdcQuery;
  final String spoonQuery;
  final String emoji;
  final String? imageUrl;
  final List<FoodNutrient> nutrients;

  factory FoodItem.fromMap(Map<String, dynamic> map) => FoodItem(
        id: map['id']?.toString() ?? '',
        name: map['name']?.toString() ?? '',
        goalSlug: map['goal_slug']?.toString() ?? '',
        why: map['why']?.toString() ?? '',
        keyNutrients: (map['key_nutrients'] as List?)
                ?.map((e) => e.toString())
                .toList() ??
            const [],
        dailyAmount: map['daily_amount']?.toString() ?? '',
        fdcQuery: map['fdc_query']?.toString() ?? map['name']?.toString() ?? '',
        spoonQuery:
            map['spoon_query']?.toString() ?? map['name']?.toString() ?? '',
        emoji: map['emoji']?.toString() ?? '🍎',
        imageUrl: map['image_url'] as String?,
      );

  FoodItem copyWith({
    String? imageUrl,
    List<FoodNutrient>? nutrients,
  }) {
    return FoodItem(
      id: id,
      name: name,
      goalSlug: goalSlug,
      why: why,
      keyNutrients: keyNutrients,
      dailyAmount: dailyAmount,
      fdcQuery: fdcQuery,
      spoonQuery: spoonQuery,
      emoji: emoji,
      imageUrl: imageUrl ?? this.imageUrl,
      nutrients: nutrients ?? this.nutrients,
    );
  }

  @override
  List<Object?> get props => [id, name, goalSlug];
}
