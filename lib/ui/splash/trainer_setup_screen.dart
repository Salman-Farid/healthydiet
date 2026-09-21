import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/routes.dart';
import '../../core/constants.dart';
import '../../core/l10n.dart';
import '../../data/providers/settings_controller.dart';
import '../../data/providers/trainer_profile_controller.dart';

/// Game-like setup: height (ft/in) → weight → age → goal.
class TrainerSetupScreen extends StatefulWidget {
  const TrainerSetupScreen({super.key});

  @override
  State<TrainerSetupScreen> createState() => _TrainerSetupScreenState();
}

class _TrainerSetupScreenState extends State<TrainerSetupScreen> {
  final profile = Get.find<TrainerProfileController>();
  final settings = Get.find<SettingsController>();
  int _step = 0;

  final _feetCtrl = TextEditingController();
  final _inchesCtrl = TextEditingController();
  final _weightCtrl = TextEditingController();
  final _ageCtrl = TextEditingController();

  String t(String key) => AppStrings.get(settings.language.value, key);

  @override
  void initState() {
    super.initState();
    final h = profile.heightFeetInches;
    if (h.feet > 0) _feetCtrl.text = '${h.feet}';
    if (h.inches > 0 || h.feet > 0) _inchesCtrl.text = '${h.inches}';
    if (profile.weightKg.value > 0) {
      _weightCtrl.text = profile.weightKg.value.toStringAsFixed(0);
    }
    if (profile.age.value > 0) _ageCtrl.text = '${profile.age.value}';
  }

  @override
  void dispose() {
    _feetCtrl.dispose();
    _inchesCtrl.dispose();
    _weightCtrl.dispose();
    _ageCtrl.dispose();
    super.dispose();
  }

  Future<void> _next() async {
    if (_step == 0) {
      final ft = int.tryParse(_feetCtrl.text.trim()) ?? 0;
      final inch = int.tryParse(_inchesCtrl.text.trim()) ?? 0;
      if (ft < 3 || ft > 8) {
        Get.snackbar('Hmm', 'Feet should be 3–8',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: AppColors.surface,
            colorText: AppColors.ink);
        return;
      }
      if (inch < 0 || inch > 11) {
        Get.snackbar('Hmm', 'Inches should be 0–11',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: AppColors.surface,
            colorText: AppColors.ink);
        return;
      }
      await profile.save(heightFeet: ft.toDouble(), heightInches: inch.toDouble());
    } else if (_step == 1) {
      final w = double.tryParse(_weightCtrl.text.trim()) ?? 0;
      if (w < 25 || w > 300) {
        Get.snackbar('Hmm', 'Weight in kg (25–300)',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: AppColors.surface,
            colorText: AppColors.ink);
        return;
      }
      await profile.save(weight: w);
    } else if (_step == 2) {
      final a = int.tryParse(_ageCtrl.text.trim()) ?? 0;
      if (a < 10 || a > 100) {
        Get.snackbar('Hmm', 'Enter your age',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: AppColors.surface,
            colorText: AppColors.ink);
        return;
      }
      await profile.save(ageYears: a);
    } else if (_step == 3) {
      await profile.save();
      await settings.completeOnboarding();
      Get.offAllNamed(AppRoutes.home);
      return;
    }
    setState(() => _step++);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(t('coach'),
                      style: Theme.of(context).textTheme.headlineMedium),
                  const Spacer(),
                  Text('Step ${_step + 1}/4',
                      style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(99),
                child: LinearProgressIndicator(
                  value: (_step + 1) / 4,
                  minHeight: 8,
                  backgroundColor: AppColors.surfaceAlt,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 24),
              Expanded(child: _buildStep(context)),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _next,
                  child: Text(_step == 3 ? t('lets_train') : t('next')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStep(BuildContext context) {
    switch (_step) {
      case 0:
        return Column(
          key: const ValueKey(0),
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('📏', style: TextStyle(fontSize: 44)),
            const SizedBox(height: 12),
            Text(t('height_cm'),
                style: Theme.of(context).textTheme.displayMedium),
            const SizedBox(height: 8),
            Text('Example: 5 feet 8 inches',
                style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _feetCtrl,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: t('height_ft'),
                      hintText: '5',
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _inchesCtrl,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: t('height_in'),
                      hintText: '8',
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      case 1:
        return Column(
          key: const ValueKey(1),
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('⚖️', style: TextStyle(fontSize: 44)),
            const SizedBox(height: 12),
            Text(t('weight_kg'),
                style: Theme.of(context).textTheme.displayMedium),
            const SizedBox(height: 20),
            TextField(
              controller: _weightCtrl,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: t('weight_kg'),
                hintText: '70',
              ),
            ),
          ],
        );
      case 2:
        return Column(
          key: const ValueKey(2),
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('🎂', style: TextStyle(fontSize: 44)),
            const SizedBox(height: 12),
            Text(t('age'), style: Theme.of(context).textTheme.displayMedium),
            const SizedBox(height: 20),
            TextField(
              controller: _ageCtrl,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: t('age'), hintText: '25'),
            ),
          ],
        );
      default:
        return Column(
          key: const ValueKey(3),
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('🎯', style: TextStyle(fontSize: 44)),
            const SizedBox(height: 12),
            Text(t('pick_quest'),
                style: Theme.of(context).textTheme.displayMedium),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.05,
                children: AppConstants.goals.entries.map((e) {
                  final selected = profile.goal.value == e.key;
                  final color = AppColors.forGoal(e.key);
                  return GestureDetector(
                    onTap: () => setState(() => profile.goal.value = e.key),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color:
                            selected
                                ? color.withValues(alpha: 0.15)
                                : AppColors.surface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: selected ? color : AppColors.border,
                          width: selected ? 2 : 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(e.value['emoji'] ?? '💪',
                              style: const TextStyle(fontSize: 28)),
                          const Spacer(),
                          Text(e.value['title'] ?? e.key,
                              style: Theme.of(context).textTheme.titleMedium),
                          Text(e.value['hint'] ?? '',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(fontSize: 11)),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        );
    }
  }
}
