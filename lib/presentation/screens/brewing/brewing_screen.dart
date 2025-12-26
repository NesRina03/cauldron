import 'package:flutter/material.dart';
import '../../../data/models/potion.dart';

class BrewingScreen extends StatefulWidget {
  final Potion potion;

  const BrewingScreen({
    Key? key,
    required this.potion,
  }) : super(key: key);

  @override
  State<BrewingScreen> createState() => _BrewingScreenState();
}

class _BrewingScreenState extends State<BrewingScreen> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Brewing Steps')),
      body: Center(child: Text('Brewing steps coming soon!')),
    );
  }
}