import 'package:flutter/material.dart';
import 'package:move_young/screens/activities/sports_screens/generic_sport_screen.dart';
import 'package:easy_localization/easy_localization.dart';

class MotocrossScreen extends StatelessWidget {
  const MotocrossScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GenericSportScreen(
      title: 'canoing'.tr(),
      sportType: 'canoe',
    );
  }
}

class MotocrossDisplay {
  static final Map<String, List<dynamic>> tagIcons = {
    'lit': [Icons.lightbulb, Colors.amber],
  };
}
