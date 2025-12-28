import 'package:flutter/material.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_text_styles.dart';
import '../../../../data/models/potion.dart';
import 'package:provider/provider.dart';
import '../../../../providers/potion_provider.dart';
import 'package:shimmer/shimmer.dart';

class PotionCard extends StatelessWidget {
  final Potion potion;
  final VoidCallback onTap;

  const PotionCard({
    Key? key,
    required this.potion,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image with hero and shimmer, plus overlays
            Stack(
              children: [
                Hero(
                  tag: 'potion-image-${potion.id}',
                  child: potion.imageUrl != null &&
                          (potion.imageUrl?.isNotEmpty ?? false)
                      ? ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(12)),
                          child: Image.network(
                            potion.imageUrl!,
                            height: 120,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, progress) {
                              if (progress == null) return child;
                              return Shimmer.fromColors(
                                baseColor: Colors.grey[300]!,
                                highlightColor: Colors.grey[100]!,
                                child: Container(
                                  height: 120,
                                  color: Colors.grey[300],
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                              height: 120,
                              color: Colors.grey[200],
                              child: const Icon(Icons.broken_image,
                                  size: 50, color: Colors.grey),
                            ),
                          ),
                        )
                      : Container(
                          height: 120,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                AppColors.darkSecondary,
                                AppColors.darkElevated,
                              ],
                            ),
                            borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(12)),
                          ),
                          child: Center(
                            child: Icon(
                              Icons.science_outlined,
                              size: 50,
                              color: AppColors.goldPrimary.withOpacity(0.5),
                            ),
                          ),
                        ),
                ),
                // Quick brew badge
                if (potion.prepTimeMinutes <= 10)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.goldPrimary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.bolt,
                              size: 12, color: AppColors.darkPrimary),
                          const SizedBox(width: 4),
                          Text(
                            'Quick',
                            style: AppTextStyles.caption(
                                    color: AppColors.darkPrimary)
                                .copyWith(fontSize: 10),
                          ),
                        ],
                      ),
                    ),
                  ),
                // Cached indicator
                if (potion.isCached)
                  Positioned(
                    bottom: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Icon(
                        Icons.cloud_done,
                        size: 12,
                        color: AppColors.goldPrimary,
                      ),
                    ),
                  ),
                // Favorite button
                Positioned(
                  top: 8,
                  left: 8,
                  child: Consumer<PotionProvider>(
                    builder: (context, provider, _) => GestureDetector(
                      onTap: () => provider.toggleFavorite(potion.id),
                      child: Icon(
                        potion.isFavorite
                            ? Icons.favorite
                            : Icons.favorite_border,
                        color: potion.isFavorite ? Colors.red : Colors.grey,
                        size: 22,
                        semanticLabel:
                            potion.isFavorite ? 'Unfavorite' : 'Favorite',
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      potion.name,
                      style: AppTextStyles.h3(
                        color: isDark
                            ? AppColors.textPrimary
                            : AppColors.textPrimaryLight,
                      ).copyWith(fontSize: 16),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        // Difficulty stars
                        ...List.generate(
                          potion.difficulty.stars,
                          (index) => const Icon(
                            Icons.star,
                            size: 12,
                            color: AppColors.goldPrimary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Time
                        Text(
                          '${potion.prepTimeMinutes} min',
                          style: AppTextStyles.caption(
                            color: isDark
                                ? AppColors.lavender
                                : AppColors.lavenderDark,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    // Category badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: (isDark
                                ? AppColors.lavender
                                : AppColors.lavenderDark)
                            .withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        potion.category.displayName,
                        style: AppTextStyles.caption(
                          color: isDark
                              ? AppColors.lavender
                              : AppColors.lavenderDark,
                        ).copyWith(fontSize: 10),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
