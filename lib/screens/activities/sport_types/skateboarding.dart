import 'package:flutter/material.dart';
import 'package:move_young/screens/activities/sport_types/generic_sport_screen.dart';

class SkateboardingScreen extends StatelessWidget {
  const SkateboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const GenericSportScreen(
      title: 'Skateboarding Parks',
      sportType: 'skateboard',
    );
  }
}

