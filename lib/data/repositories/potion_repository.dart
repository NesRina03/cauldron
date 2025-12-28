import '../datasources/mealdb_api.dart';
import '../models/potion.dart';

class PotionRepository {
  // Fetch a single recipe by ID from API only
  Future<Potion?> getPotionById(String id) async {
    final apiRecipes = await MealDBApi.fetchAllRecipes();
    final potions =
        apiRecipes.map(MealDBMapper.toPotion).where((p) => p.id == id);
    return potions.isNotEmpty ? potions.first : null;
  }

  // Fetch all potions from API only
  Future<List<Potion>> getAllPotions() async {
    final apiRecipes = await MealDBApi.fetchAllRecipes();
    return apiRecipes.map(MealDBMapper.toPotion).toList();
  }
}
