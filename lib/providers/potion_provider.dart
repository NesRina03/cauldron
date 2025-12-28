import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/models/potion.dart';
import '../data/models/mood.dart';
import '../data/repositories/potion_repository.dart';
import 'dart:convert';
import '../presentation/screens/potion_detail/widgets/tag_keyword_maps.dart';

class PotionProvider extends ChangeNotifier {
  // Map of recipe id to user allergy/preference tags
  final Map<String, List<String>> _recipeUserTags = {};

  /// Filters by mood/category and search query in a single public method
  void searchAndFilter({String? query, Mood? mood, PotionCategory? category}) {
    final baseList = _allPotions.where((potion) {
      final moodMatch = mood == null || potion.moods.contains(mood);
      final catMatch = category == null || potion.category == category;
      return moodMatch && catMatch;
    }).toList();
    if (query == null || query.isEmpty) {
      _filteredPotions = baseList;
    } else {
      _filteredPotions = baseList.where((potion) {
        return potion.name.toLowerCase().contains(query.toLowerCase()) ||
            potion.realName.toLowerCase().contains(query.toLowerCase()) ||
            potion.description.toLowerCase().contains(query.toLowerCase());
      }).toList();
    }
    notifyListeners();
  }

  void filterByMoodAndCategory({Mood? mood, PotionCategory? category}) {
    _filteredPotions = _allPotions.where((potion) {
      final moodMatch = mood == null || potion.moods.contains(mood);
      final catMatch = category == null || potion.category == category;
      return moodMatch && catMatch;
    }).toList();
    notifyListeners();
  }

  List<Potion> _allPotions = [];
  List<Potion> _filteredPotions = [];
  bool _isLoading = true;
  String? _error;

  List<Potion> get allPotions => _allPotions;
  List<Potion> get filteredPotions => _filteredPotions;
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<String> getUserTagsForRecipe(String id) => _recipeUserTags[id] ?? [];

  final PotionRepository _repository = PotionRepository();

  PotionProvider() {
    loadPotions();
  }

  Future<void> _updateAllRecipeUserTags() async {
    final prefs = await SharedPreferences.getInstance();
    final allergies = prefs.getStringList('user_allergies') ?? [];
    final preferences = prefs.getStringList('user_preferences') ?? [];
    _recipeUserTags.clear();
    for (final potion in _allPotions) {
      final List<String> tags = [];
      // Allergies
      for (final allergy in allergies) {
        final keywords = allergyTagKeywords[allergy] ?? [allergy];
        if (potion.ingredients.any((i) => keywords
            .any((kw) => i.name.toLowerCase().contains(kw.toLowerCase())))) {
          tags.add(allergy);
        }
      }
      // Preferences
      for (final pref in preferences) {
        final keywords = preferenceTagKeywords[pref] ?? [pref];
        if (pref == 'Halal') {
          // Halal: tag as Halal if NONE of the forbidden keywords are present
          final hasForbidden = potion.ingredients.any((i) => keywords
              .any((kw) => i.name.toLowerCase().contains(kw.toLowerCase())));
          if (!hasForbidden) {
            tags.add('Halal');
          }
        } else {
          if (potion.ingredients.any((i) => keywords
              .any((kw) => i.name.toLowerCase().contains(kw.toLowerCase())))) {
            tags.add(pref);
          }
        }
      }
      _recipeUserTags[potion.id] = tags;
    }
    notifyListeners();
  }

  Future<void> updateAllRecipeUserTags() async {
    await _updateAllRecipeUserTags();
  }

  Future<void> loadPotions() async {
    try {
      _isLoading = true;
      notifyListeners();

      // Load all potions from API only
      _allPotions = await _repository.getAllPotions();

      // Load favorites and cached status from SharedPreferences
      await _loadPotionStates();

      _filteredPotions = _allPotions;
      _isLoading = false;
      _error = null;
      // After loading potions, update allergy/preference tags
      await _updateAllRecipeUserTags();
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
      final List<String> favorites =
          List<String>.from(json.decode(favoritesJson));
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
    final favorites =
        _allPotions.where((p) => p.isFavorite).map((p) => p.id).toList();
    final cached =
        _allPotions.where((p) => p.isCached).map((p) => p.id).toList();

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
      _filteredPotions
          .sort((a, b) => a.prepTimeMinutes.compareTo(b.prepTimeMinutes));
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
      _filteredPotions =
          _allPotions.where((potion) => potion.canMakeNow).toList();
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

  /// Filter by user food preference tag, optionally with mood and category
  void filterByPreference(
      {required String preference, Mood? mood, PotionCategory? category}) {
    final baseList = _allPotions.where((potion) {
      final moodMatch = mood == null || potion.moods.contains(mood);
      final catMatch = category == null || potion.category == category;
      final tags = _recipeUserTags[potion.id] ?? [];
      final prefMatch = tags.contains(preference);
      return moodMatch && catMatch && prefMatch;
    }).toList();
    _filteredPotions = baseList;
    notifyListeners();
  }
}
