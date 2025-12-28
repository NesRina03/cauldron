import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({Key? key}) : super(key: key);

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
          children: const [
            Text('Cauldron',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            Text('A magical potion brewing app to inspire your daily rituals.'),
            SizedBox(height: 16),
            Text('Version 1.0.0'),
            SizedBox(height: 32),
            Text('Developed by NesRina03'),
            SizedBox(height: 16),
            Text('Contact: nesrina@example.com'),
          ],
        ),
      ),
    );
  }
}
