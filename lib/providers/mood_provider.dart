import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/models/mood.dart';

class MoodProvider extends ChangeNotifier {
  Mood? _currentMood;
  List<Mood> _moodHistory = [];

  Mood? get currentMood => _currentMood;
  List<Mood> get moodHistory => _moodHistory;

  MoodProvider() {
    _loadMood();
  }

  Future<void> _loadMood() async {
    final prefs = await SharedPreferences.getInstance();
    final moodName = prefs.getString('currentMood');
    if (moodName != null) {
      try {
        _currentMood = Mood.values.firstWhere((m) => m.name == moodName);
      } catch (_) {
        _currentMood = null;
      }
    } else {
      _currentMood = null;
    }

    // Load mood history
    final historyJson = prefs.getStringList('moodHistory') ?? [];
    _moodHistory = historyJson
        .map((name) => Mood.values.firstWhere(
              (m) => m.name == name,
              orElse: () => Mood.energized,
            ))
        .toList();

    notifyListeners();
  }

  Future<void> setMood(Mood? mood) async {
    final prefs = await SharedPreferences.getInstance();
    if (mood == null) {
      _currentMood = null;
      await prefs.remove('currentMood');
      notifyListeners();
      return;
    }
    _currentMood = mood;
    _moodHistory.add(mood);

    // Keep only last 50 moods
    if (_moodHistory.length > 50) {
      _moodHistory = _moodHistory.sublist(_moodHistory.length - 50);
    }

    await prefs.setString('currentMood', mood.name);
    await prefs.setStringList(
      'moodHistory',
      _moodHistory.map((m) => m.name).toList(),
    );

    notifyListeners();
  }

  // Predict mood based on time of day and history
  // _predictMood removed (unused)

  Mood getPredictedMood() {
    final hour = DateTime.now().hour;

    if (hour >= 6 && hour < 10) return Mood.tired;
    if (hour >= 14 && hour < 17) return Mood.inspired;
    if (hour >= 18 && hour < 22) return Mood.calm;
    return Mood.peaceful;
  }
}
