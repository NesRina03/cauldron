import 'package:flutter/material.dart';
import '../../../data/models/potion.dart';
import 'widgets/step_card.dart';
import 'widgets/timer_widget.dart';

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

  List<bool> _completedSteps = [];

  @override
  Widget build(BuildContext context) {
    final steps = widget.potion.steps;
    if (_completedSteps.length != steps.length) {
      _completedSteps = List<bool>.filled(steps.length, false);
    }

    return Scaffold(
      appBar: AppBar(title: Text('Brewing: ${widget.potion.name}')),
      body: PageView.builder(
        controller: _pageController,
        itemCount: steps.length,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          final step = steps[index];
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32.0),
                  child: StepCard(
                    step: step,
                    isCompleted: _completedSteps[index],
                    onComplete: () {
                      setState(() {
                        _completedSteps[index] = true;
                        if (index < steps.length - 1) {
                          _pageController.nextPage(
                              duration: const Duration(milliseconds: 500),
                              curve: Curves.easeInOut);
                        }
                      });
                    },
                  ),
                ),
              ),
              if (step.durationMinutes != null && !_completedSteps[index])
                TimerWidget(
                  durationMinutes: step.durationMinutes!,
                  onComplete: () {
                    setState(() {
                      _completedSteps[index] = true;
                      if (index < steps.length - 1) {
                        _pageController.nextPage(
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.easeInOut);
                      }
                    });
                  },
                ),
              if (_completedSteps.every((c) => c))
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Text('All steps completed! Enjoy your potion!',
                      style: Theme.of(context).textTheme.headlineSmall),
                ),
            ],
          );
        },
      ),
    );
  }
}
