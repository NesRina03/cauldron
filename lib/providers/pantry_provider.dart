import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../data/models/ingredients.dart';

class PantryProvider extends ChangeNotifier {
  final List<Ingredient> _items = [];
  Set<String> _pantryIngredients = {};

  List<Ingredient> get items => _items;
  Set<String> get pantryIngredients => _pantryIngredients;

  PantryProvider() {
    _loadPantry();
  }

  Future<void> _loadPantry() async {
    final prefs = await SharedPreferences.getInstance();
    final pantryJson = prefs.getString('pantry');
    if (pantryJson != null) {
      _pantryIngredients = Set<String>.from(json.decode(pantryJson));
    }
    // For demo, just create Ingredient objects from IDs
    _items.clear();
    for (final id in _pantryIngredients) {
      _items.add(Ingredient(id: id, name: id, amount: '', isInPantry: true));
    }
    notifyListeners();
  }

  Future<void> _savePantry() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('pantry', json.encode(_pantryIngredients.toList()));
  }

  Future<void> toggleIngredient(String ingredientId) async {
    if (_pantryIngredients.contains(ingredientId)) {
      _pantryIngredients.remove(ingredientId);
    } else {
      _pantryIngredients.add(ingredientId);
    }
    await _savePantry();
    notifyListeners();
  }

  bool hasIngredient(String ingredientId) {
    return _pantryIngredients.contains(ingredientId);
  }

  Future<void> addIngredient(String ingredientId) async {
    _pantryIngredients.add(ingredientId);
    _items.add(Ingredient(
        id: ingredientId, name: ingredientId, amount: '', isInPantry: true));
    await _savePantry();
    notifyListeners();
  }

  Future<void> removeIngredient(String ingredientId) async {
    _pantryIngredients.remove(ingredientId);
    _items.removeWhere((item) => item.id == ingredientId);
    await _savePantry();
    notifyListeners();
  }

  Future<void> addItem(Ingredient ingredient) async {
    if (!_pantryIngredients.contains(ingredient.id)) {
      _pantryIngredients.add(ingredient.id);
      _items.add(ingredient.copyWith(isInPantry: true));
      await _savePantry();
      notifyListeners();
    }
  }

  Future<void> removeItem(Ingredient ingredient) async {
    _pantryIngredients.remove(ingredient.id);
    _items.removeWhere((item) => item.id == ingredient.id);
    await _savePantry();
    notifyListeners();
  }

  Future<void> clearPantry() async {
    _pantryIngredients.clear();
    await _savePantry();
    notifyListeners();
  }
}
