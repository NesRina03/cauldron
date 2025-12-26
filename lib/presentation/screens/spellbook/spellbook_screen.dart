import 'package:flutter/material.dart';

class SpellbookScreen extends StatelessWidget {
  const SpellbookScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Spellbook'),
      ),
      body: Center(
        child: Text(
          'Your spellbook is empty. Add favorite recipes or notes!',
          style: Theme.of(context).textTheme.bodyLarge,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
