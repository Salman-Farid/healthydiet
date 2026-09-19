import 'dart:ui';

class AppConstants {
  AppConstants._();

  static const supabaseUrl = 'https://ghhelxjabukfuoxiwqaj.supabase.co';
  static const supabaseAnonKey =
      'sb_publishable_GZUlylQcqRBcoL-xjJsqjA_XliR_Kpg';

  static const mediaCdnBase =
      'https://cdn.jsdelivr.net/gh/hasaneyldrm/exercises-dataset@main';

  static const settingsBox = 'settings';
  static const cacheBox = 'exercise_cache';
  static const favoritesBox = 'favorites';
  static const workoutsBox = 'workouts';
  static const sessionsBox = 'sessions';
  static const trainerBox = 'trainer_profile';

  static const attribution = '© Gym visual — https://gymvisual.com/';
  static const datasetUrl =
      'https://github.com/hasaneyldrm/exercises-dataset';

  /// Goals the coach asks about — simple, game-like language.
  /// What a beginner would ask a trainer — simple goal cards.
  static const goals = <String, Map<String, String>>{
    'general': {
      'emoji': '💪',
      'title': 'Feel Strong',
      'hint': 'Normal training',
    },
    'sixpack': {
      'emoji': '🎯',
      'title': 'For Six Packs',
      'hint': 'Abs & waist',
    },
    'booster': {
      'emoji': '🚀',
      'title': 'Get Super Strong',
      'hint': 'Heavy lifts',
    },
    'fatloss': {
      'emoji': '🔥',
      'title': 'Burn Fat',
      'hint': 'Cardio & sweat',
    },
    'muscle': {
      'emoji': '🏗️',
      'title': 'Build Muscles',
      'hint': 'Bigger arms / body',
    },
    'beginner': {
      'emoji': '🌱',
      'title': 'I Am New',
      'hint': 'Easy, no gear',
    },
  };

  /// Instruction languages from dataset (no Bengali — dropped).
  static const instructionLanguages = <String, String>{
    'en': 'English',
    'es': 'Español',
    'it': 'Italiano',
    'tr': 'Türkçe',
    'ru': 'Русский',
    'zh': '中文',
    'hi': 'हिन्दी',
    'pl': 'Polski',
    'ko': '한국어',
    'fr': 'Français',
  };

  static const primaryColor = Color(0xFFFF6B35);
  static const errorColor = Color(0xFFEF4444);
  static const warningColor = Color(0xFFF59E0B);
  static const successColor = Color(0xFF22C55E);

  static String mediaUrl(String path) {
    if (path.isEmpty) return '';
    if (path.startsWith('http')) return path;
    return '$mediaCdnBase/$path';
  }
}

/// LIGHT theme tokens — friendly gym-game UI.
class AppColors {
  AppColors._();

  // Background & surfaces — pure white app chrome
  static const background = Color(0xFFFFFFFF);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceAlt = Color(0xFFF5F5F5);
  static const border = Color(0xFFE8E8E8);

  // Ink
  static const ink = Color(0xFF151A24);
  static const muted = Color(0xFF6B7385);

  // Brand — energetic gym game
  static const primary = Color(0xFFFF6B35); // coach orange
  static const primarySoft = Color(0xFFFFEEE6);
  static const volt = Color(0xFF22C55E); // go green
  static const voltSoft = Color(0xFFE8F9EF);
  static const cyan = Color(0xFF0EA5E9);
  static const purple = Color(0xFF8B5CF6);
  static const yellow = Color(0xFFF59E0B);
  static const danger = Color(0xFFEF4444);
  static const success = Color(0xFF16A34A);

  // Legacy aliases used by voice widgets
  static const bgLight = background;
  static const bgDark = background; // force light
  static const surfaceLight = surface;
  static const surfaceDark = surface;
  static const borderLight = border;
  static const borderDark = border;
  static const textPrimaryLight = ink;
  static const textPrimaryDark = ink;
  static const textSecondaryLight = muted;
  static const textSecondaryDark = muted;
  static const textMutedLight = muted;
  static const textMutedDark = muted;

  static const primaryColor = primary;
  static const errorColor = danger;
  static const warningColor = yellow;
  static const successColor = volt;
  static const Color orange = primary;
  // Alias used by older voice widgets
  // ignore: prefer_const_declarations
  static final Color primaryAccent = primary;

  static const bodyPartColors = <String, Color>{
    'chest': Color(0xFFFF6B35),
    'back': Color(0xFF0EA5E9),
    'shoulders': Color(0xFF22C55E),
    'upper arms': Color(0xFF8B5CF6),
    'lower arms': Color(0xFFEC4899),
    'waist': Color(0xFFF59E0B),
    'upper legs': Color(0xFF14B8A6),
    'lower legs': Color(0xFF3B82F6),
    'cardio': Color(0xFFEF4444),
    'neck': Color(0xFF64748B),
  };

  static Color forBodyPart(String part) =>
      bodyPartColors[part.toLowerCase()] ?? primary;

  static Color forGoal(String goal) {
    switch (goal) {
      case 'sixpack':
        return yellow;
      case 'booster':
        return primary;
      case 'fatloss':
        return danger;
      case 'muscle':
        return purple;
      case 'beginner':
        return volt;
      default:
        return cyan;
    }
  }
}
