import 'package:flutter/material.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_text_styles.dart';
import '../../../../data/models/potion.dart';

class StepCard extends StatelessWidget {
  final BrewingStep step;
  final bool isCompleted;
  final VoidCallback onComplete;

  const StepCard({
    Key? key,
    required this.step,
    required this.isCompleted,
    required this.onComplete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(24),
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: (isDark ? AppColors.darkElevated : AppColors.lightSurface).withOpacity(0.9),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Step number badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: isDark ? AppColors.goldPrimary : AppColors.goldPrimaryLight,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Step ${step.number}',
              style: AppTextStyles.caption(
                color: isDark ? AppColors.darkPrimary : AppColors.textPrimary,
              ).copyWith(fontWeight: FontWeight.w600),
            ),
          ),

          const SizedBox(height: 16),

          // Instruction
          Text(
            step.instruction,
            style: AppTextStyles.bodyLarge(
              color: isDark ? AppColors.textPrimary : AppColors.textPrimaryLight,
            ),
          ),

          if (step.durationMinutes != null) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.timer_outlined,
                  size: 18,
                  color: isDark ? AppColors.lavender : AppColors.lavenderDark,
                ),
                const SizedBox(width: 6),
                Text(
                  '${step.durationMinutes} minutes',
                  style: AppTextStyles.body(
                    color: isDark ? AppColors.lavender : AppColors.lavenderDark,
                  ),
                ),
              ],
            ),
          ],

          const SizedBox(height: 20),

          // Complete button
          if (!isCompleted)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: onComplete,
                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                    color: isDark ? AppColors.goldPrimary : AppColors.goldPrimaryLight,
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Mark Complete',
                  style: TextStyle(
                    color: isDark ? AppColors.goldPrimary : AppColors.goldPrimaryLight,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            )
          else
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.check_circle, color: AppColors.success, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Completed',
                  style: AppTextStyles.body(color: AppColors.success).copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}