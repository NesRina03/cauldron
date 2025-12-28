import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.palette),
            title: const Text('Theme'),
            subtitle: const Text('Switch between light and dark mode'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('About'),
            subtitle: const Text('Learn more about Cauldron'),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
