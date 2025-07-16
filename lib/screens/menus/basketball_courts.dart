import 'package:flutter/material.dart';
import 'package:move_young/screens/menus/widgets/generic_sport_screen.dart';

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
  static Map<String, (IconData icon, Color color)> tagIcons = {
    'surface': (Icons.sports_basketball, Colors.orange),
    'lit': (Icons.lightbulb_outline, Colors.amber),
    'hoops': (Icons.sports, Colors.orange),
  };

  static String formatValue(String key, String? value) {
    if (key == 'lit') return value == 'yes' ? 'Lit' : 'Unlit';
    return value ?? 'Unknown';
  }
}
