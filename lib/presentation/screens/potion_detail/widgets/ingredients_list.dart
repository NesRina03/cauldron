import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_text_styles.dart';
import '../../../../data/models/ingredients.dart';
import '../../../../providers/pantry_provider.dart';

class IngredientsList extends StatelessWidget {
  final List<Ingredient> ingredients;

  const IngredientsList({
    Key? key,
    required this.ingredients,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final pantryProvider = context.watch<PantryProvider>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ingredients',
          style: AppTextStyles.h3(
            color: isDark ? AppColors.textPrimary : AppColors.textPrimaryLight,
          ),
        ),
        const SizedBox(height: 12),
        ...ingredients.map((ingredient) {
          final hasIngredient = pantryProvider.hasIngredient(ingredient.id);

          return _IngredientItem(
            ingredient: ingredient,
            hasIngredient: hasIngredient,
            isDark: isDark,
            onToggle: () {
              pantryProvider.toggleIngredient(ingredient.id);
            },
            onShowSubstitutes: ingredient.substitutes.isNotEmpty
                ? () => _showSubstitutesModal(context, ingredient, isDark)
                : null,
          );
        }).toList(),
      ],
    );
  }

  void _showSubstitutesModal(
      BuildContext context, Ingredient ingredient, bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.darkElevated : AppColors.lightSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Substitute for ${ingredient.name}',
              style: AppTextStyles.h3(
                color:
                    isDark ? AppColors.textPrimary : AppColors.textPrimaryLight,
              ),
            ),
            const SizedBox(height: 16),
            ...ingredient.substitutes
                .map((substitute) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.swap_horiz,
                          color: AppColors.goldPrimary),
                      title: Text(
                        substitute,
                        style: AppTextStyles.body(
                          color: isDark
                              ? AppColors.textPrimary
                              : AppColors.textPrimaryLight,
                        ),
                      ),
                      trailing: TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          'Use this',
                          style: TextStyle(
                            color: isDark
                                ? AppColors.goldPrimary
                                : AppColors.goldPrimaryLight,
                          ),
                        ),
                      ),
                    ))
                .toList(),
          ],
        ),
      ),
    );
  }
}

class _IngredientItem extends StatelessWidget {
  final Ingredient ingredient;
  final bool hasIngredient;
  final bool isDark;
  final VoidCallback onToggle;
  final VoidCallback? onShowSubstitutes;

  const _IngredientItem({
    required this.ingredient,
    required this.hasIngredient,
    required this.isDark,
    required this.onToggle,
    this.onShowSubstitutes,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(
          color: isDark
              ? AppColors.lavender.withOpacity(0.2)
              : AppColors.lavenderDark.withOpacity(0.2),
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          // Checkbox
          GestureDetector(
            onTap: onToggle,
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: hasIngredient
                      ? AppColors.goldPrimary
                      : AppColors.lavender,
                  width: 2,
                ),
                color:
                    hasIngredient ? AppColors.goldPrimary : Colors.transparent,
              ),
              child: hasIngredient
                  ? const Icon(Icons.check,
                      size: 16, color: AppColors.darkPrimary)
                  : null,
            ),
          ),

          const SizedBox(width: 12),

          // Ingredient info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ingredient.name,
                  style: AppTextStyles.body(
                    color: isDark
                        ? AppColors.textPrimary
                        : AppColors.textPrimaryLight,
                  ).copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(
                  (ingredient.quantity > 0
                          ? ingredient.quantity.toString()
                          : '') +
                      (ingredient.unit.isNotEmpty ? ' ${ingredient.unit}' : ''),
                  style: AppTextStyles.bodySmall(
                    color: isDark ? AppColors.lavender : AppColors.lavenderDark,
                  ),
                ),
              ],
            ),
          ),

          // Substitute button or checkmark
          if (onShowSubstitutes != null)
            TextButton(
              onPressed: onShowSubstitutes,
              style: TextButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              ),
              child: Text(
                'Substitutes',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark
                      ? AppColors.goldPrimary
                      : AppColors.goldPrimaryLight,
                ),
              ),
            )
          else if (hasIngredient)
            const Icon(Icons.check_circle,
                color: AppColors.goldPrimary, size: 20),
        ],
      ),
    );
  }
}
