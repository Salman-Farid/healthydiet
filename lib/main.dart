import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app/routes.dart';
import 'app/theme.dart';
import 'core/constants.dart';
import 'data/providers/exercise_controller.dart';
import 'data/providers/food_controller.dart';
import 'data/providers/settings_controller.dart';
import 'data/providers/trainer_profile_controller.dart';
import 'data/providers/workout_controller.dart';
import 'services/food_notification_service.dart';
import 'ui/home/home_shell.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
    ),
  );

  // Hive first — fail-safe so UI can still show if a box fails.
  try {
    await Hive.initFlutter();
    for (final name in [
      AppConstants.settingsBox,
      AppConstants.cacheBox,
      AppConstants.favoritesBox,
      AppConstants.workoutsBox,
      AppConstants.sessionsBox,
      AppConstants.trainerBox,
    ]) {
      if (!Hive.isBoxOpen(name)) {
        await Hive.openBox(name);
      }
    }
  } catch (e) {
    debugPrint('Hive init: $e');
  }

  // Supabase is optional at boot — cache-first UI still works offline.
  try {
    await Supabase.initialize(
      url: AppConstants.supabaseUrl,
      publishableKey: AppConstants.supabaseAnonKey,
    ).timeout(const Duration(seconds: 6));
  } catch (e) {
    debugPrint('Supabase init: $e');
  }

  Get.put(SettingsController(), permanent: true);
  Get.put(TrainerProfileController(), permanent: true);
  Get.put(ExerciseController(), permanent: true);
  Get.put(WorkoutController(), permanent: true);
  Get.put(FoodController(), permanent: true);

  // Daily 9:00 food tip — permission once on first install, then auto-schedule.
  // Runs after first frame so the system dialog is not blocked by startup.
  WidgetsBinding.instance.addPostFrameCallback((_) {
    FoodNotificationService.bootOnLaunch();
  });

  runApp(const FitForgeApp());
}

class FitForgeApp extends StatelessWidget {
  const FitForgeApp({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Get.find<SettingsController>();
    return ScreenUtilInit(
      designSize: const Size(390, 844),
      minTextAdapt: true,
      builder: (context, child) {
        return Obx(() {
          return GetMaterialApp(
            title: 'FitBook 2026',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light(lang: settings.language.value),
            // Splash is only a brand flash — then straight to exercises.
            home: const _BrandSplash(),
            getPages: AppRoutes.pages,
            defaultTransition: Transition.fadeIn,
            transitionDuration: const Duration(milliseconds: 160),
          );
        });
      },
    );
  }
}

class _BrandSplash extends StatefulWidget {
  const _BrandSplash();

  @override
  State<_BrandSplash> createState() => _BrandSplashState();
}

class _BrandSplashState extends State<_BrandSplash> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future<void>.delayed(const Duration(milliseconds: 220), () {
        if (!mounted) return;
        Get.offAll(() => const HomeShell());
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Text('🏋️', style: TextStyle(fontSize: 48)),
      ),
    );
  }
}
