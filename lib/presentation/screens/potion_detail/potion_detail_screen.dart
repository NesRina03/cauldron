import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_text_styles.dart';
import '../../../data/models/potion.dart';
import '../../../providers/potion_provider.dart';
import '../../widgets/common/custom_button.dart';
import 'widgets/ingredients_list.dart';
import 'widgets/brewing_steps.dart';
import '../brewing/brewing_screen.dart';

class PotionDetailScreen extends StatelessWidget {
  final Potion potion;

  const PotionDetailScreen({
    Key? key,
    required this.potion,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final potionProvider = context.watch<PotionProvider>();
    final currentPotion = potionProvider.getPotionById(potion.id) ?? potion;

    return Scaffold(
      body: Stack(
        children: [
          // Content
          CustomScrollView(
            slivers: [
              // Hero Image
              SliverAppBar(
                expandedHeight: 280,
                pinned: true,
                backgroundColor: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
                leading: IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black.withOpacity(0.5),
                    ),
                    child: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
                actions: [
                  IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.black.withOpacity(0.5),
                      ),
                      child: Icon(
                        currentPotion.isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: currentPotion.isFavorite ? AppColors.goldPrimary : Colors.white,
                      ),
                    ),
                    onPressed: () {
                      potionProvider.toggleFavorite(currentPotion.id);
                    },
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.darkSecondary,
                          AppColors.darkElevated,
                        ],
                      ),
                    ),
                    child: Stack(
                      children: [
                        Center(
                          child: Icon(
                            Icons.science_outlined,
                            size: 100,
                            color: AppColors.goldPrimary.withOpacity(0.3),
                          ),
                        ),
                        // Gradient overlay
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          height: 100,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  (isDark ? AppColors.darkPrimary : AppColors.lightPrimary).withOpacity(0.9),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Content
              SliverToBoxAdapter(
                child: Container(
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title & Info
                        Text(
                          currentPotion.name,
                          style: AppTextStyles.h1(
                            color: isDark ? AppColors.textPrimary : AppColors.textPrimaryLight,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '(${currentPotion.realName})',
                          style: AppTextStyles.body(
                            color: isDark ? AppColors.lavender : AppColors.lavenderDark,
                          ).copyWith(fontStyle: FontStyle.italic),
                        ),
                        
                        const SizedBox(height: 12),
                        
                        // Metadata
                        Row(
                          children: [
                            // Difficulty stars
                            ...List.generate(
                              currentPotion.difficulty.stars,
                              (index) => const Icon(
                                Icons.star,
                                size: 16,
                                color: AppColors.goldPrimary,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '•',
                              style: TextStyle(
                                color: isDark ? AppColors.lavender : AppColors.lavenderDark,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${currentPotion.prepTimeMinutes} min',
                              style: AppTextStyles.body(
                                color: isDark ? AppColors.lavender : AppColors.lavenderDark,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '•',
                              style: TextStyle(
                                color: isDark ? AppColors.lavender : AppColors.lavenderDark,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${currentPotion.servings} serving${currentPotion.servings > 1 ? 's' : ''}',
                              style: AppTextStyles.body(
                                color: isDark ? AppColors.lavender : AppColors.lavenderDark,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: (isDark ? AppColors.lavender : AppColors.lavenderDark).withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                currentPotion.category.displayName,
                                style: AppTextStyles.caption(
                                  color: isDark ? AppColors.lavender : AppColors.lavenderDark,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // Description
                        Text(
                          currentPotion.description,
                          style: AppTextStyles.bodyLarge(
                            color: isDark ? AppColors.textSecondary : AppColors.textSecondaryLight,
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Benefits
                        if (currentPotion.benefits.isNotEmpty) ...[
                          Text(
                            'Benefits',
                            style: AppTextStyles.h3(
                              color: isDark ? AppColors.textPrimary : AppColors.textPrimaryLight,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: currentPotion.benefits.map((benefit) => Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: (isDark ? AppColors.lavender : AppColors.lavenderDark).withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                benefit,
                                style: AppTextStyles.caption(
                                  color: isDark ? AppColors.lavender : AppColors.lavenderDark,
                                ),
                              ),
                            )).toList(),
                          ),
                          const SizedBox(height: 24),
                        ],

                        // Ingredients
                        IngredientsList(ingredients: currentPotion.ingredients),

                        const SizedBox(height: 24),

                        // Brewing Steps
                        BrewingSteps(steps: currentPotion.steps),

                        const SizedBox(height: 100), // Space for button
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Fixed bottom button
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: (isDark ? AppColors.darkElevated : AppColors.lightSurface).withOpacity(0.95),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                child: CustomButton(
                  text: 'Start Brewing',
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => BrewingScreen(potion: currentPotion),
                      ),
                    );
                  },
                  width: double.infinity,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}