import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<List<String>> getUserPreferences() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getStringList('user_preferences') ?? [];
}

class RecipePreferencesTags extends StatelessWidget {
  final List<String> recipeTags;
  const RecipePreferencesTags({Key? key, required this.recipeTags})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<String>>(
      future: getUserPreferences(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty)
          return const SizedBox.shrink();
        final prefs = snapshot.data!;
        final matches = prefs
            .where((p) => recipeTags
                .map((t) => t.toLowerCase())
                .contains(p.toLowerCase()))
            .toList();
        if (matches.isEmpty) return const SizedBox.shrink();
        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: matches
              .map((tag) => Chip(
                    label: Text(tag),
                    backgroundColor: Colors.green.withOpacity(0.2),
                    labelStyle: const TextStyle(color: Colors.green),
                  ))
              .toList(),
        );
      },
    );
  }
}
