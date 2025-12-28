import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AllergyPreferencesScreen extends StatefulWidget {
  const AllergyPreferencesScreen({Key? key}) : super(key: key);

  @override
  State<AllergyPreferencesScreen> createState() =>
      _AllergyPreferencesScreenState();
}

class _AllergyPreferencesScreenState extends State<AllergyPreferencesScreen> {
  final TextEditingController _controller = TextEditingController();
  List<String> _allergies = [];

  @override
  void initState() {
    super.initState();
    _loadAllergies();
  }

  Future<void> _loadAllergies() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _allergies = prefs.getStringList('user_allergies') ?? [];
    });
  }

  Future<void> _saveAllergies() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('user_allergies', _allergies);
  }

  void _addAllergy() {
    final text = _controller.text.trim();
    if (text.isNotEmpty && !_allergies.contains(text)) {
      setState(() {
        _allergies.add(text);
        _controller.clear();
      });
      _saveAllergies();
    }
  }

  void _removeAllergy(int index) {
    setState(() {
      _allergies.removeAt(index);
    });
    _saveAllergies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Allergies & Preferences')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Add your food allergies or dietary preferences:',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                        hintText: 'e.g. peanuts, gluten, vegan'),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: _addAllergy,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _allergies.isEmpty
                  ? const Center(
                      child: Text('No allergies or preferences set.'))
                  : ListView.builder(
                      itemCount: _allergies.length,
                      itemBuilder: (context, index) => Card(
                        child: ListTile(
                          title: Text(_allergies[index]),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => _removeAllergy(index),
                          ),
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
