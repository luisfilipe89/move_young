import 'package:flutter/material.dart';
import 'package:move_young/screens/activities/sports_screens/generic_sport_screen.dart';
import 'package:easy_localization/easy_localization.dart';

class SkateboardScreen extends StatelessWidget {
  const SkateboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GenericSportScreen(
      title: 'skateboarding_parks'.tr(),
      sportType: 'skateboard',
    );
  }
}

class SkateboardDisplay {
  static final Map<String, List<dynamic>> tagIcons = {
    'surface': [Icons.grass, Colors.green],
    'lit': [Icons.lightbulb, Colors.amber],
  };
}
