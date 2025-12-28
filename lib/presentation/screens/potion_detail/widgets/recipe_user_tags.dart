import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../data/models/ingredients.dart';
import 'tag_keyword_maps.dart';

Future<List<String>> getUserAllergies() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getStringList('user_allergies') ?? [];
}

Future<List<String>> getUserPreferences() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getStringList('user_preferences') ?? [];
}

class RecipeUserTags extends StatelessWidget {
  final List<Ingredient> ingredients;
  final List<String> benefits;
  const RecipeUserTags(
      {Key? key, required this.ingredients, required this.benefits})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<List<String>>>(
      future: Future.wait([
        getUserAllergies(),
        getUserPreferences(),
      ]),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox.shrink();
        final allergies = snapshot.data![0];
        final preferences = snapshot.data![1];
        // Allergies: match using tag-to-keywords map
        final allergyMatches = allergies.where((tag) {
          final keywords = allergyTagKeywords[tag] ?? [tag];
          return ingredients.any((i) => keywords
              .any((kw) => i.name.toLowerCase().contains(kw.toLowerCase())));
        }).toList();

        // Preferences: match using tag-to-keywords map (forbidden ingredients)
        final preferenceMatches = preferences.where((tag) {
          final keywords = preferenceTagKeywords[tag] ?? [tag];
          return ingredients.any((i) => keywords
              .any((kw) => i.name.toLowerCase().contains(kw.toLowerCase())));
        }).toList();
        if (allergyMatches.isEmpty && preferenceMatches.isEmpty)
          return const SizedBox.shrink();
        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ...allergyMatches.map((tag) => Chip(
                  label: Text(tag),
                  backgroundColor: Colors.red.withOpacity(0.2),
                  labelStyle: const TextStyle(color: Colors.red),
                )),
            ...preferenceMatches.map((tag) => Chip(
                  label: Text(tag),
                  backgroundColor: Colors.green.withOpacity(0.2),
                  labelStyle: const TextStyle(color: Colors.green),
                )),
          ],
        );
      },
    );
  }
}
