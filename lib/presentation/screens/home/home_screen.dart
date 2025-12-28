import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_text_styles.dart';
import '../../../providers/mood_provider.dart';
import '../../../providers/potion_provider.dart';
import '../../../providers/theme_provider.dart';
import '../../../data/models/potion.dart';
import '../../../data/models/mood.dart';
import '../../../core/utils/cache_manager.dart';
import '../../widgets/navigation/bottom_nav_bar.dart';
import '../../widgets/common/loading_indicator.dart';
import 'widgets/potion_card.dart';
import 'widgets/preferences_filter_chips.dart';
import '../potion_detail/potion_detail_screen.dart';
import '../pantry/pantry_screen.dart';
import '../spellbook/spellbook_screen.dart';
import '../profile/profile_screen.dart';
import 'all_recipes_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  int _selectedCategoryIndex = 3;

  @override
  void initState() {
    super.initState();
    // Load potions on first launch
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final potionProvider = context.read<PotionProvider>();
      final moodProvider = context.read<MoodProvider>();

      if (potionProvider.allPotions.isEmpty) {
        potionProvider.loadPotions().then((_) {
          if (moodProvider.currentMood != null) {
            potionProvider.filterByMood(moodProvider.currentMood!);
          } else {
            potionProvider.resetFilters();
          }
        });
      } else {
        if (moodProvider.currentMood != null) {
          potionProvider.filterByMood(moodProvider.currentMood!);
        } else {
          potionProvider.resetFilters();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _HomeContent(
            searchController: _searchController,
            selectedCategoryIndex: _selectedCategoryIndex,
            onCategoryChanged: (idx) =>
                setState(() => _selectedCategoryIndex = idx),
          ),
          const PantryScreen(),
          const SpellbookScreen(),
          const ProfileScreen(),
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

class _HomeContent extends StatefulWidget {
  final TextEditingController searchController;
  final int selectedCategoryIndex;
  final void Function(int) onCategoryChanged;
  const _HomeContent({
    Key? key,
    required this.searchController,
    required this.selectedCategoryIndex,
    required this.onCategoryChanged,
  }) : super(key: key);

  @override
  State<_HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<_HomeContent> {
  String? _selectedPreference;

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
    final themeProvider = context.watch<ThemeProvider>();
    final categories = [
      PotionCategory.meal,
      PotionCategory.drink,
      PotionCategory.dessert,
    ];

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${_getGreeting()}, Alchemist',
                  style: AppTextStyles.h2(
                    color: isDark
                        ? AppColors.textPrimary
                        : AppColors.textPrimaryLight,
                  ),
                ),
                IconButton(
                  icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
                  tooltip: 'Toggle Theme',
                  onPressed: () => themeProvider.toggleTheme(),
                ),
              ],
            ),
          ),

          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              controller: widget.searchController,
              decoration: InputDecoration(
                hintText: 'Search recipes...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: widget.searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          widget.searchController.clear();
                          // Re-apply mood/category filter only
                          final mood = context.read<MoodProvider>().currentMood;
                          final category = widget.selectedCategoryIndex < 3
                              ? categories[widget.selectedCategoryIndex]
                              : null;
                          potionProvider.filterByMoodAndCategory(
                              mood: mood, category: category);
                          setState(() {});
                        },
                      )
                    : null,
              ),
              onChanged: (val) {
                final mood = context.read<MoodProvider>().currentMood;
                final category = widget.selectedCategoryIndex < 3
                    ? categories[widget.selectedCategoryIndex]
                    : null;
                potionProvider.searchAndFilter(
                    query: val, mood: mood, category: category);
                setState(() {});
              },
            ),
          ),

          // Mood Categories (horizontal selector)
          SizedBox(
            height: 56,
            child: Consumer<MoodProvider>(
              builder: (context, moodProvider, _) => ListView(
                scrollDirection: Axis.horizontal,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                children: Mood.values
                    .map((mood) => Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: ChoiceChip(
                            label: Text(mood.displayName),
                            selected: moodProvider.currentMood == mood,
                            onSelected: (_) {
                              if (moodProvider.currentMood == mood) {
                                // Deselect mood: filter only by category
                                moodProvider.setMood(null);
                                potionProvider.filterByMoodAndCategory(
                                  category: widget.selectedCategoryIndex < 3
                                      ? categories[widget.selectedCategoryIndex]
                                      : null,
                                );
                              } else {
                                moodProvider.setMood(mood);
                                potionProvider.filterByMood(mood);
                              }
                              setState(() {});
                            },
                          ),
                        ))
                    .toList(),
              ),
            ),
          ),

          // Recipe Categories (horizontal selector)
          SizedBox(
            height: 56,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              children: [
                ...categories.asMap().entries.map((entry) => Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: ChoiceChip(
                        label: Text(entry.value.displayName),
                        selected: widget.selectedCategoryIndex == entry.key,
                        onSelected: (_) {
                          widget.onCategoryChanged(entry.key);
                          final mood = context.read<MoodProvider>().currentMood;
                          potionProvider.filterByMoodAndCategory(
                              mood: mood, category: entry.value);
                          setState(() {});
                        },
                      ),
                    )),
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: ChoiceChip(
                    label: const Text('See All'),
                    selected: widget.selectedCategoryIndex == 3,
                    onSelected: (_) {
                      widget.onCategoryChanged(3);
                      potionProvider.resetFilters();
                      setState(() {});
                    },
                  ),
                ),
              ],
            ),
          ),

          // User Preferences Filter (if any)
          PreferencesFilterChips(
            selectedPreference: _selectedPreference,
            onFilterChanged: (pref) {
              setState(() {
                _selectedPreference = pref;
                final mood = context.read<MoodProvider>().currentMood;
                final category = widget.selectedCategoryIndex < 3
                    ? categories[widget.selectedCategoryIndex]
                    : null;
                if (pref == null) {
                  // No preference filter, use mood/category/search
                  final query = widget.searchController.text;
                  if (query.isNotEmpty) {
                    potionProvider.searchAndFilter(
                        query: query, mood: mood, category: category);
                  } else {
                    potionProvider.filterByMoodAndCategory(
                        mood: mood, category: category);
                  }
                } else {
                  // Use new public filterByPreference method
                  potionProvider.filterByPreference(
                    preference: pref,
                    mood: mood,
                    category: category,
                  );
                }
              });
            },
          ),

          // All Recipes Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.menu_book),
                label: const Text('View All Recipes'),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const AllRecipesScreen(),
                    ),
                  );
                },
              ),
            ),
          ),

          // Most Accessed Recipes (horizontal list)
          FutureBuilder<Map<String, dynamic>>(
            future: CacheManager.getCacheStats(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const SizedBox.shrink();
              final stats = snapshot.data!;
              final mostAccessed =
                  (stats['mostAccessedRecipes'] as List?)?.cast<Potion>() ?? [];
              if (mostAccessed.isEmpty) return const SizedBox.shrink();
              return SizedBox(
                height: 180,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  itemCount: mostAccessed.length,
                  itemBuilder: (context, index) {
                    final potion = mostAccessed[index];
                    return Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: PotionCard(
                        potion: potion,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) =>
                                  PotionDetailScreen(potion: potion),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              );
            },
          ),

          const SizedBox(height: 16),

          // Potions Grid with AnimatedSwitcher
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              switchInCurve: Curves.easeInOut,
              switchOutCurve: Curves.easeInOut,
              child: potionProvider.isLoading
                  ? const LoadingIndicator(message: 'Loading potions...')
                  : potionProvider.filteredPotions.isEmpty
                      ? Center(
                          key: const ValueKey('empty'),
                          child: Text(
                            'No potions found for this mood',
                            style: AppTextStyles.body(
                              color: isDark
                                  ? AppColors.textSecondary
                                  : AppColors.textSecondaryLight,
                            ),
                          ),
                        )
                      : GridView.builder(
                          key: ValueKey(potionProvider.filteredPotions
                              .map((p) => p.id)
                              .join(',')),
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 80),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.75,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                          ),
                          itemCount: potionProvider.filteredPotions.length,
                          itemBuilder: (context, index) {
                            final potion =
                                potionProvider.filteredPotions[index];
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
            ),
          ),
        ],
      ),
    );
  }
}
