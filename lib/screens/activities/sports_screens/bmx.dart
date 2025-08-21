import 'package:flutter/material.dart';
import 'package:move_young/screens/activities/sports_screens/generic_sport_screen.dart';
import 'package:easy_localization/easy_localization.dart';

class BmxScreen extends StatelessWidget {
  const BmxScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GenericSportScreen(
      title: 'bmx_parks'.tr(),
      sportType: 'bmx',
    );
  }
}

class BmxDisplay {
  static const Map<String, IconData> tagIcons = {
    'lit': Icons.lightbulb,
  };
}
