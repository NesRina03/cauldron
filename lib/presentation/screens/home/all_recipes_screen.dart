import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/potion_provider.dart';
import '../../widgets/common/loading_indicator.dart';
import '../potion_detail/potion_detail_screen.dart';
import 'widgets/potion_card.dart';

class AllRecipesScreen extends StatelessWidget {
  const AllRecipesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final potionProvider = context.watch<PotionProvider>();
    final allPotions = potionProvider.allPotions;
    final isLoading = potionProvider.isLoading;
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Recipes'),
      ),
      body: isLoading
          ? const LoadingIndicator(message: 'Loading recipes...')
          : allPotions.isEmpty
              ? const Center(child: Text('No recipes found.'))
              : GridView.builder(
                  padding: const EdgeInsets.all(20),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.75,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: allPotions.length,
                  itemBuilder: (context, index) {
                    final potion = allPotions[index];
                    return PotionCard(
                      potion: potion,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) =>
                                PotionDetailScreen(potion: potion),
                          ),
                        );
                      },
                    );
                  },
                ),
    );
  }
}
