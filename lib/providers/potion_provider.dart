import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/models/potion.dart';
import '../data/models/mood.dart';
import '../data/datasources/recipes_data.dart';
import 'dart:convert';

class PotionProvider extends ChangeNotifier {
  List<Potion> _allPotions = [];
  List<Potion> _filteredPotions = [];
  bool _isLoading = true;
  String? _error;

  List<Potion> get allPotions => _allPotions;
  List<Potion> get filteredPotions => _filteredPotions;
  bool get isLoading => _isLoading;
  String? get error => _error;

  PotionProvider() {
    loadPotions();
  }

  Future<void> loadPotions() async {
    try {
      _isLoading = true;
      notifyListeners();

      // Load from JSON
      _allPotions = await RecipesDataSource.loadRecipes();
      
      // Load favorites and cached status from SharedPreferences
      await _loadPotionStates();
      
      _filteredPotions = _allPotions;
      _isLoading = false;
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load potions: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadPotionStates() async {
    final prefs = await SharedPreferences.getInstance();
    final favoritesJson = prefs.getString('favorites');
    final cachedJson = prefs.getString('cached');
    
    if (favoritesJson != null) {
      final List<String> favorites = List<String>.from(json.decode(favoritesJson));
      _allPotions = _allPotions.map((potion) {
        return potion.copyWith(isFavorite: favorites.contains(potion.id));
      }).toList();
    }
    
    if (cachedJson != null) {
      final List<String> cached = List<String>.from(json.decode(cachedJson));
      _allPotions = _allPotions.map((potion) {
        return potion.copyWith(isCached: cached.contains(potion.id));
      }).toList();
    }
  }

  Future<void> _savePotionStates() async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = _allPotions.where((p) => p.isFavorite).map((p) => p.id).toList();
    final cached = _allPotions.where((p) => p.isCached).map((p) => p.id).toList();
    
    await prefs.setString('favorites', json.encode(favorites));
    await prefs.setString('cached', json.encode(cached));
  }

  void filterByMood(Mood mood) {
    _filteredPotions = _allPotions.where((potion) {
      return potion.moods.contains(mood);
    }).toList();
    
    // Sort by complexity based on mood
    if (mood == Mood.tired) {
      // Show simplest recipes first when tired
      _filteredPotions.sort((a, b) => 
        a.prepTimeMinutes.compareTo(b.prepTimeMinutes));
    }
    
    notifyListeners();
  }

  void filterByCategory(PotionCategory category) {
    _filteredPotions = _allPotions.where((potion) {
      return potion.category == category;
    }).toList();
    notifyListeners();
  }

  void filterByAvailability(bool canMakeNow) {
    if (canMakeNow) {
      _filteredPotions = _allPotions.where((potion) => potion.canMakeNow).toList();
    } else {
      _filteredPotions = _allPotions;
    }
    notifyListeners();
  }

  void searchPotions(String query) {
    if (query.isEmpty) {
      _filteredPotions = _allPotions;
    } else {
      _filteredPotions = _allPotions.where((potion) {
        return potion.name.toLowerCase().contains(query.toLowerCase()) ||
            potion.realName.toLowerCase().contains(query.toLowerCase()) ||
            potion.description.toLowerCase().contains(query.toLowerCase());
      }).toList();
    }
    notifyListeners();
  }

  Future<void> toggleFavorite(String potionId) async {
    final index = _allPotions.indexWhere((p) => p.id == potionId);
    if (index != -1) {
      _allPotions[index] = _allPotions[index].copyWith(
        isFavorite: !_allPotions[index].isFavorite,
      );
      await _savePotionStates();
      notifyListeners();
    }
  }

  Future<void> toggleCached(String potionId) async {
    final index = _allPotions.indexWhere((p) => p.id == potionId);
    if (index != -1) {
      _allPotions[index] = _allPotions[index].copyWith(
        isCached: !_allPotions[index].isCached,
      );
      await _savePotionStates();
      notifyListeners();
    }
  }

  Potion? getPotionById(String id) {
    try {
      return _allPotions.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }

  List<Potion> getFavorites() {
    return _allPotions.where((p) => p.isFavorite).toList();
  }

  List<Potion> getCachedPotions() {
    return _allPotions.where((p) => p.isCached).toList();
  }

  void resetFilters() {
    _filteredPotions = _allPotions;
    notifyListeners();
  }
}