import 'package:flutter/material.dart';
import 'package:move_young/screens/menus/widgets/generic_sport_screen.dart';

class TableTennisScreen extends StatelessWidget {
  const TableTennisScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const GenericSportScreen(
      title: 'Table Tennis',
      sportType: 'table_tennis',
    );
  }
}

class TableTennisDisplay {
  static final Map<String, (IconData, Color)> tagIcons = {
    'indoor': (Icons.home, Colors.blue),
    'covered': (Icons.roofing, Colors.blue),
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

extension StringCapitalize on String {
  String capitalize() =>
      isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';
}