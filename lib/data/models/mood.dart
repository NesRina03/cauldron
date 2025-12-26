enum Mood {
  energized,
  calm,
  inspired,
  strong,
  joyful,
  tired,
  peaceful;

  String get displayName {
    switch (this) {
      case Mood.energized:
        return 'Energized';
      case Mood.calm:
        return 'Calm';
      case Mood.inspired:
        return 'Inspired';
      case Mood.strong:
        return 'Strong';
      case Mood.joyful:
        return 'Joyful';
      case Mood.tired:
        return 'Tired';
      case Mood.peaceful:
        return 'Peaceful';
    }
  }

  String get emoji {
    switch (this) {
      case Mood.energized:
        return '⚡';
      case Mood.calm:
        return '🌙';
      case Mood.inspired:
        return '✨';
      case Mood.strong:
        return '💪';
      case Mood.joyful:
        return '🌸';
      case Mood.tired:
        return '😴';
      case Mood.peaceful:
        return '💙';
    }
  }
}
