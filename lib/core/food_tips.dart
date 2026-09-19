/// Daily 9 AM food tips — coach-style recommendations to the user.
class FoodTip {
  const FoodTip({
    required this.title,
    required this.body,
    required this.imageUrl,
    required this.emoji,
  });

  final String title;
  final String body;
  final String imageUrl;
  final String emoji;
}

class FoodTips {
  FoodTips._();

  /// Copy pattern: Eat/Have/Drink + food + amount/day + "to help your …"
  static const List<FoodTip> daily = [
    FoodTip(
      title: 'Have some walnuts',
      body:
          'Eat some walnuts about 30g/day to help sharpen your memory and keep your brain focused.',
      imageUrl: 'https://www.themealdb.com/images/ingredients/Walnuts.png',
      emoji: '🌰',
    ),
    FoodTip(
      title: 'Eat some avocado',
      body:
          'Have about half an avocado a day to help keep your skin smooth and healthy.',
      imageUrl: 'https://www.themealdb.com/images/ingredients/Avocado.png',
      emoji: '🥑',
    ),
    FoodTip(
      title: 'Eat some carrots',
      body:
          'Have one medium carrot a day to help your night vision and eye health.',
      imageUrl: 'https://www.themealdb.com/images/ingredients/Carrots.png',
      emoji: '🥕',
    ),
    FoodTip(
      title: 'Eat some salmon',
      body:
          'Have salmon about 100g/day (a few times a week) to help your heart rhythm and brain focus.',
      imageUrl: 'https://www.themealdb.com/images/ingredients/Salmon.png',
      emoji: '🐟',
    ),
    FoodTip(
      title: 'Eat some blueberries',
      body:
          'Have one cup of blueberries a day to help feed your brain with antioxidants.',
      imageUrl:
          'https://www.themealdb.com/images/ingredients/Blueberries.png',
      emoji: '🫐',
    ),
    FoodTip(
      title: 'Eat some oats',
      body:
          'Have 40–80g of oats a day to help steady your energy and support your heart.',
      imageUrl: 'https://www.themealdb.com/images/ingredients/Oats.png',
      emoji: '🥣',
    ),
    FoodTip(
      title: 'Eat some spinach',
      body:
          'Have one cup of spinach a day to help your eyes, blood and daily energy.',
      imageUrl: 'https://www.themealdb.com/images/ingredients/Spinach.png',
      emoji: '🥬',
    ),
    FoodTip(
      title: 'Eat some eggs',
      body:
          'Have 1–2 eggs a day to help your muscles recover and your memory stay sharp.',
      imageUrl: 'https://www.themealdb.com/images/ingredients/Eggs.png',
      emoji: '🥚',
    ),
    FoodTip(
      title: 'Eat an orange',
      body:
          'Have one orange a day to help your skin glow and your immune system stay strong.',
      imageUrl: 'https://www.themealdb.com/images/ingredients/Orange.png',
      emoji: '🍊',
    ),
    FoodTip(
      title: 'Eat some yogurt',
      body:
          'Have one cup of yogurt a day to help your gut, bones and after-gym recovery.',
      imageUrl: 'https://www.themealdb.com/images/ingredients/Yogurt.png',
      emoji: '🥣',
    ),
    FoodTip(
      title: 'Eat a banana',
      body:
          'Have one banana before you train to help your energy and muscle cramps.',
      imageUrl: 'https://www.themealdb.com/images/ingredients/Banana.png',
      emoji: '🍌',
    ),
    FoodTip(
      title: 'Eat some chicken breast',
      body:
          'Have 120–200g of chicken breast a day to help your muscles grow after the gym.',
      imageUrl:
          'https://www.themealdb.com/images/ingredients/Chicken%20Breast.png',
      emoji: '🍗',
    ),
    FoodTip(
      title: 'Eat some tomato',
      body:
          'Have one cup of tomato a day to help protect your skin from daily stress.',
      imageUrl: 'https://www.themealdb.com/images/ingredients/Tomato.png',
      emoji: '🍅',
    ),
    FoodTip(
      title: 'Eat some broccoli',
      body:
          'Have one cup of broccoli a day to help your bones and immunity stay strong.',
      imageUrl: 'https://www.themealdb.com/images/ingredients/Broccoli.png',
      emoji: '🥦',
    ),
    FoodTip(
      title: 'Drink some milk',
      body:
          'Drink 1–2 cups of milk a day to help your bones stay strong with calcium.',
      imageUrl: 'https://www.themealdb.com/images/ingredients/Milk.png',
      emoji: '🥛',
    ),
    FoodTip(
      title: 'Eat some almonds',
      body:
          'Have about 25–30g of almonds a day to help your heart with vitamin E.',
      imageUrl: 'https://www.themealdb.com/images/ingredients/Almonds.png',
      emoji: '🥜',
    ),
    FoodTip(
      title: 'Eat some lentils',
      body:
          'Have one cup of lentils a day to help your muscles and keep your digestion easy.',
      imageUrl: 'https://www.themealdb.com/images/ingredients/Lentils.png',
      emoji: '🫘',
    ),
    FoodTip(
      title: 'Drink some water with lemon',
      body:
          'Have half a lemon in water today to help your digestion and daily vitamin C.',
      imageUrl: 'https://www.themealdb.com/images/ingredients/Lemon.png',
      emoji: '🍋',
    ),
    FoodTip(
      title: 'Eat some sweet potato',
      body:
          'Have one medium sweet potato a day to help your eyes and steady your energy.',
      imageUrl:
          'https://images.unsplash.com/photo-1459411552884-841db9b3cc2a?w=400&h=400&fit=crop',
      emoji: '🍠',
    ),
    FoodTip(
      title: 'Eat some cottage cheese',
      body:
          'Have one cup of cottage cheese a day to help your muscles recover while you sleep.',
      imageUrl:
          'https://images.unsplash.com/photo-1559561853-08451507cbe7?w=400&h=400&fit=crop',
      emoji: '🧀',
    ),
  ];

  /// Stable tip per calendar day (cycling through the full list).
  static FoodTip tipForDate(DateTime date) {
    final day = DateTime.utc(date.year, date.month, date.day)
        .difference(DateTime.utc(2020, 1, 1))
        .inDays;
    final len = daily.length;
    if (len == 0) {
      return const FoodTip(
        title: 'Eat some vegetables',
        body: 'Have a serving of vegetables today to help your health.',
        imageUrl: 'https://www.themealdb.com/images/ingredients/Broccoli.png',
        emoji: '🥦',
      );
    }
    var index = day % len;
    if (index < 0) index += len;
    return daily[index];
  }

  /// Tip by cursor (test button — cycles every tap).
  static FoodTip tipAt(int index) {
    final len = daily.length;
    if (len == 0) return tipForDate(DateTime.now());
    var i = index % len;
    if (i < 0) i += len;
    return daily[i];
  }
}
