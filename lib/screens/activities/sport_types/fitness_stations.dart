import 'package:flutter/material.dart';
import 'package:move_young/screens/activities/sport_types/generic_sport_screen.dart';

class FitnessStationsScreen extends StatelessWidget {
  const FitnessStationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const GenericSportScreen(
      title: 'Outdoor Fitness Stations',
      sportType: 'fitness',
    );
  }
}

