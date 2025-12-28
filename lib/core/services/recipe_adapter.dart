import '../../data/models/potion.dart';
import '../../data/models/ingredients.dart';
import '../../data/models/mood.dart';

class RecipeAdapter {
  /// Combines fetched recipes with manual drinks if no drinks are present.
  /// Use this after fetching all recipes from TheMealDB.
  static List<Potion> ensureDrinksIncluded(List<Potion> potions) {
    final hasDrinks = potions.any((p) => p.category == PotionCategory.drink);
    if (hasDrinks) return potions;
    // Add manual drinks to the end of the list
    return List<Potion>.from(potions)..addAll(manualDrinks());
  }

  // Converts TheMealDB API data to Potion model
  static Potion fromMealDB(Map<String, dynamic> mealDbJson) {
    // Parse ingredients
    final ingredients = <Ingredient>[];
    for (int i = 1; i <= 20; i++) {
      final ingredient = mealDbJson['strIngredient$i'];
      final measure = mealDbJson['strMeasure$i'];
      if (ingredient != null && ingredient.toString().trim().isNotEmpty) {
        // Try to parse measure into quantity/unit
        double quantity = 0;
        String unit = '';
        if (measure != null && measure.toString().trim().isNotEmpty) {
          final parts = measure.toString().trim().split(' ');
          if (parts.length == 1) {
            // Could be just a number or just a unit
            final numVal = double.tryParse(parts[0]);
            if (numVal != null) {
              quantity = numVal;
            } else {
              unit = parts[0];
            }
          } else if (parts.length > 1) {
            // Try to parse first part as number
            final numVal = double.tryParse(parts[0]);
            if (numVal != null) {
              quantity = numVal;
              unit = parts.sublist(1).join(' ');
            } else {
              // fallback: treat all as unit
              unit = measure.toString().trim();
            }
          }
        }
        ingredients.add(Ingredient(
          id: ingredient,
          name: ingredient,
          quantity: quantity,
          unit: unit,
        ));
      }
    }

    // Parse steps (split instructions by line or period)
    final steps = <BrewingStep>[];
    final instructionsRaw =
        (mealDbJson['strInstructions'] ?? '').split(RegExp(r'[\n\r]+|\. '));
    int stepNum = 1;
    for (final instr in instructionsRaw) {
      final trimmed = instr.trim();
      if (trimmed.isNotEmpty) {
        steps.add(BrewingStep(number: stepNum++, instruction: trimmed));
      }
    }

    // Category mapping: only meal and dessert
    PotionCategory category = PotionCategory.meal;
    final cat = (mealDbJson['strCategory'] ?? '').toString().toLowerCase();
    if (cat.contains('dessert') ||
        cat.contains('sweet') ||
        cat.contains('appetizer')) {
      category = PotionCategory.dessert;
    } else {
      category = PotionCategory.meal;
    }

    // Mood classification based on keywords in name, category, or instructions
    final name = (mealDbJson['strMeal'] ?? '').toString().toLowerCase();
    final instructions =
        (mealDbJson['strInstructions'] ?? '').toString().toLowerCase();
    final moodKeywords = <Mood, List<String>>{
      Mood.energized: [
        'energy',
        'spicy',
        'pepper',
        'caffeine',
        'hot',
        'power',
        'boost'
      ],
      Mood.calm: [
        'calm',
        'soothing',
        'relax',
        'mild',
        'gentle',
        'herbal',
        'chamomile'
      ],
      Mood.inspired: [
        'inspire',
        'creative',
        'aromatic',
        'unique',
        'fusion',
        'exotic'
      ],
      Mood.strong: ['strong', 'protein', 'meat', 'hearty', 'robust', 'stew'],
      Mood.joyful: [
        'joy',
        'happy',
        'sweet',
        'dessert',
        'treat',
        'fruit',
        'colorful'
      ],
      Mood.tired: ['tired', 'comfort', 'rest', 'easy', 'simple', 'quick'],
      Mood.peaceful: ['peace', 'zen', 'balance', 'light', 'refresh', 'mint'],
    };
    final Set<Mood> detectedMoods = {};
    for (final entry in moodKeywords.entries) {
      for (final kw in entry.value) {
        if (name.contains(kw) ||
            cat.contains(kw) ||
            instructions.contains(kw)) {
          detectedMoods.add(entry.key);
        }
      }
    }
    // Fallback: if no mood detected, assign based on hash
    final moods = detectedMoods.isNotEmpty
        ? detectedMoods.toList()
        : [Mood.values[name.hashCode.abs() % Mood.values.length]];

    return Potion(
      id: mealDbJson['idMeal'] ?? '',
      name: mealDbJson['strMeal'] ?? '',
      realName: mealDbJson['strMeal'] ?? '',
      category: category,
      moods: moods,
      difficulty: Difficulty.novice,
      prepTimeMinutes: 10,
      servings: 1,
      description: mealDbJson['strInstructions'] ?? '',
      ingredients: ingredients,
      steps: steps,
      benefits: const [],
      imageUrl: mealDbJson['strMealThumb'],
      isFavorite: false,
      isCached: false,
    );
  }

  // Returns a list of manual drink recipes (e.g., hot chocolate, tea, infusions)
  static List<Potion> manualDrinks() {
    return [
      Potion(
        id: 'manual_drink_1',
        name: 'Classic Hot Chocolate',
        realName: 'Classic Hot Chocolate',
        category: PotionCategory.drink,
        moods: [Mood.calm, Mood.joyful],
        difficulty: Difficulty.novice,
        prepTimeMinutes: 10,
        servings: 1,
        description:
            'A rich and creamy hot chocolate made with real cocoa and milk.',
        ingredients: [
          Ingredient(id: 'milk', name: 'Milk', quantity: 1, unit: 'cup'),
          Ingredient(
              id: 'cocoa', name: 'Cocoa powder', quantity: 2, unit: 'tbsp'),
          Ingredient(id: 'sugar', name: 'Sugar', quantity: 1, unit: 'tbsp'),
          Ingredient(
              id: 'vanilla',
              name: 'Vanilla extract',
              quantity: 0.25,
              unit: 'tsp'),
        ],
        steps: [
          BrewingStep(
              number: 1,
              instruction: 'Heat milk in a saucepan until steaming.'),
          BrewingStep(
              number: 2,
              instruction: 'Whisk in cocoa powder and sugar until dissolved.'),
          BrewingStep(
              number: 3, instruction: 'Add vanilla extract and stir well.'),
          BrewingStep(number: 4, instruction: 'Pour into a mug and enjoy.'),
        ],
        benefits: const ['Comforting', 'Mood-lifting'],
        imageUrl: null,
        isFavorite: false,
        isCached: false,
      ),
      Potion(
        id: 'manual_drink_2',
        name: 'Herbal Infusion',
        realName: 'Herbal Infusion',
        category: PotionCategory.drink,
        moods: [Mood.calm, Mood.peaceful],
        difficulty: Difficulty.novice,
        prepTimeMinutes: 5,
        servings: 1,
        description: 'A soothing herbal tea made with chamomile and mint.',
        ingredients: [
          Ingredient(
              id: 'chamomile',
              name: 'Chamomile flowers',
              quantity: 1,
              unit: 'tsp'),
          Ingredient(
              id: 'mint',
              name: 'Fresh mint leaves',
              quantity: 5,
              unit: 'leaves'),
          Ingredient(id: 'water', name: 'Hot water', quantity: 1, unit: 'cup'),
        ],
        steps: [
          BrewingStep(
              number: 1, instruction: 'Place chamomile and mint in a cup.'),
          BrewingStep(
              number: 2,
              instruction: 'Pour hot water over and steep for 5 minutes.'),
          BrewingStep(number: 3, instruction: 'Strain and enjoy.'),
        ],
        benefits: const ['Relaxing', 'Digestive'],
        imageUrl: null,
        isFavorite: false,
        isCached: false,
      ),
      Potion(
        id: 'manual_drink_3',
        name: 'Spiced Chai Latte',
        realName: 'Spiced Chai Latte',
        category: PotionCategory.drink,
        moods: [Mood.energized, Mood.calm],
        difficulty: Difficulty.novice,
        prepTimeMinutes: 10,
        servings: 1,
        description: 'A warming chai latte with black tea and spices.',
        ingredients: [
          Ingredient(
              id: 'black_tea', name: 'Black tea bag', quantity: 1, unit: 'pcs'),
          Ingredient(id: 'milk', name: 'Milk', quantity: 0.5, unit: 'cup'),
          Ingredient(id: 'water', name: 'Water', quantity: 0.5, unit: 'cup'),
          Ingredient(
              id: 'spices', name: 'Chai spice mix', quantity: 1, unit: 'tsp'),
          Ingredient(id: 'sugar', name: 'Sugar', quantity: 0, unit: 'to taste'),
        ],
        steps: [
          BrewingStep(
              number: 1,
              instruction:
                  'Boil water and steep tea bag with spices for 3 minutes.'),
          BrewingStep(number: 2, instruction: 'Heat milk and add to tea.'),
          BrewingStep(
              number: 3, instruction: 'Sweeten to taste and serve hot.'),
        ],
        benefits: const ['Energizing', 'Comforting'],
        imageUrl: null,
        isFavorite: false,
        isCached: false,
      ),
    ];
  }
}
