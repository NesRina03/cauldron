import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/ingredients.dart';
import '../models/potion.dart';
import '../models/mood.dart';

// Helper to map MealDB API to Potion model
class MealDBMapper {
  static Potion toPotion(MealRecipe meal) {
    // Map ingredients
    final ingredients = meal.ingredients.map((i) {
      double quantity = 0;
      String unit = '';
      if (i.measure.trim().isNotEmpty) {
        final parts = i.measure.trim().split(' ');
        if (parts.length == 1) {
          final numVal = double.tryParse(parts[0]);
          if (numVal != null) {
            quantity = numVal;
          } else {
            unit = parts[0];
          }
        } else if (parts.length > 1) {
          final numVal = double.tryParse(parts[0]);
          if (numVal != null) {
            quantity = numVal;
            unit = parts.sublist(1).join(' ');
          } else {
            unit = i.measure.trim();
          }
        }
      }
      return Ingredient(
        id: i.name,
        name: i.name,
        quantity: quantity,
        unit: unit,
        isInPantry: false,
      );
    }).toList();

    // Map steps (split instructions by line or period)
    final steps = <BrewingStep>[];
    final instructions = meal.instructions.split(RegExp(r'[\n\r]+|\. '));
    int stepNum = 1;
    for (final instr in instructions) {
      final trimmed = instr.trim();
      if (trimmed.isNotEmpty) {
        steps.add(BrewingStep(number: stepNum++, instruction: trimmed));
      }
    }

    // Map category to PotionCategory
    PotionCategory category = PotionCategory.meal;
    switch (meal.category.toLowerCase()) {
      case 'drink':
        category = PotionCategory.drink;
        break;
      case 'dessert':
        category = PotionCategory.dessert;
        break;
      case 'elixir':
        category = PotionCategory.elixir;
        break;
      case 'meal':
      default:
        category = PotionCategory.meal;
    }

    // Assign a random mood for demo (could be improved)
    final moods = [Mood.values[meal.name.hashCode.abs() % Mood.values.length]];

    return Potion(
      id: meal.id,
      name: meal.name,
      realName: meal.name,
      category: category,
      moods: moods,
      difficulty: Difficulty.novice,
      prepTimeMinutes: 10,
      servings: 1,
      description: '',
      ingredients: ingredients,
      steps: steps,
      benefits: const [],
      imageUrl: meal.imageUrl,
      isFavorite: false,
      isCached: false,
    );
  }
}

class MealDBApi {
  static const String baseUrl = 'https://www.themealdb.com/api/json/v1/1/';

  static Future<List<MealRecipe>> fetchAllRecipes() async {
    final response = await http.get(Uri.parse('${baseUrl}search.php?s='));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final meals = data['meals'] as List?;
      if (meals == null) return [];
      return meals.map((json) => MealRecipe.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load recipes');
    }
  }
}

class MealRecipe {
  final String id;
  final String name;
  final String category;
  final String area;
  final String instructions;
  final String imageUrl;
  final List<MealIngredient> ingredients;

  MealRecipe({
    required this.id,
    required this.name,
    required this.category,
    required this.area,
    required this.instructions,
    required this.imageUrl,
    required this.ingredients,
  });

  factory MealRecipe.fromJson(Map<String, dynamic> json) {
    final ingredients = <MealIngredient>[];
    for (int i = 1; i <= 20; i++) {
      final ingredient = json['strIngredient$i'];
      final measure = json['strMeasure$i'];
      if (ingredient != null && ingredient.toString().trim().isNotEmpty) {
        ingredients.add(MealIngredient(
          name: ingredient,
          measure: measure ?? '',
        ));
      }
    }
    return MealRecipe(
      id: json['idMeal'] ?? '',
      name: json['strMeal'] ?? '',
      category: json['strCategory'] ?? '',
      area: json['strArea'] ?? '',
      instructions: json['strInstructions'] ?? '',
      imageUrl: json['strMealThumb'] ?? '',
      ingredients: ingredients,
    );
  }
}

class MealIngredient {
  final String name;
  final String measure;
  MealIngredient({required this.name, required this.measure});
}
