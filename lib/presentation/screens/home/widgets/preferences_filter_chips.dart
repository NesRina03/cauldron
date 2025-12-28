import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Widget to display user food preference tags as filter chips and allow filtering recipes by them.
class PreferencesFilterChips extends StatefulWidget {
  final void Function(String?) onFilterChanged;
  final String? selectedPreference;
  const PreferencesFilterChips(
      {Key? key, required this.onFilterChanged, this.selectedPreference})
      : super(key: key);

  @override
  State<PreferencesFilterChips> createState() => _PreferencesFilterChipsState();
}

class _PreferencesFilterChipsState extends State<PreferencesFilterChips> {
  List<String> _preferences = [];

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _preferences = prefs.getStringList('user_preferences') ?? [];
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_preferences.isEmpty) return const SizedBox.shrink();
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          ..._preferences.map((pref) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(pref),
                  selected: widget.selectedPreference == pref,
                  onSelected: (selected) {
                    widget.onFilterChanged(selected ? pref : null);
                  },
                ),
              )),
        ],
      ),
    );
  }
}
