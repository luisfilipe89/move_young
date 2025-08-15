import 'package:flutter/material.dart';
import 'package:move_young/screens/activities/sports_screens/generic_sport_screen.dart';
import 'package:easy_localization/easy_localization.dart';

class FitnessScreen extends StatelessWidget {
  const FitnessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GenericSportScreen(
      title: 'fitness_stations'.tr(),
      sportType: 'fitness',
    );
  }
}

class FitnessDisplay {
  static final Map<String, List<dynamic>> tagIcons = {
    'lit': [Icons.lightbulb, Colors.amber],
  };
}
