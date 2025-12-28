import 'package:flutter/material.dart';

class AboutCauldronScreen extends StatelessWidget {
  const AboutCauldronScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About Cauldron'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'About Cauldron',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            const Text(
              'This is a project made under the BuildIT competition, an internal mini Hackathon of the IT section in Micro Club.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            const Text(
              'Cauldron is a smart recipe and potion app that helps you discover, filter, and manage magical recipes based on your mood, pantry, allergies, and food preferences. It features advanced filtering, allergy/preference tagging, and a beautiful, intuitive UI. The app is built under the theme of caching algorithms, ensuring fast access to your favorite recipes and a seamless user experience.',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
