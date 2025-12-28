import 'package:flutter/material.dart';
import 'about_cauldron_screen.dart';
import 'allergies_preferences_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const CircleAvatar(
              radius: 48,
              child: Icon(Icons.person, size: 48),
            ),
            const SizedBox(height: 16),
            Text('Alchemist', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text('Welcome to your magical profile!',
                style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 32),
            ListTile(
              leading: const Icon(Icons.warning_amber_rounded),
              title: const Text('Allergies & Preferences'),
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const AllergiesPreferencesScreen()));
              },
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const AboutCauldronScreen()));
                },
                child: const Text('About Cauldron'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
