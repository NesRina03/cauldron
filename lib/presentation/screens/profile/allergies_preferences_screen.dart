import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import '../../../providers/potion_provider.dart';

const List<String> allergyOptions = [
  'Lactose',
  'Gluten',
  'Peanuts',
  'Tree Nuts',
  'Eggs',
  'Fish',
  'Shellfish',
  'Soy',
  'Sesame',
  'Dairy',
  'Wheat',
  'Mustard',
  'Celery',
  'Sulphites',
  'Lupin',
  'Molluscs',
];

const List<String> preferenceOptions = [
  'Vegan',
  'Vegetarian',
  'Pescatarian',
  'Keto',
  'Halal',
  'Kosher',
  'Low Carb',
  'Low Sugar',
  'Paleo',
  'Dairy-Free',
  'Gluten-Free',
];

class AllergiesPreferencesScreen extends StatefulWidget {
  const AllergiesPreferencesScreen({Key? key}) : super(key: key);

  @override
  State<AllergiesPreferencesScreen> createState() =>
      _AllergiesPreferencesScreenState();
}

class _AllergiesPreferencesScreenState
    extends State<AllergiesPreferencesScreen> {
  Set<String> _allergies = {};
  Set<String> _preferences = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _allergies = (prefs.getStringList('user_allergies') ?? []).toSet();
      _preferences = (prefs.getStringList('user_preferences') ?? []).toSet();
    });
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('user_allergies', _allergies.toList());
    await prefs.setStringList('user_preferences', _preferences.toList());
    // Update all recipe tags after saving
    if (mounted) {
      final provider = context.read<PotionProvider>();
      await provider.updateAllRecipeUserTags();
    }
  }

  Widget _buildChips(List<String> options, Set<String> selected,
      void Function(String, bool) onChanged) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.map((option) {
        final isSelected = selected.contains(option);
        return FilterChip(
          label: Text(option),
          selected: isSelected,
          onSelected: (val) {
            onChanged(option, val);
            _save();
          },
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Allergies & Preferences')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: ListView(
          children: [
            Text('Food Allergies',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            _buildChips(allergyOptions, _allergies, (name, val) {
              setState(() {
                if (val) {
                  _allergies.add(name);
                } else {
                  _allergies.remove(name);
                }
              });
            }),
            const SizedBox(height: 24),
            Text('Food Preferences',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            _buildChips(preferenceOptions, _preferences, (name, val) {
              setState(() {
                if (val) {
                  _preferences.add(name);
                } else {
                  _preferences.remove(name);
                }
              });
            }),
          ],
        ),
      ),
    );
  }
}
