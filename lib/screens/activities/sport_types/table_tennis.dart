import 'package:flutter/material.dart';
import 'package:move_young/screens/activities/sport_types/generic_sport_screen.dart';
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
  static final Map<String, List<dynamic>> tagIcons = {
    'indoor': [Icons.home, Colors.blue],
    'covered': [Icons.roofing, Colors.blue],
  };

  static String formatValue(String key, String? value) {
    switch (key) {
      case 'indoor':
        if (value == 'yes') return 'Indoor';
        if (value == 'no') return 'Outdoor';
        return 'Unknown';
      case 'covered':
        return value == 'yes' ? 'Covered' : 'Uncovered';
      default:
        return value ?? 'Unknown';
    }
  }
}
