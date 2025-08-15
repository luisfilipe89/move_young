import 'package:flutter/material.dart';
import 'package:move_young/screens/activities/sports_screens/generic_sport_screen.dart';
import 'package:easy_localization/easy_localization.dart';

class BeachVolleyBallScreen extends StatelessWidget {
  const BeachVolleyBallScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GenericSportScreen(
      title: 'beachvolleyball'.tr(),
      sportType: 'beachvolleyball',
    );
  }
}

class BeachVolleyBallDisplay {
  static final Map<String, List<dynamic>> tagIcons = {
    'lit': [Icons.lightbulb, Colors.amber],
  };
}
