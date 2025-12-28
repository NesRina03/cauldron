import 'package:flutter/material.dart';

class IngredientImage extends StatelessWidget {
  final String ingredientId;
  const IngredientImage({required this.ingredientId, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final localAsset = 'assets/images/ingredients/$ingredientId.png';
    // TheMealDB expects the first letter capitalized, rest as-is (spaces replaced with %20)
    String formatted = ingredientId.replaceAll('_', ' ');
    if (formatted.isNotEmpty) {
      formatted = formatted[0].toUpperCase() + formatted.substring(1);
    }
    final networkUrl =
        'https://www.themealdb.com/images/ingredients/${Uri.encodeComponent(formatted)}.png';
    return Image.asset(
      localAsset,
      width: 40,
      height: 40,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Image.network(
          networkUrl,
          width: 40,
          height: 40,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) =>
              const Icon(Icons.image_not_supported),
        );
      },
    );
  }
}
