import 'package:flutter/material.dart';
import 'package:move_young/screens/activities/sport_types/generic_sport_screen.dart';

class FootballFieldScreen extends StatelessWidget {
  const FootballFieldScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const GenericSportScreen(
      title: 'Football Fields',
      sportType: 'soccer', 
    );
  }
}
class FootballFieldDisplay {
  static final Map<String, List<dynamic>> tagIcons = {
    'surface': [Icons.grass, Colors.green],
    'lit': [Icons.lightbulb, Colors.amber],
  };

  static String formatValue(String key, String? value) {
    if (key == 'lit') return value == 'yes' ? 'Yes' : 'No';
    return value ?? 'Unknown';
  }
}
