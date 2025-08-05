import 'package:flutter/material.dart';
import 'package:move_young/screens/activities/sport_types/generic_sport_screen.dart';
import 'package:easy_localization/easy_localization.dart';

class BasketballCourtsScreen extends StatelessWidget {
  const BasketballCourtsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GenericSportScreen(
      title: 'basketball_courts'.tr(),
      sportType: 'basketball',
    );
  }
}

class BasketballFieldDisplay {
  static final Map<String, List<Object>> tagIcons = <String, List<Object>>{
    'surface': [Icons.sports_basketball, Colors.orange],
    'lit': [Icons.lightbulb_outline, Colors.amber],
    'hoops': [Icons.sports, Colors.orange],
  };

  static String formatValue(String key, String? value) {
    switch (key) {
      case 'lit':
        return value == 'yes' ? 'Lit' : 'Unlit';
      default:
        return value ?? 'Unknown';
    }
  }
}
