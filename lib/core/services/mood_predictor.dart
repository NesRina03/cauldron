import '../../data/models/mood.dart';

class MoodPredictor {
  // ...existing code from utils/mood_predictor.dart...
}

class MoodHistoryEntry {
  final Mood mood;
  final DateTime timestamp;

  MoodHistoryEntry({required this.mood, required this.timestamp});
}
