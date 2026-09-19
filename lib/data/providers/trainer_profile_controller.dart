import 'package:get/get.dart';
import 'package:hive/hive.dart';

import '../../core/constants.dart';

/// Height stored in cm; UI asks feet + inches (common noob preference).
class TrainerProfileController extends GetxController {
  final heightCm = 0.0.obs;
  final weightKg = 0.0.obs;
  final age = 0.obs;
  final sex = 'unknown'.obs;
  final goal = 'general'.obs;
  final level = 'beginner'.obs;
  final isSetupDone = false.obs;

  Box get _box => Hive.box(AppConstants.trainerBox);

  @override
  void onInit() {
    super.onInit();
    _load();
  }

  void _load() {
    heightCm.value = (_box.get('heightCm') as num?)?.toDouble() ?? 0;
    weightKg.value = (_box.get('weightKg') as num?)?.toDouble() ?? 0;
    age.value = (_box.get('age') as num?)?.toInt() ?? 0;
    sex.value = _box.get('sex')?.toString() ?? 'unknown';
    goal.value = _box.get('goal')?.toString() ?? 'general';
    level.value = _box.get('level')?.toString() ?? 'beginner';
    isSetupDone.value = _box.get('setupDone') == true && heightCm.value > 0;
  }

  /// feet + inches → cm (1 ft = 30.48, 1 in = 2.54)
  static double feetInchesToCm(num feet, num inches) =>
      (feet * 30.48) + (inches * 2.54);

  static double cmToFeet(double cm) => cm / 30.48;

  /// [feet] whole feet, [inches] remainder inches.
  ({int feet, int inches}) get heightFeetInches {
    if (heightCm.value <= 0) return (feet: 0, inches: 0);
    final totalIn = heightCm.value / 2.54;
    var ft = (totalIn / 12).floor();
    var inch = (totalIn - ft * 12).round();
    if (inch >= 12) {
      ft += 1;
      inch = 0;
    }
    return (feet: ft, inches: inch);
  }

  String get heightFeetInchesLabel {
    final h = heightFeetInches;
    return '${h.feet}′ ${h.inches}″';
  }

  Future<void> save({
    double? height,
    double? heightFeet,
    double? heightInches,
    double? weight,
    int? ageYears,
    String? sexValue,
    String? goalValue,
    String? levelValue,
  }) async {
    if (height != null) {
      heightCm.value = height;
    } else if (heightFeet != null || heightInches != null) {
      heightCm.value = feetInchesToCm(
        heightFeet ?? heightFeetInches.feet,
        heightInches ?? heightFeetInches.inches,
      );
    }
    if (weight != null) weightKg.value = weight;
    if (ageYears != null) age.value = ageYears;
    if (sexValue != null) sex.value = sexValue;
    if (goalValue != null) goal.value = goalValue;
    if (levelValue != null) level.value = levelValue;
    await _box.put('heightCm', heightCm.value);
    await _box.put('weightKg', weightKg.value);
    await _box.put('age', age.value);
    await _box.put('sex', sex.value);
    await _box.put('goal', goal.value);
    await _box.put('level', level.value);
    isSetupDone.value = heightCm.value > 0 && weightKg.value > 0;
    await _box.put('setupDone', isSetupDone.value);
  }

  double? get bmi {
    if (heightCm.value < 50 || weightKg.value < 10) return null;
    final m = heightCm.value / 100;
    return weightKg.value / (m * m);
  }

  String get goalTitle =>
      AppConstants.goals[goal.value]?['title'] ?? 'Feel Strong';
  String get goalEmoji => AppConstants.goals[goal.value]?['emoji'] ?? '💪';
  String get goalHint =>
      AppConstants.goals[goal.value]?['hint'] ?? 'Normal training';

  Map<String, dynamic> toJson() => {
        'height_cm': heightCm.value,
        'height_ft_in': heightFeetInchesLabel,
        'height_feet': heightFeetInches.feet,
        'height_inches': heightFeetInches.inches,
        'weight_kg': weightKg.value,
        'age': age.value,
        'sex': sex.value,
        'goal': goal.value,
        'level': level.value,
        'bmi': bmi,
        'setup_done': isSetupDone.value,
      };

  String coachSummary() {
    if (!isSetupDone.value) {
      return 'Profile incomplete. Ask height in feet/inches, weight in kg, age, then goal.';
    }
    final bmiVal = bmi;
    final h = heightFeetInches;
    return 'User: ${h.feet} ft ${h.inches} in (${heightCm.value.toStringAsFixed(0)} cm), '
        '${weightKg.value.toStringAsFixed(1)} kg, age ${age.value}, '
        'goal=$goalTitle, level=${level.value}'
        '${bmiVal != null ? ', BMI≈${bmiVal.toStringAsFixed(1)}' : ''}.';
  }
}
