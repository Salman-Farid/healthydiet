import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/food_api_keys.dart';
import '../models/food.dart';

class FoodRepository {
  FoodRepository(this._client);

  final SupabaseClient _client;
  final _imageCache = <String, String?>{};
  final _nutrientCache = <String, List<FoodNutrient>>{};

  static const _usdaBase = 'https://api.nal.usda.gov/fdc/v1';
  static const _spoonBase = 'https://api.spoonacular.com';

  Future<List<FoodGoal>> fetchGoals() async {
    final rows = await _client.from('food_goals').select().order('sort_order');
    return rows
        .map((e) => FoodGoal.fromMap((e as Map).cast<String, dynamic>()))
        .toList();
  }

  Future<List<FoodItem>> fetchFoods({String? goalSlug}) async {
    var q = _client.from('foods').select();
    if (goalSlug != null && goalSlug.isNotEmpty) {
      q = q.eq('goal_slug', goalSlug);
    }
    final rows = await q.order('sort_order', ascending: true).order('name');
    return rows
        .map((e) => FoodItem.fromMap((e as Map).cast<String, dynamic>()))
        .toList();
  }

  /// Real food photo: DB URL first, then TheMealDB ingredient CDN.
  Future<String?> imageUrlFor(FoodItem food) async {
    final cached = _imageCache[food.id];
    if (cached != null) return cached;

    final dbUrl = food.imageUrl;
    if (dbUrl != null &&
        dbUrl.startsWith('http') &&
        !dbUrl.contains('source.unsplash.com')) {
      _imageCache[food.id] = dbUrl;
      return dbUrl;
    }

    final mealDb = _mealDbIngredientUrl(food);
    if (mealDb != null) {
      _imageCache[food.id] = mealDb;
      return mealDb;
    }
    final meal = await _mealDbImage(food);
    if (meal != null) {
      _imageCache[food.id] = meal;
      return meal;
    }
    final spoon = await _spoonImage(food);
    if (spoon != null) {
      _imageCache[food.id] = spoon;
      return spoon;
    }
    _imageCache[food.id] = null;
    return null;
  }

  /// TheMealDB free ingredient photo pattern (real product-style photos).
  String? _mealDbIngredientUrl(FoodItem food) {
    final candidates = <String>[
      food.name,
      food.spoonQuery,
      food.name.replaceAll(RegExp(r'^the\s+', caseSensitive: false), ''),
    ];
    for (final raw in candidates) {
      if (raw.isEmpty) continue;
      final encoded = Uri.encodeComponent(raw.trim());
      return 'https://www.themealdb.com/images/ingredients/$encoded.png';
    }
    return null;
  }

  Future<String?> _spoonImage(FoodItem food) async {
    final q = Uri.encodeComponent(
        food.spoonQuery.isEmpty ? food.name : food.spoonQuery);
    try {
      final resp = await http.get(Uri.parse(
              '$_spoonBase/food/ingredients/search?query=$q&number=1&apiKey=${FoodApiKeys.spoonacular}'))
          .timeout(const Duration(seconds: 8));
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
        final results =
            (data is Map ? data['results'] as List? : null) ?? const [];
        if (results.isNotEmpty) {
          final image = results.first['image']?.toString();
          if (image != null && image.isNotEmpty) {
            return image.startsWith('http')
                ? image
                : 'https://spoonacular.com/cdn/ingredients_250x250/$image';
          }
        }
      }
    } catch (_) {}
    return null;
  }

  Future<String?> _mealDbImage(FoodItem food) async {
    final q = Uri.encodeComponent(
        food.spoonQuery.isEmpty ? food.name : food.spoonQuery);
    try {
      final resp = await http.get(
        Uri.parse('https://www.themealdb.com/api/json/v1/1/search.php?s=$q'),
      ).timeout(const Duration(seconds: 6));
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
        final meals =
            (data is Map ? data['meals'] as List? : null) ?? const [];
        if (meals.isNotEmpty) {
          final img = meals.first['strMealThumb']?.toString();
          if (img != null && img.isNotEmpty) return img;
        }
      }
    } catch (_) {}
    return null;
  }

  Future<List<FoodNutrient>> nutrientsFor(FoodItem food) async {
    final cached = _nutrientCache[food.id];
    if (cached != null && cached.isNotEmpty) return cached;

    final query = Uri.encodeComponent(
        food.fdcQuery.isEmpty ? food.name : food.fdcQuery);
    const wanted = {
      'Energy': 'kcal',
      'Protein': 'g',
      'Total lipid (fat)': 'g',
      'Carbohydrate, by difference': 'g',
      'Fiber, total dietary': 'g',
      'Calcium, Ca': 'mg',
      'Iron, Fe': 'mg',
      'Magnesium, Mg': 'mg',
      'Potassium, K': 'mg',
      'Zinc, Zn': 'mg',
      'Vitamin A, RAE': 'µg',
      'Vitamin C, total ascorbic acid': 'mg',
      'Vitamin D (D2 + D3)': 'µg',
      'Vitamin E (alpha-tocopherol)': 'mg',
      'Vitamin K (phylloquinone)': 'µg',
      'Folate, total': 'µg',
      'Choline, total': 'mg',
    };

    try {
      final resp = await http.get(Uri.parse(
              '$_usdaBase/foods/search?query=$query&pageSize=1&api_key=${FoodApiKeys.usda}'))
          .timeout(const Duration(seconds: 10));
      if (resp.statusCode != 200) {
        _nutrientCache[food.id] = const [];
        return const [];
      }
      final data = jsonDecode(resp.body) as Map<String, dynamic>;
      final foods = (data['foods'] as List?) ?? const [];
      if (foods.isEmpty) {
        _nutrientCache[food.id] = const [];
        return const [];
      }
      final nutrients = (foods.first['foodNutrients'] as List?) ?? const [];
      final out = <FoodNutrient>[];
      for (final n in nutrients) {
        final map = (n as Map).cast<String, dynamic>();
        final name = (map['nutrientName'] ?? map['nutrient'] ?? '').toString();
        if (!wanted.containsKey(name)) continue;
        final amount = (map['value'] as num?) ?? (map['amount'] as num?) ?? 0;
        var unit = (map['unitName'] ?? wanted[name] ?? '').toString();
        if (unit.isEmpty) unit = wanted[name] ?? '';
        out.add(FoodNutrient(
          name: name,
          amount: amount,
          unit: unit,
          dailyValue: map['dailyValue'] as num?,
        ));
      }
      out.sort((a, b) {
        if (a.name == 'Protein') return -1;
        if (b.name == 'Protein') return 1;
        return a.name.compareTo(b.name);
      });
      _nutrientCache[food.id] = out;
      return out;
    } catch (_) {
      _nutrientCache[food.id] = const [];
      return const [];
    }
  }
}
