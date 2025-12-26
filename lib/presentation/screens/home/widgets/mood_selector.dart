import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_text_styles.dart';
import '../../../../data/models/mood.dart';
import '../../../../providers/mood_provider.dart';

class MoodSelector extends StatelessWidget {
  final Function(Mood) onMoodSelected;

  const MoodSelector({
    Key? key,
    required this.onMoodSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final moodProvider = context.watch<MoodProvider>();

    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: Mood.values.length,
        itemBuilder: (context, index) {
          final mood = Mood.values[index];
          final isSelected = moodProvider.currentMood == mood;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: _MoodChip(
              mood: mood,
              isSelected: isSelected,
              isDark: isDark,
              onTap: () {
                moodProvider.setMood(mood);
                onMoodSelected(mood);
              },
            ),
          );
        },
      ),
    );
  }
}

class _MoodChip extends StatelessWidget {
  final Mood mood;
  final bool isSelected;
  final bool isDark;
  final VoidCallback onTap;

  const _MoodChip({
    required this.mood,
    required this.isSelected,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? AppColors.goldPrimary : AppColors.goldPrimaryLight)
              : (isDark ? AppColors.darkSurface : AppColors.lightSurface),
          border: Border.all(
            color: isSelected
                ? (isDark ? AppColors.goldPrimary : AppColors.goldPrimaryLight)
                : (isDark ? AppColors.lavender.withOpacity(0.3) : AppColors.lavenderDark.withOpacity(0.3)),
            width: 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              mood.emoji,
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(width: 8),
            Text(
              mood.displayName,
              style: AppTextStyles.body(
                color: isSelected
                    ? (isDark ? AppColors.darkPrimary : AppColors.textPrimary)
                    : (isDark ? AppColors.textPrimary : AppColors.textPrimaryLight),
              ).copyWith(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}