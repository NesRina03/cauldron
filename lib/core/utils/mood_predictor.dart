import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/mood.dart';

class MoodPredictor {
  static const String _moodHistoryKey = 'mood_history_detailed';

  /// Predict mood based on multiple factors
  static Future<Mood> predictMood() async {
    // Factor 1: Time of day (fallback)
    final timeBasedMood = _getMoodByTime();
    // Factor 2: Historical patterns (primary)
    final historyBasedMood = await _getMoodByHistory();
    return historyBasedMood ?? timeBasedMood;
  }

  /// Time-based mood prediction
  static Mood _getMoodByTime() {
    final hour = DateTime.now().hour;

    if (hour >= 5 && hour < 9) {
      return Mood.tired; // Early morning: likely tired, need energy
    } else if (hour >= 9 && hour < 12) {
      return Mood.energized; // Mid-morning: productive time
    } else if (hour >= 12 && hour < 14) {
      return Mood.joyful; // Lunch: social time
    } else if (hour >= 14 && hour < 17) {
      return Mood.inspired; // Afternoon: creative period
    } else if (hour >= 17 && hour < 20) {
      return Mood.calm; // Early evening: wind down
    } else if (hour >= 20 && hour < 23) {
      return Mood.peaceful; // Night: relaxation
    } else {
      return Mood.tired; // Late night/early morning
    }
  }

  /// Historical patterns mood prediction
  static Future<Mood?> _getMoodByHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = prefs.getStringList(_moodHistoryKey);
    if (historyJson == null || historyJson.isEmpty) return null;
    // Parse history
    final history = historyJson.map((json) {
      final parts = json.split('|');
      return MoodHistoryEntry(
        mood: Mood.values.byName(parts[0]),
        timestamp: DateTime.parse(parts[1]),
      );
    }).toList();
    // Get current time context (hour + day of week)
    final now = DateTime.now();
    final currentHour = now.hour;
    final currentDay = now.weekday;
    // Find similar historical patterns
    final similarEntries = history.where((entry) {
      final hourDiff = (entry.timestamp.hour - currentHour).abs();
      final daySame = entry.timestamp.weekday == currentDay;
      return hourDiff <= 2 && daySame; // Within 2 hours, same day of week
    }).toList();
    if (similarEntries.isEmpty) return null;
    // Return most common mood in similar situations
    final moodCounts = <Mood, int>{};
    for (var entry in similarEntries) {
      moodCounts[entry.mood] = (moodCounts[entry.mood] ?? 0) + 1;
    }
    return moodCounts.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }

  /// Log mood for future predictions
  static Future<void> logMood(Mood mood) async {
    final prefs = await SharedPreferences.getInstance();
    final history = prefs.getStringList(_moodHistoryKey) ?? [];

    // Add new entry
    history.add('${mood.name}|${DateTime.now().toIso8601String()}');

    // Keep only last 100 entries
    if (history.length > 100) {
      history.removeRange(0, history.length - 100);
    }

    await prefs.setStringList(_moodHistoryKey, history);
  }

  /// Predict recipes to cache based on mood
  static List<String> getRecipesToCacheForMood(Mood mood) {
    // This returns recipe IDs that should be cached for this mood
    // Based on:
    // - Complexity (tired = simple, energized = complex)
    // - Time to prepare
    // - Category preferences

    // This would query your local DB or use heuristics
    // For now, placeholder
    return [];
  }
}

class MoodHistoryEntry {
  final Mood mood;
  final DateTime timestamp;

  MoodHistoryEntry({required this.mood, required this.timestamp});
}
