import 'package:flutter/material.dart';
import 'package:move_young/screens/activities/sports_screens/generic_sport_screen.dart';
import 'package:easy_localization/easy_localization.dart';

class SoccerScreen extends StatelessWidget {
  const SoccerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GenericSportScreen(
      title: "football_fields".tr(),
      sportType: 'soccer',
    );
  }
}

class SoccerDisplay {
  static const Map<String, IconData> tagIcons = {
    'grass': Icons.park,
    'artificial_turf': Icons.sports_soccer,
    'lit': Icons.lightbulb,
  };
}
