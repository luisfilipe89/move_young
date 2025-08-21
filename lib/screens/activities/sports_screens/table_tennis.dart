import 'package:flutter/material.dart';
import 'package:move_young/screens/activities/sports_screens/generic_sport_screen.dart';
import 'package:easy_localization/easy_localization.dart';

class TableTennisScreen extends StatelessWidget {
  const TableTennisScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GenericSportScreen(
      title: 'table_tennis_areas'.tr(),
      sportType: 'table_tennis',
    );
  }
}

class TableTennisDisplay {
  static const Map<String, IconData> tagIcons = {
    'lit': Icons.lightbulb,
  };
}
