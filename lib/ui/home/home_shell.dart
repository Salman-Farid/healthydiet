import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';

import '../../core/l10n.dart';
import '../../data/providers/exercise_controller.dart';
import '../../data/providers/settings_controller.dart';
import '../exercises/exercise_library_screen.dart';
import '../favorites/favorites_screen.dart';
import '../foods/food_library_screen.dart';
import '../settings/settings_screen.dart';
import '../train/train_screen.dart';

/// Tabs: Exercises · Train · Foods · Favourites · Settings
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  void _onTab(int i) {
    if (_index != 0 && i == 0) {
      if (Get.isRegistered<ExerciseController>()) {
        Get.find<ExerciseController>().unlockSection();
      }
    }
    setState(() => _index = i);
  }

  @override
  Widget build(BuildContext context) {
    final lang = Get.find<SettingsController>().language.value;
    String t(String key) => AppStrings.get(lang, key);

    // IndexedStack keeps every tab mounted → duplicate Hero tags crash.
    // HeroMode(enabled) only registers heroes for the ACTIVE tab.
    final screens = [
      HeroMode(enabled: _index == 0, child: const ExerciseLibraryScreen()),
      HeroMode(enabled: _index == 1, child: const WorkoutListScreen()),
      HeroMode(enabled: _index == 2, child: const FoodLibraryScreen()),
      HeroMode(enabled: _index == 3, child: const FavoritesScreen()),
      HeroMode(enabled: _index == 4, child: const SettingsScreen()),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      body: IndexedStack(index: _index, children: screens),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Color(0xFFE8E8E8))),
        ),
        child: SafeArea(
          child: SalomonBottomBar(
            currentIndex: _index,
            margin: const EdgeInsets.fromLTRB(8, 4, 8, 8),
            itemPadding:
                const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
            selectedItemColor: const Color(0xFFFF6B35),
            unselectedItemColor: const Color(0xFF6B7385),
            onTap: _onTab,
            items: [
              SalomonBottomBarItem(
                icon: const Icon(Icons.fitness_center_rounded),
                title:
                    Text(t('exercises'), style: const TextStyle(fontSize: 12)),
              ),
              SalomonBottomBarItem(
                icon: const Icon(Icons.directions_run_rounded),
                title: Text(t('train'), style: const TextStyle(fontSize: 12)),
              ),
              SalomonBottomBarItem(
                icon: const Icon(Icons.restaurant_rounded),
                title: Text(t('foods'), style: const TextStyle(fontSize: 12)),
              ),
              SalomonBottomBarItem(
                icon: const Icon(Icons.favorite_rounded),
                title: Text(t('favourites'),
                    style: const TextStyle(fontSize: 12)),
              ),
              SalomonBottomBarItem(
                icon: const Icon(Icons.settings_rounded),
                title:
                    Text(t('settings'), style: const TextStyle(fontSize: 12)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
