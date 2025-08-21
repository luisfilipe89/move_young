import 'package:flutter/material.dart';
import 'package:move_young/screens/activities/sports_screens/generic_sport_screen.dart';
import 'package:easy_localization/easy_localization.dart';

class SkateboardScreen extends StatelessWidget {
  const SkateboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GenericSportScreen(
      title: 'skateboard_parks'.tr(),
      sportType: 'skateboard',
    );
  }
}

class SkateboardDisplay {
  static const Map<String, IconData> tagIcons = {
    'lit': Icons.lightbulb,
  };
}
