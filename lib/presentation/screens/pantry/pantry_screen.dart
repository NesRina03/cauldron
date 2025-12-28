import 'package:flutter/material.dart';
import '../../../providers/pantry_provider.dart';
import '../../../providers/potion_provider.dart';
import 'package:provider/provider.dart';
import '../../widgets/common/empty_state.dart';
import '../../../data/models/ingredients.dart';
import 'ingredient_image.dart';

class PantryScreen extends StatelessWidget {
  const PantryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final pantryProvider = context.watch<PantryProvider>();
    final potionProvider = context.watch<PotionProvider>();
    // Gather all unique ingredients from all recipes
    final allIngredients = <String, Ingredient>{};
    for (final potion in potionProvider.allPotions) {
      for (final ing in potion.ingredients) {
        allIngredients[ing.id] = ing;
      }
    }

    // Pantry state: ingredientId -> quantity/unit
    final Map<String, double> ingredientQuantities = {
      for (final item in pantryProvider.items) item.id: item.quantity
    };
    final Map<String, String> ingredientUnits = {
      for (final item in pantryProvider.items) item.id: item.unit
    };

    // Filter and search state
    final filterOptions = ['All', 'Available', 'Not Available'];
    final filterNotifier = ValueNotifier<String>('All');
    final searchController = TextEditingController();
    final searchNotifier = ValueNotifier<String>('');

    List<Ingredient> filteredIngredients() {
      final list = allIngredients.values.toList();
      final filter = filterNotifier.value;
      final search = searchNotifier.value.trim().toLowerCase();
      List<Ingredient> filtered = list;
      if (filter == 'Available') {
        filtered = filtered
            .where((i) => (ingredientQuantities[i.id] != null &&
                ingredientQuantities[i.id]! > 0))
            .toList();
      } else if (filter == 'Not Available') {
        filtered = filtered
            .where((i) => (ingredientQuantities[i.id] == null ||
                ingredientQuantities[i.id] == 0))
            .toList();
      }
      if (search.isNotEmpty) {
        filtered = filtered
            .where((i) => i.name.toLowerCase().contains(search))
            .toList();
      }
      filtered
          .sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
      return filtered;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pantry'),
      ),
      body: ValueListenableBuilder<String>(
        valueListenable: filterNotifier,
        builder: (context, filter, _) {
          return ValueListenableBuilder<String>(
            valueListenable: searchNotifier,
            builder: (context, search, __) {
              final ingredients = filteredIngredients();
              return Column(
                children: [
                  // Search bar at the top
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 16, 12, 8),
                    child: TextField(
                      controller: searchController,
                      decoration: const InputDecoration(
                        hintText: 'Search ingredients...',
                        isDense: true,
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (val) => searchNotifier.value = val,
                    ),
                  ),
                  // Filter tags as chips
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    child: Row(
                      children: [
                        ...filterOptions.map((f) => Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: ChoiceChip(
                                label: Text(f),
                                selected: filter == f,
                                onSelected: (selected) {
                                  if (selected) filterNotifier.value = f;
                                },
                              ),
                            )),
                      ],
                    ),
                  ),
                  // Ingredient list
                  Expanded(
                    child: ingredients.isEmpty
                        ? EmptyState(
                            message: 'No ingredients found for this filter.')
                        : ListView.separated(
                            itemCount: ingredients.length,
                            separatorBuilder: (_, __) =>
                                const Divider(height: 1),
                            itemBuilder: (context, index) {
                              final ing = ingredients[index];
                              final quantity =
                                  ingredientQuantities[ing.id] ?? 0.0;
                              String unit = ingredientUnits[ing.id] ?? '';
                              // Set sensible default units for common ingredients
                              if (unit.isEmpty) {
                                final name = ing.name.toLowerCase();
                                if (name.contains('water') ||
                                    name.contains('milk') ||
                                    name.contains('oil') ||
                                    name.contains('juice')) {
                                  unit = 'ml';
                                } else if (name.contains('flour') ||
                                    name.contains('sugar') ||
                                    name.contains('salt') ||
                                    name.contains('powder') ||
                                    name.contains('rice') ||
                                    name.contains('yeast')) {
                                  unit = 'g';
                                } else if (name.contains('egg')) {
                                  unit = 'pcs';
                                } else if (name.contains('butter') ||
                                    name.contains('cheese')) {
                                  unit = 'g';
                                } else if (name.contains('tea') ||
                                    name.contains('spice') ||
                                    name.contains('herb')) {
                                  unit = 'tsp';
                                } else if (name.contains('onion') ||
                                    name.contains('garlic') ||
                                    name.contains('carrot') ||
                                    name.contains('potato')) {
                                  unit = 'pcs';
                                } else {
                                  unit = '';
                                }
                              }
                              final textController = TextEditingController(
                                  text: quantity.toString());
                              final List<String> unitOptions = [
                                'g',
                                'kg',
                                'ml',
                                'l',
                                'tsp',
                                'tbsp',
                                'cup',
                                'pcs',
                                'pinch',
                                'clove',
                                'slice',
                                'can',
                                'pack',
                                'oz',
                                'lb',
                                ''
                              ];
                              return ListTile(
                                leading: ing.id.isNotEmpty
                                    ? IngredientImage(ingredientId: ing.id)
                                    : const Icon(Icons.image),
                                title: Text(ing.name),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                        'Substitutes: ${ing.substitutes.isNotEmpty ? ing.substitutes.join(", ") : "None"}'),
                                    Row(
                                      children: [
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            IconButton(
                                              icon: const Icon(Icons.remove,
                                                  size: 18),
                                              onPressed: () {
                                                double newQty = (quantity - 1)
                                                    .clamp(0, 1000);
                                                pantryProvider.addItem(
                                                  ing.copyWith(
                                                      quantity: newQty,
                                                      unit: unit,
                                                      isInPantry: newQty > 0),
                                                );
                                                searchNotifier.value =
                                                    searchNotifier.value;
                                              },
                                              tooltip: 'Decrease',
                                            ),
                                            SizedBox(
                                              width: 80,
                                              child: TextFormField(
                                                controller: textController,
                                                keyboardType:
                                                    const TextInputType
                                                        .numberWithOptions(
                                                        decimal: true),
                                                decoration:
                                                    const InputDecoration(
                                                  labelText: 'Qty',
                                                  isDense: true,
                                                ),
                                                onFieldSubmitted: (val) {
                                                  double newQty =
                                                      double.tryParse(val) ?? 0;
                                                  newQty =
                                                      newQty.clamp(0, 1000);
                                                  pantryProvider.addItem(
                                                    ing.copyWith(
                                                        quantity: newQty,
                                                        unit: unit,
                                                        isInPantry: newQty > 0),
                                                  );
                                                  searchNotifier.value =
                                                      searchNotifier.value;
                                                },
                                                onChanged: (val) {
                                                  double newQty =
                                                      double.tryParse(val) ?? 0;
                                                  newQty =
                                                      newQty.clamp(0, 1000);
                                                  pantryProvider.addItem(
                                                    ing.copyWith(
                                                        quantity: newQty,
                                                        unit: unit,
                                                        isInPantry: newQty > 0),
                                                  );
                                                },
                                              ),
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.add,
                                                  size: 18),
                                              onPressed: () {
                                                double newQty = (quantity + 1)
                                                    .clamp(0, 1000);
                                                pantryProvider.addItem(
                                                  ing.copyWith(
                                                      quantity: newQty,
                                                      unit: unit,
                                                      isInPantry: newQty > 0),
                                                );
                                                searchNotifier.value =
                                                    searchNotifier.value;
                                              },
                                              tooltip: 'Increase',
                                            ),
                                          ],
                                        ),
                                        const SizedBox(width: 8),
                                        DropdownButton<String>(
                                          value: unitOptions.contains(unit)
                                              ? unit
                                              : '',
                                          items: unitOptions
                                              .map((u) => DropdownMenuItem(
                                                    value: u,
                                                    child: Text(
                                                        u.isEmpty ? '-' : u),
                                                  ))
                                              .toList(),
                                          onChanged: (selectedUnit) {
                                            pantryProvider.addItem(
                                              ing.copyWith(
                                                  quantity: quantity,
                                                  unit: selectedUnit ?? '',
                                                  isInPantry: quantity > 0),
                                            );
                                          },
                                          underline: Container(
                                              height: 1,
                                              color: Colors.grey[300]),
                                          style: const TextStyle(
                                              fontSize: 14,
                                              color: Colors.black),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete),
                                          onPressed: () {
                                            pantryProvider.addItem(
                                              ing.copyWith(
                                                  quantity: 0,
                                                  unit: unit,
                                                  isInPantry: false),
                                            );
                                            searchNotifier.value =
                                                searchNotifier.value;
                                          },
                                          tooltip: 'Reset to 0',
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
