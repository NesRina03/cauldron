import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/models/mood.dart';

class MoodProvider extends ChangeNotifier {
  Mood _currentMood = Mood.energized;
  List<Mood> _moodHistory = [];

  Mood get currentMood => _currentMood;
  List<Mood> get moodHistory => _moodHistory;

  MoodProvider() {
    _loadMood();
    _predictMood();
  }

  Future<void> _loadMood() async {
    final prefs = await SharedPreferences.getInstance();
    final moodName = prefs.getString('currentMood');
    if (moodName != null) {
      _currentMood = Mood.values.firstWhere(
        (m) => m.name == moodName,
        orElse: () => Mood.energized,
      );
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

  Future<void> setMood(Mood mood) async {
    _currentMood = mood;
    _moodHistory.add(mood);
    
    // Keep only last 50 moods
    if (_moodHistory.length > 50) {
      _moodHistory = _moodHistory.sublist(_moodHistory.length - 50);
    }
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('currentMood', mood.name);
    await prefs.setStringList(
      'moodHistory',
      _moodHistory.map((m) => m.name).toList(),
    );
    
    notifyListeners();
  }

  // Predict mood based on time of day and history
  void _predictMood() {
    final hour = DateTime.now().hour;
    
    // Morning (6-10): Likely tired or need energy
    if (hour >= 6 && hour < 10) {
      _currentMood = Mood.tired;
    }
    // Afternoon (14-17): Might need focus
    else if (hour >= 14 && hour < 17) {
      _currentMood = Mood.inspired;
    }
    // Evening (18-22): Likely want to relax
    else if (hour >= 18 && hour < 22) {
      _currentMood = Mood.calm;
    }
    // Night (22+): Definitely tired
    else if (hour >= 22 || hour < 6) {
      _currentMood = Mood.peaceful;
    }
    
    notifyListeners();
  }

  Mood getPredictedMood() {
    final hour = DateTime.now().hour;
    
    if (hour >= 6 && hour < 10) return Mood.tired;
    if (hour >= 14 && hour < 17) return Mood.inspired;
    if (hour >= 18 && hour < 22) return Mood.calm;
    return Mood.peaceful;
  }
}