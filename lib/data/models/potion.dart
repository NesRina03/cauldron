import 'ingredients.dart';
import 'mood.dart';

enum PotionCategory {
  drink,
  dessert,
  meal,
  elixir;

  String get displayName {
    switch (this) {
      case PotionCategory.drink:
        return 'Drink';
      case PotionCategory.dessert:
        return 'Dessert';
      case PotionCategory.meal:
        return 'Meal';
      case PotionCategory.elixir:
        return 'Elixir';
    }
  }
}

enum Difficulty {
  novice,
  apprentice,
  adept,
  master;

  String get displayName {
    switch (this) {
      case Difficulty.novice:
        return 'Novice';
      case Difficulty.apprentice:
        return 'Apprentice';
      case Difficulty.adept:
        return 'Adept';
      case Difficulty.master:
        return 'Master';
    }
  }

  int get stars {
    switch (this) {
      case Difficulty.novice:
        return 1;
      case Difficulty.apprentice:
        return 2;
      case Difficulty.adept:
        return 3;
      case Difficulty.master:
        return 4;
    }
  }
}

class BrewingStep {
  final int number;
  final String instruction;
  final int? durationMinutes;

  BrewingStep({
    required this.number,
    required this.instruction,
    this.durationMinutes,
  });

  Map<String, dynamic> toJson() => {
        'number': number,
        'instruction': instruction,
        'durationMinutes': durationMinutes,
      };

  factory BrewingStep.fromJson(Map<String, dynamic> json) => BrewingStep(
        number: json['number'] as int,
        instruction: json['instruction'] as String,
        durationMinutes: json['durationMinutes'] as int?,
      );
}

class Potion {
  final String id;
  final String name;
  final String realName;
  final PotionCategory category;
  final List<Mood> moods;
  final Difficulty difficulty;
  final int prepTimeMinutes;
  final int servings;
  final String description;
  final List<Ingredient> ingredients;
  final List<BrewingStep> steps;
  final List<String> benefits;
  final String? imageUrl;
  final bool isFavorite;
  final bool isCached;

  Potion({
    required this.id,
    required this.name,
    required this.realName,
    required this.category,
    required this.moods,
    required this.difficulty,
    required this.prepTimeMinutes,
    required this.servings,
    required this.description,
    required this.ingredients,
    required this.steps,
    this.benefits = const [],
    this.imageUrl,
    this.isFavorite = false,
    this.isCached = false,
  });

  bool get canMakeNow => ingredients.every((i) => i.isInPantry == true);
  int get missingIngredientsCount =>
      ingredients.where((i) => i.isInPantry != true).length;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'realName': realName,
        'category': category.name,
        'moods': moods.map((m) => m.name).toList(),
        'difficulty': difficulty.name,
        'prepTimeMinutes': prepTimeMinutes,
        'servings': servings,
        'description': description,
        'ingredients': ingredients.map((i) => i.toJson()).toList(),
        'steps': steps.map((s) => s.toJson()).toList(),
        'benefits': benefits,
        'imageUrl': imageUrl,
        'isFavorite': isFavorite,
        'isCached': isCached,
      };

  factory Potion.fromJson(Map<String, dynamic> json) => Potion(
        id: json['id'] as String,
        name: json['name'] as String,
        realName: json['realName'] as String,
        category: PotionCategory.values.byName(json['category'] as String),
        moods: (json['moods'] as List)
            .map((m) => Mood.values.byName(m as String))
            .toList(),
        difficulty: Difficulty.values.byName(json['difficulty'] as String),
        prepTimeMinutes: json['prepTimeMinutes'] as int,
        servings: json['servings'] as int,
        description: json['description'] as String,
        ingredients: (json['ingredients'] as List)
            .map((i) => Ingredient.fromJson(i as Map<String, dynamic>))
            .toList(),
        steps: (json['steps'] as List)
            .map((s) => BrewingStep.fromJson(s as Map<String, dynamic>))
            .toList(),
        benefits: (json['benefits'] as List?)?.cast<String>() ?? [],
        imageUrl: json['imageUrl'] as String?,
        isFavorite: json['isFavorite'] as bool? ?? false,
        isCached: json['isCached'] as bool? ?? false,
      );

  Potion copyWith({
    String? id,
    String? name,
    String? realName,
    PotionCategory? category,
    List<Mood>? moods,
    Difficulty? difficulty,
    int? prepTimeMinutes,
    int? servings,
    String? description,
    List<Ingredient>? ingredients,
    List<BrewingStep>? steps,
    List<String>? benefits,
    String? imageUrl,
    bool? isFavorite,
    bool? isCached,
  }) =>
      Potion(
        id: id ?? this.id,
        name: name ?? this.name,
        realName: realName ?? this.realName,
        category: category ?? this.category,
        moods: moods ?? this.moods,
        difficulty: difficulty ?? this.difficulty,
        prepTimeMinutes: prepTimeMinutes ?? this.prepTimeMinutes,
        servings: servings ?? this.servings,
        description: description ?? this.description,
        ingredients: ingredients ?? this.ingredients,
        steps: steps ?? this.steps,
        benefits: benefits ?? this.benefits,
        imageUrl: imageUrl ?? this.imageUrl,
        isFavorite: isFavorite ?? this.isFavorite,
        isCached: isCached ?? this.isCached,
      );
}
