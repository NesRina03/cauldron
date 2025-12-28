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
    final pantryJson = prefs.getString('pantry_full');
    if (pantryJson != null) {
      final decoded = json.decode(pantryJson) as List<dynamic>;
      _items.clear();
      _items.addAll(
          decoded.map((e) => Ingredient.fromJson(e as Map<String, dynamic>)));
      _pantryIngredients =
          _items.where((i) => i.isInPantry).map((i) => i.id).toSet();
    } else {
      _items.clear();
      _pantryIngredients.clear();
    }
    notifyListeners();
  }

  Future<void> _savePantry() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        'pantry_full', json.encode(_items.map((e) => e.toJson()).toList()));
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
        id: ingredientId,
        name: ingredientId,
        quantity: 0,
        unit: '',
        isInPantry: true));
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
    _pantryIngredients.add(ingredient.id);
    final idx = _items.indexWhere((item) => item.id == ingredient.id);
    final isAvailable = ingredient.quantity > 0;
    if (idx != -1) {
      _items[idx] = ingredient.copyWith(isInPantry: isAvailable);
    } else {
      _items.add(ingredient.copyWith(isInPantry: isAvailable));
    }
    await _savePantry();
    notifyListeners();
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
