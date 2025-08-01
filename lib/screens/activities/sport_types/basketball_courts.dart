import 'package:flutter/material.dart';
import 'package:move_young/screens/activities/sport_types/generic_sport_screen.dart';

class BasketballCourtsScreen extends StatelessWidget {
  const BasketballCourtsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const GenericSportScreen(
      title: 'Basketball Courts',
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
        return value == 'yes' ? 'Lit': 'Unlit';
      default:
        return value ?? 'Unknown';
    }
  }
}  
