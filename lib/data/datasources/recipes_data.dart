import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/potion.dart';

class RecipesDataSource {
  static Future<List<Potion>> loadRecipes() async {
    try {
      final String response = await rootBundle.loadString('assets/data/recipes.json');
      final List<dynamic> data = json.decode(response);
      return data.map((json) => Potion.fromJson(json)).toList();
    } catch (e) {
      print('Error loading recipes: $e');
      return [];
    }
  }
}