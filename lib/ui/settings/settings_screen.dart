import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/constants.dart';
import '../../core/l10n.dart';
import '../../data/providers/settings_controller.dart';
import '../../data/providers/trainer_profile_controller.dart';
import '../../services/food_notification_service.dart';
import '../widgets/common.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Get.find<SettingsController>();
    final profile = Get.find<TrainerProfileController>();
    final lang = settings.language.value;
    String t(String key) => AppStrings.get(lang, key);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: Text(t('settings'))),
      body: Obx(() {
        final current = settings.language.value;
        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 128),
          children: [
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(t('language'),
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: kInstructionLanguages.entries.map((e) {
                      final selected = current == e.key;
                      return ChoiceChip(
                        selected: selected,
                        onSelected: (_) => settings.setLanguage(e.key),
                        label: Text(
                            '${kLanguageFlags[e.key] ?? ''} ${e.value}'),
                        selectedColor: AppColors.primarySoft,
                        side: BorderSide(
                          color: selected
                              ? AppColors.primary
                              : AppColors.border,
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(t('goal'),
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text(
                    '${profile.goalEmoji} ${profile.goalTitle}',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: AppConstants.goals.entries.map((e) {
                      final selected = profile.goal.value == e.key;
                      return ChoiceChip(
                        selected: selected,
                        onSelected: (_) => profile.save(goalValue: e.key),
                        label: Text(
                            '${e.value['emoji']} ${e.value['title']}'),
                        selectedColor: AppColors.primarySoft,
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            GlassCard(
              child: Column(
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(t('height_cm')),
                    subtitle: Text(
                      '${profile.heightFeetInchesLabel}  ·  ${profile.heightCm.value.toStringAsFixed(0)} cm',
                    ),
                    trailing: const Icon(Icons.height, color: AppColors.muted),
                  ),
                  const Divider(color: AppColors.border),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(t('weight_kg')),
                    subtitle: Text(
                        '${profile.weightKg.value.toStringAsFixed(1)} kg'),
                    trailing:
                        const Icon(Icons.monitor_weight, color: AppColors.muted),
                  ),
                  const Divider(color: AppColors.border),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(t('age')),
                    subtitle: Text('${profile.age.value}'),
                    trailing:
                        const Icon(Icons.cake, color: AppColors.muted),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    t('daily_food_tip'),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    t('daily_food_tip_hint'),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 14),
                  // Obvious test button — send a notification right now.
                  FilledButton.icon(
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onPressed: () async {
                      final ok = await FoodNotificationService.showTestTip();
                      if (!context.mounted) return;
                      final msg = ok
                          ? t('test_notification_sent')
                          : t('notif_need_rebuild');
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(msg),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    icon: const Icon(Icons.notifications_active_rounded),
                    label: Text(
                      t('tap_send_notification'),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () async {
                      await FoodNotificationService.init();
                      await FoodNotificationService.scheduleDaily(
                          hour: 9, minute: 0);
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(t('tips_scheduled'))),
                      );
                    },
                    child: Text(t('schedule_9am')),
                  ),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }
}
