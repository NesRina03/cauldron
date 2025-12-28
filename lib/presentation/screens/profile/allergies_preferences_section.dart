import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../data/models/ingredients.dart';
import '../../../providers/pantry_provider.dart';

class AllergiesPreferencesSection extends StatefulWidget {
  const AllergiesPreferencesSection({Key? key}) : super(key: key);

  @override
  State<AllergiesPreferencesSection> createState() =>
      _AllergiesPreferencesSectionState();
}

class _AllergiesPreferencesSectionState
    extends State<AllergiesPreferencesSection> {
  Set<String> _allergies = {};
  Set<String> _preferences = {};
  List<Ingredient> _allIngredients = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final allergies = prefs.getStringList('user_allergies') ?? [];
    final preferences = prefs.getStringList('user_preferences') ?? [];
    final pantryProvider = Provider.of<PantryProvider>(context, listen: false);
    setState(() {
      _allergies = allergies.toSet();
      _preferences = preferences.toSet();
      _allIngredients = List<Ingredient>.from(pantryProvider.items);
      _allIngredients.sort((a, b) => a.name.compareTo(b.name));
    });
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('user_allergies', _allergies.toList());
    await prefs.setStringList('user_preferences', _preferences.toList());
  }

  Widget _buildChips(
      Set<String> selected, void Function(String, bool) onChanged) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _allIngredients.map((ingredient) {
        final isSelected = selected.contains(ingredient.name);
        return FilterChip(
          label: Text(ingredient.name),
          selected: isSelected,
          onSelected: (val) {
            onChanged(ingredient.name, val);
            _save();
          },
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Food Allergies', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        _buildChips(_allergies, (name, val) {
          setState(() {
            if (val) {
              _allergies.add(name);
              _preferences.remove(name);
            } else {
              _allergies.remove(name);
            }
          });
        }),
        const SizedBox(height: 24),
        Text('Food Preferences',
            style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        _buildChips(_preferences, (name, val) {
          setState(() {
            if (val) {
              _preferences.add(name);
              _allergies.remove(name);
            } else {
              _preferences.remove(name);
            }
          });
        }),
      ],
    );
  }
}
