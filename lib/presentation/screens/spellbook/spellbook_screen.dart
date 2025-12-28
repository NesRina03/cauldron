import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../../providers/potion_provider.dart';
// import '../../../data/models/potion.dart';
import '../home/widgets/potion_card.dart';
import '../potion_detail/potion_detail_screen.dart';

class SpellbookScreen extends StatelessWidget {
  const SpellbookScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Spellbook'),
      ),
      body: const SpellbookContent(),
    );
  }
}

class SpellbookContent extends StatefulWidget {
  const SpellbookContent({Key? key}) : super(key: key);

  @override
  State<SpellbookContent> createState() => _SpellbookContentState();
}

class _SpellbookContentState extends State<SpellbookContent> {
  final List<String> _notes = [];
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final notesJson = prefs.getString('spellbook_notes');
    if (notesJson != null) {
      final decoded = List<String>.from(jsonDecode(notesJson));
      setState(() {
        _notes.clear();
        _notes.addAll(decoded);
      });
    }
  }

  Future<void> _saveNotes() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('spellbook_notes', jsonEncode(_notes));
  }

  @override
  Widget build(BuildContext context) {
    final favorites = context.watch<PotionProvider>().getFavorites();
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Your Spellbook',
              style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 16),
          // Favorite Recipes Section
          if (favorites.isNotEmpty) ...[
            Text('Favorite Recipes',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            SizedBox(
              height: 240,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                shrinkWrap: true,
                physics: const ClampingScrollPhysics(),
                itemCount: favorites.length,
                separatorBuilder: (_, __) => const SizedBox(width: 20),
                itemBuilder: (context, index) {
                  final potion = favorites[index];
                  return ConstrainedBox(
                    constraints: const BoxConstraints(
                      minWidth: 180,
                      maxWidth: 220,
                      minHeight: 220,
                      maxHeight: 240,
                    ),
                    child: PotionCard(
                      potion: potion,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => PotionDetailScreen(potion: potion),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
          ],
          // Notes Section
          Text('Your Notes', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          if (_notes.isEmpty)
            Center(
                child: Text('No notes yet. Add your magical recipes or notes!'))
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _notes.length,
              itemBuilder: (context, index) => Card(
                child: ListTile(
                  title: Text(_notes[index]),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () async {
                      setState(() {
                        _notes.removeAt(index);
                      });
                      await _saveNotes();
                    },
                  ),
                ),
              ),
            ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: const InputDecoration(hintText: 'Add a note...'),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () async {
                  final text = _controller.text.trim();
                  if (text.isNotEmpty) {
                    setState(() {
                      _notes.add(text);
                      _controller.clear();
                    });
                    await _saveNotes();
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
