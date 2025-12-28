import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../data/models/ingredients.dart';

Future<List<String>> getUserAllergies() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getStringList('user_allergies') ?? [];
}

class AllergyWarning extends StatelessWidget {
  final List<Ingredient> ingredients;
  const AllergyWarning({Key? key, required this.ingredients}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<String>>(
      future: getUserAllergies(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty)
          return const SizedBox.shrink();
        final allergies = snapshot.data!;
        final found = ingredients
            .where((i) => allergies
                .any((a) => i.name.toLowerCase().contains(a.toLowerCase())))
            .toList();
        if (found.isEmpty) return const SizedBox.shrink();
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.1),
            border: Border.all(color: Colors.red),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Icon(Icons.warning, color: Colors.red),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Warning: This recipe contains ingredients you marked as allergies or preferences: ' +
                      found.map((i) => i.name).join(', '),
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
