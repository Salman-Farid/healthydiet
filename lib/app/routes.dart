import 'package:get/get.dart';

import '../data/models/exercise.dart';
import '../data/models/food.dart';
import '../ui/exercise_detail/exercise_detail_screen.dart';
import '../ui/exercises/exercise_library_screen.dart';
import '../ui/foods/food_detail_screen.dart';
import '../ui/home/home_shell.dart';
import '../ui/splash/trainer_setup_screen.dart';
import '../ui/widgets/hero_routes.dart';

class AppRoutes {
  AppRoutes._();

  static const setup = '/setup';
  static const home = '/home';
  static const library = '/library';
  static const detail = '/exercise';
  static const food = '/food';

  static final pages = <GetPage<dynamic>>[
    GetPage(name: setup, page: () => const TrainerSetupScreen()),
    GetPage(name: home, page: () => const HomeShell()),
    GetPage(name: library, page: () => const ExerciseLibraryScreen()),
    GetPage(
      name: detail,
      transitionDuration: HeroRoutes.duration,
      curve: HeroRoutes.curve,
      page: () {
        final args = Get.arguments;
        if (args is Exercise) return ExerciseDetailScreen(exercise: args);
        if (args is Map && args['exercise'] is Exercise) {
          return ExerciseDetailScreen(
            exercise: args['exercise'] as Exercise,
            initialLanguage: args['language'] as String?,
          );
        }
        return const HomeShell();
      },
    ),
    GetPage(
      name: food,
      transitionDuration: HeroRoutes.duration,
      curve: HeroRoutes.curve,
      page: () {
        final args = Get.arguments;
        if (args is FoodItem) return FoodDetailScreen(food: args);
        return const HomeShell();
      },
    ),
  ];
}
