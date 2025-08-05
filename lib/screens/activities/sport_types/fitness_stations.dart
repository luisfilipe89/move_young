import 'package:flutter/material.dart';
import 'package:move_young/screens/activities/sport_types/generic_sport_screen.dart';
import 'package:easy_localization/easy_localization.dart';

class FitnessStationsScreen extends StatelessWidget {
  const FitnessStationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GenericSportScreen(
      title: 'fitness_stations'.tr(),
      sportType: 'fitness',
    );
  }
}
