import 'package:flutter/material.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_text_styles.dart';
import '../../../../data/models/potion.dart';

class BrewingSteps extends StatelessWidget {
  final List<BrewingStep> steps;

  const BrewingSteps({
    Key? key,
    required this.steps,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Brewing Steps',
          style: AppTextStyles.h3(
            color: isDark ? AppColors.textPrimary : AppColors.textPrimaryLight,
          ),
        ),
        const SizedBox(height: 12),
        ...steps.map((step) => _StepItem(
          step: step,
          isDark: isDark,
          isLast: step.number == steps.length,
        )).toList(),
      ],
    );
  }
}

class _StepItem extends StatelessWidget {
  final BrewingStep step;
  final bool isDark;
  final bool isLast;

  const _StepItem({
    required this.step,
    required this.isDark,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: isLast ? 0 : 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Step number
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDark ? AppColors.goldPrimary : AppColors.goldPrimaryLight,
            ),
            child: Center(
              child: Text(
                '${step.number}',
                style: AppTextStyles.body(
                  color: isDark ? AppColors.darkPrimary : AppColors.textPrimary,
                ).copyWith(fontWeight: FontWeight.w600),
              ),
            ),
          ),
          
          const SizedBox(width: 12),
          
          // Step content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  step.instruction,
                  style: AppTextStyles.body(
                    color: isDark ? AppColors.textPrimary : AppColors.textPrimaryLight,
                  ),
                ),
                if (step.durationMinutes != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.timer_outlined,
                        size: 16,
                        color: isDark ? AppColors.lavender : AppColors.lavenderDark,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${step.durationMinutes} min',
                        style: AppTextStyles.bodySmall(
                          color: isDark ? AppColors.lavender : AppColors.lavenderDark,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}