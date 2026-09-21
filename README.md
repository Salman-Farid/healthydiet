# FitBook 2026

**Gym exercises, food tips & daily nutrition coach** — a cross-platform Flutter app with 1,300+ exercises, 150+ foods with real USDA nutritional data, pre-built workout templates, and a 10-language instruction system.

---

## Screenshots

| Exercises | Train | Foods | Exercise Detail | Food Detail |
|-----------|-------|-------|-----------------|-------------|
| Searchable grid with body part filters | 7 workout templates with exercise counts | Health goal chips with sort options | Hero-animated GIF + multilingual steps | USDA nutrition panel + benefit text |

---

## Features

### Exercise Library (1,300+ exercises)
- Two-column grid with infinite scroll (batches of 60)
- Body part chips with live counts: Chest (163), Back (203), Shoulders (143), Upper Arms (292), Upper Legs (126), Waist (38), Cardio (27), Lower Arms (72), Lower Legs (56), Neck (36), Hips (28)
- Search across name, equipment, target, muscle group, body part
- Equipment filter: barbell, dumbbell, body weight, cable, machine, kettlebell, resistance band, EZ bar, medicine ball, foam roller, smith machine, other
- Hero-animated detail screen with exercise GIF, step-by-step instructions in 10 languages
- Favorite toggle persisted locally via Hive

### Workout Templates (7 programs)
- **Six Pack** — waist-focused core exercises
- **Hand Muscles** — lower arm grip work
- **Chest** — chest compound and isolation
- **Legs** — upper/lower leg mix
- **Full Body** — compound multi-joint
- **Burn Belly Fat** — cardio-heavy sessions
- **Beginner** — bodyweight-only starter plan

Each template shows exercise count and estimated duration. Tapping a template locks the exercise library to only show relevant exercises.

### Food & Nutrition Library (150+ foods)
- 16 health goal categories: Brain, Heart, Lungs, Kidneys, Liver, Bones, Eyes, Teeth & Gums, Blood, Skin, Hair & Scalps, Muscles, Immune System, Stomach, Gut & Intestines, Joints
- Real USDA nutritional data for 17 nutrients: Energy, Protein, Fat, Carbohydrates, Fiber, Calcium, Iron, Magnesium, Potassium, Zinc, Vitamins A/C/D/E/K, Folate, Choline
- Daily value percentage calculations
- Hand-written "Why it helps" benefit text for 20+ specific foods
- Sort by Name, Protein, Fiber, or Vitamin C
- Food images from Spoonacular and TheMealDB CDNs

### Daily Food Tips
- 20 curated food tips cycling over 14 days
- 9 AM local notification with matching food photo
- Photos downloaded, letterboxed to 512x512, and cached on disk
- Test notification button in Settings

### Trainer Profile
- 4-step onboarding: Height (ft/in or cm) → Weight (kg) → Age → Fitness goal
- 6 goal options: Feel Strong, Six Packs, Super Strong, Burn Fat, Build Muscles, I Am New
- BMI calculation
- Profile stored in Hive for offline access

### Settings
- Language picker: English, Espanol, Italiano, Turkce, Russian, Chinese, Hindi, Polski, Korean, Francais
- Goal selection with emoji indicators
- Height/weight/age display
- Daily food tip configuration

---

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Framework | Flutter (Dart SDK ^3.7.0) |
| State Management | GetX |
| Backend | Supabase (PostgreSQL) |
| Local Storage | Hive (6 boxes: settings, exercise_cache, favorites, workouts, sessions, trainer_profile) |
| Preferences | SharedPreferences |
| Fonts | Google Fonts — Space Grotesk (headings) + Inter (body) |
| Images | CachedNetworkImage with Shimmer loading |
| Responsive | flutter_screenutil (390×844 design) |
| Navigation | GetX named routes with Hero animations (650ms ease-in-out-cubic) |
| Notifications | flutter_local_notifications + timezone |
| HTTP | http package for USDA, Spoonacular, TheMealDB APIs |
| IDs | UUID v4 for workout drafts |
| Platforms | Android, iOS, Linux, macOS, Web, Windows |

---

## Project Structure

```
lib/
├── main.dart                          # App entry, GetX binding, splash
├── app/
│   ├── theme.dart                     # Material 3 light theme, orange primary
│   └── routes.dart                    # Named route definitions
├── core/
│   ├── constants.dart                 # Supabase config, CDN URLs, colors, goals
│   ├── l10n.dart                      # 10-language UI translations
│   ├── food_tips.dart                 # 20 daily food tips with coach copy
│   └── food_api_keys.dart             # USDA + Spoonacular API keys
├── data/
│   ├── models/
│   │   ├── exercise.dart              # Exercise, BodyPartInfo, EquipmentInfo
│   │   ├── food.dart                  # FoodItem, FoodGoal, FoodNutrient
│   │   └── workout.dart               # WorkoutDraft, WorkoutTemplate, SetLog, SessionRecord
│   ├── repositories/
│   │   ├── exercise_repository.dart   # Supabase fetch + Hive cache
│   │   └── food_repository.dart       # Food fetch + image resolution + USDA lookup
│   └── providers/
│       ├── exercise_controller.dart   # Exercise filtering, search, favorites, section lock
│       ├── food_controller.dart       # Food filtering, sort, lazy enrichment
│       ├── workout_controller.dart    # Templates, drafts, session records, weekly stats
│       ├── settings_controller.dart   # Language, units, onboarding state
│       └── trainer_profile_controller.dart  # Profile, BMI, coach summary
├── services/
│   └── food_notification_service.dart # 9 AM daily food tip scheduling
├── ui/
│   ├── splash/
│   │   ├── splash_screen.dart         # Animated brand flash
│   │   └── trainer_setup_screen.dart  # 4-step onboarding wizard
│   ├── exercises/
│   │   ├── exercise_library_screen.dart  # Grid + search + body part chips
│   │   └── exercise_detail_screen.dart   # Hero GIF + multilingual instructions
│   ├── train/
│   │   └── train_screen.dart          # 7 workout template cards
│   ├── foods/
│   │   ├── food_library_screen.dart   # Grid + goal chips + sort
│   │   └── food_detail_screen.dart    # Hero photo + USDA panel + benefits
│   ├── favorites/
│   │   └── favorites_screen.dart      # Favorited exercises grid
│   ├── settings/
│   │   └── settings_screen.dart       # Language, goal, profile, notifications
│   └── widgets/
│       ├── hero_routes.dart           # Custom Hero flight animations
│       └── common.dart               # ExerciseThumb, GlassCard, EmptyState, MuscleChip
```

---

## Database Schema (Supabase)

| Table | Purpose | Access |
|-------|---------|--------|
| `exercises` | 1,300+ exercises with multilingual instructions (JSONB) | Public read |
| `body_parts` | 10 body parts with slug, label, emoji, color | Public read |
| `equipment_types` | 12 equipment types with slug, label, icon | Public read |
| `workout_templates` | 7+ workout plans with focus, level, accent color | Public read |
| `workout_template_exercises` | Junction: templates ↔ exercises (sets, reps, rest) | Public read |
| `profiles` | User profiles linked to auth (display_name, language, weight_unit) | Owner only |
| `workouts` | User-created custom workouts | Owner only |
| `workout_exercises` | Exercises within user workouts | Owner only |
| `workout_sessions` | Completed session records with duration and totals | Owner only |
| `session_sets` | Individual set logs (weight, reps, RPE) | Owner only |
| `favorites` | User's favorited exercises | Owner only |

Row Level Security (RLS) enabled on all tables. Catalog tables are publicly readable; user data tables are owner-only.

---

## External APIs

| API | Purpose |
|-----|---------|
| Supabase | Exercise catalog, body parts, equipment, workout templates, user data |
| USDA FoodData Central | Nutritional data for 17 nutrients per food |
| Spoonacular | Food ingredient images |
| TheMealDB | Food ingredient images (CDN + search fallback) |
| jsDelivr CDN | Exercise thumbnails and GIFs from GitHub dataset |

---

## Localization

Full UI translations in 10 languages:

| Language | Code |
|----------|------|
| English | en |
| Spanish | es |
| Italian | it |
| Turkish | tr |
| Russian | ru |
| Chinese | zh |
| Hindi | hi |
| Polish | pl |
| Korean | ko |
| French | fr |

Covers navigation labels, search hints, exercise instructions, workout template names, body part labels, equipment labels, food goal labels, notification strings, and settings strings.

---

## Getting Started

### Prerequisites
- Flutter SDK ^3.7.0
- Dart SDK ^3.7.0
- Supabase project (for cloud features)

### Installation

```bash
# Clone the repository
git clone https://github.com/your-org/fitbook2026.git
cd fitbook2026

# Install dependencies
flutter pub get

# Run on connected device
flutter run
```

### Configuration

1. **Supabase** — Update `lib/core/constants.dart` with your Supabase URL and anon key
2. **USDA API** — Set your key in `lib/core/food_api_keys.dart`
3. **Spoonacular** — Set your key in `lib/core/food_api_keys.dart`
4. **Notifications** — Configure `android/app/build.gradle` for notification channel

### Build

```bash
# Android release
flutter build apk --release

# iOS release
flutter build ios --release

# Web
flutter build web --release

# Or use the build script
./build_release.sh
```

---

## How It Works

1. **First launch** — Brand splash → 4-step trainer setup (height, weight, age, goal) → Home
2. **Exercise browsing** — Tap body part chips or search → infinite scroll grid → tap card for Hero detail
3. **Workout templates** — Tap a template card → exercise library filters to that body part → browse exercises
4. **Food library** — Tap health goal chips → sort by protein/fiber/vitamin → tap card for USDA nutrition panel
5. **Favorites** — Heart icon on any exercise → persisted in Hive → view in Favourites tab
6. **Daily tips** — 9 AM notification cycles through 20 food tips with photos
7. **Offline** — Exercise catalog and favorites cached in Hive; works without internet after first load

---

## Roadmap

Planned features for upcoming releases:

| Priority | Feature | Impact |
|----------|---------|--------|
| 1 | Habit streak tracking | Retention — users return to maintain streaks |
| 2 | One-tap "Done" exercise logging | Engagement — feels like a workout app |
| 3 | Saved meal plan with day picker | Utility — turns food tips into followable plans |
| 4 | Body metrics history + progress ring | Motivation — visible change drives usage |
| 5 | Offline-first UI polish | Reliability — works in gyms with no signal |
| 6 | Smart search with recent queries | Speed — faster find = more opens |
| 7 | Configurable push reminders | DAU — reminders drive daily opens |
| 8 | Social share cards | Growth — free organic reach |
| 9 | Auth + cloud backup | Multi-device — users stay across phones |
| 10 | Pro polish (icons, crash reporting, rate-us) | Trust — feels like a real product |

---

## License

Private project. All rights reserved.
