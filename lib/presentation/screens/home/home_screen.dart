import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_text_styles.dart';
import '../../../providers/mood_provider.dart';
import '../../../providers/potion_provider.dart';
import '../../widgets/navigation/bottom_nav_bar.dart';
import '../../widgets/common/loading_indicator.dart';
import 'widgets/mood_selector.dart';
import 'widgets/potion_card.dart';
import '../potion_detail/potion_detail_screen.dart';
import '../pantry/pantry_screen.dart';
import '../spellbook/spellbook_screen.dart';
import '../profile/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    // Load potions on first launch
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final potionProvider = context.read<PotionProvider>();
      final moodProvider = context.read<MoodProvider>();
      
      if (potionProvider.allPotions.isEmpty) {
        potionProvider.loadPotions().then((_) {
          potionProvider.filterByMood(moodProvider.currentMood);
        });
      } else {
        potionProvider.filterByMood(moodProvider.currentMood);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          _HomeContent(),
          PantryScreen(),
          SpellbookScreen(),
          ProfileScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}

class _HomeContent extends StatelessWidget {
  const _HomeContent();

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    if (hour < 21) return 'Good evening';
    return 'Good night';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final potionProvider = context.watch<PotionProvider>();

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
            child: Text(
              '${_getGreeting()}, Alchemist',
              style: AppTextStyles.h2(
                color: isDark ? AppColors.textPrimary : AppColors.textPrimaryLight,
              ),
            ),
          ),

          // Mood Selector
          MoodSelector(
            onMoodSelected: (mood) {
              potionProvider.filterByMood(mood);
            },
          ),

          const SizedBox(height: 16),

          // Potions Grid
          Expanded(
            child: potionProvider.isLoading
                ? const LoadingIndicator(message: 'Loading potions...')
                : potionProvider.filteredPotions.isEmpty
                    ? Center(
                        child: Text(
                          'No potions found for this mood',
                          style: AppTextStyles.body(
                            color: isDark ? AppColors.textSecondary : AppColors.textSecondaryLight,
                          ),
                        ),
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 80),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.75,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                        itemCount: potionProvider.filteredPotions.length,
                        itemBuilder: (context, index) {
                          final potion = potionProvider.filteredPotions[index];
                          return PotionCard(
                            potion: potion,
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => PotionDetailScreen(potion: potion),
                                ),
                              );
                            },
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}