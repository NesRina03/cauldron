import 'package:flutter/material.dart';
import '../../../providers/pantry_provider.dart';
import 'package:provider/provider.dart';
import '../../widgets/common/empty_state.dart';
import '../../../data/models/ingredients.dart';

class PantryScreen extends StatelessWidget {
  const PantryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final pantryProvider = context.watch<PantryProvider>();
    final items = pantryProvider.items;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pantry'),
      ),
      body: items.isEmpty
          ? EmptyState(
              message:
                  'Your pantry is empty. Add ingredients to start brewing!')
          : ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return ListTile(
                  title: Text(item.name),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => pantryProvider.removeItem(item),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final TextEditingController controller = TextEditingController();
          await showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text('Add Ingredient'),
                content: TextField(
                  controller: controller,
                  decoration:
                      const InputDecoration(hintText: 'Ingredient name'),
                  autofocus: true,
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      final name = controller.text.trim();
                      if (name.isNotEmpty) {
                        pantryProvider.addItem(
                          Ingredient(
                              id: name,
                              name: name,
                              amount: '',
                              isInPantry: true),
                        );
                        Navigator.pop(context);
                      }
                    },
                    child: const Text('Add'),
                  ),
                ],
              );
            },
          );
        },
        child: const Icon(Icons.add),
        tooltip: 'Add Ingredient',
      ),
    );
  }
}
