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
  /// Map of tag keys to icons and colors
  static const Map<String, (IconData, Color)> tagIcons = {
    'surface': (Icons.sports_soccer, Colors.green),
    'lit': (Icons.lightbulb_outline, Colors.amber),
  };

  /// Format values for display, e.g. lit → Lit/Unlit
  static String formatValue(String key, String? value) {
    switch (key) {
      case 'lit':
        return value == 'yes' ? 'Lit' : 'Unlit';
      case 'surface':
        return value?.isNotEmpty == true ? value! : 'Unknown';
      default:
        return value ?? 'Unknown';
    }
  }
}
